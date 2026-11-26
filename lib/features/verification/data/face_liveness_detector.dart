import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../domain/models/biometric_verification_model.dart';

/// Structured result extracted purely in memory from one camera frame.
class FaceAnalysisResult {
  final bool hasFace;
  final int faceCount;
  final double meanLuma; // 0.0 to 255.0
  final FaceAlignmentStatus alignmentStatus;
  final double headEulerAngleY;
  final double? leftEyeOpenProbability;
  final double? rightEyeOpenProbability;
  final List<FaceLandmarkPoint> normalizedLandmarks;
  final bool hardwareSupported;

  const FaceAnalysisResult({
    required this.hasFace,
    required this.faceCount,
    required this.meanLuma,
    required this.alignmentStatus,
    this.headEulerAngleY = 0.0,
    this.leftEyeOpenProbability,
    this.rightEyeOpenProbability,
    this.normalizedLandmarks = const [],
    this.hardwareSupported = true,
  });

  factory FaceAnalysisResult.unsupportedPlatform() => const FaceAnalysisResult(
        hasFace: false,
        faceCount: 0,
        meanLuma: 0.0,
        alignmentStatus: FaceAlignmentStatus.noFaceDetected,
        hardwareSupported: false,
      );
}

abstract class IFaceFrameAnalyzer {
  bool get isSupportedOnCurrentPlatform;
  Future<FaceAnalysisResult> analyzeCameraImage(
    CameraImage image,
    CameraDescription cameraDescription,
    DeviceOrientation deviceOrientation,
  );
  Future<void> dispose();
}

/// Real on-device Google ML Kit Face Detector analyzer processing camera frames
/// strictly in memory (NV21 / YUV420 Android & BGRA8888 iOS).
class MlKitFaceFrameAnalyzer implements IFaceFrameAnalyzer {
  FaceDetector? _faceDetector;
  bool _isDisposed = false;

  MlKitFaceFrameAnalyzer() {
    if (isSupportedOnCurrentPlatform) {
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: true,
          enableLandmarks: true,
          enableTracking: true,
          minFaceSize: 0.15,
          performanceMode: FaceDetectorMode.accurate,
        ),
      );
    }
  }

  @override
  bool get isSupportedOnCurrentPlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  Future<FaceAnalysisResult> analyzeCameraImage(
    CameraImage image,
    CameraDescription cameraDescription,
    DeviceOrientation deviceOrientation,
  ) async {
    if (_isDisposed || !isSupportedOnCurrentPlatform || _faceDetector == null) {
      return FaceAnalysisResult.unsupportedPlatform();
    }

    // 1. Estimate ambient brightness directly from volatile plane buffer
    final meanLuma = _estimateAmbientLuma(image);

    // 2. Build InputImage cleanly in volatile RAM without touching disk
    final inputImage =
        _convertCameraImageToInputImage(image, cameraDescription, deviceOrientation);
    if (inputImage == null) {
      return FaceAnalysisResult(
        hasFace: false,
        faceCount: 0,
        meanLuma: meanLuma,
        alignmentStatus: meanLuma < 45.0
            ? FaceAlignmentStatus.poorLighting
            : FaceAlignmentStatus.noFaceDetected,
      );
    }

    final faces = await _faceDetector!.processImage(inputImage);
    if (faces.isEmpty) {
      return FaceAnalysisResult(
        hasFace: false,
        faceCount: 0,
        meanLuma: meanLuma,
        alignmentStatus: meanLuma < 45.0
            ? FaceAlignmentStatus.poorLighting
            : FaceAlignmentStatus.noFaceDetected,
      );
    }

    if (faces.length > 1) {
      return FaceAnalysisResult(
        hasFace: true,
        faceCount: faces.length,
        meanLuma: meanLuma,
        alignmentStatus: FaceAlignmentStatus.multipleFaces,
      );
    }

    final face = faces.first;

    // Account for image rotation when normalizing bounding box vs upright preview
    final rotation = inputImage.metadata?.rotation ?? InputImageRotation.rotation0deg;
    final bool isRotated = rotation == InputImageRotation.rotation90deg ||
        rotation == InputImageRotation.rotation270deg;
    final double effectiveW =
        isRotated ? image.height.toDouble() : image.width.toDouble();
    final double effectiveH =
        isRotated ? image.width.toDouble() : image.height.toDouble();

    final rect = face.boundingBox;
    final double widthRatio = effectiveW > 0 ? rect.width / effectiveW : 0.0;
    final double centerX =
        effectiveW > 0 ? rect.center.dx / effectiveW : 0.5;
    final double centerY =
        effectiveH > 0 ? rect.center.dy / effectiveH : 0.5;

    final FaceAlignmentStatus alignment;
    if (meanLuma < 45.0) {
      alignment = FaceAlignmentStatus.poorLighting;
    } else if (widthRatio < 0.24) {
      alignment = FaceAlignmentStatus.tooFar;
    } else if (widthRatio > 0.70) {
      alignment = FaceAlignmentStatus.tooClose;
    } else if ((centerX - 0.5).abs() > 0.16) {
      alignment = FaceAlignmentStatus.offCenterHorizontal;
    } else if ((centerY - 0.5).abs() > 0.18) {
      alignment = FaceAlignmentStatus.offCenterVertical;
    } else {
      alignment = FaceAlignmentStatus.aligned;
    }

    final landmarks = <FaceLandmarkPoint>[];
    for (final entry in face.landmarks.entries) {
      final lm = entry.value;
      if (lm != null && effectiveW > 0 && effectiveH > 0) {
        landmarks.add(
          FaceLandmarkPoint(
            (lm.position.x / effectiveW).clamp(0.0, 1.0),
            (lm.position.y / effectiveH).clamp(0.0, 1.0),
            entry.key.name,
          ),
        );
      }
    }

    return FaceAnalysisResult(
      hasFace: true,
      faceCount: 1,
      meanLuma: meanLuma,
      alignmentStatus: alignment,
      headEulerAngleY: face.headEulerAngleY ?? 0.0,
      leftEyeOpenProbability: face.leftEyeOpenProbability,
      rightEyeOpenProbability: face.rightEyeOpenProbability,
      normalizedLandmarks: landmarks,
    );
  }

  double _estimateAmbientLuma(CameraImage image) {
    if (image.planes.isEmpty) return 0.0;
    final plane0 = image.planes.first;
    final bytes = plane0.bytes;
    if (bytes.isEmpty) return 0.0;

    final step = math.max(1, bytes.length ~/ 500);
    int sum = 0;
    int count = 0;

    if (image.format.group == ImageFormatGroup.bgra8888) {
      // BGRA: sample every 4-byte pixel stride
      final pxStep = math.max(4, step - (step % 4));
      for (int i = 0; i + 2 < bytes.length; i += pxStep) {
        final b = bytes[i];
        final g = bytes[i + 1];
        final r = bytes[i + 2];
        sum += ((0.299 * r) + (0.587 * g) + (0.114 * b)).round();
        count++;
      }
    } else {
      // NV21 / YUV420: plane 0 is direct Y-channel luma
      for (int i = 0; i < bytes.length; i += step) {
        sum += bytes[i];
        count++;
      }
    }

    return count == 0 ? 0.0 : sum / count;
  }

  InputImage? _convertCameraImageToInputImage(
    CameraImage image,
    CameraDescription camera,
    DeviceOrientation deviceOrientation,
  ) {
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;

    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      final orientations = <DeviceOrientation, int>{
        DeviceOrientation.portraitUp: 0,
        DeviceOrientation.landscapeLeft: 90,
        DeviceOrientation.portraitDown: 180,
        DeviceOrientation.landscapeRight: 270,
      };
      var rotationCompensation = orientations[deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }

    if (rotation == null) return null;

    var format = InputImageFormatValue.fromRawValue(image.format.raw);
    format ??= switch (image.format.group) {
      ImageFormatGroup.yuv420 => InputImageFormat.yuv_420_888,
      ImageFormatGroup.nv21 => InputImageFormat.nv21,
      ImageFormatGroup.bgra8888 => InputImageFormat.bgra8888,
      _ => null,
    };
    if (format == null) return null;

    Uint8List bytes;
    InputImageFormat effectiveFormat = format;

    if (Platform.isAndroid &&
        (format == InputImageFormat.yuv_420_888 || image.planes.length == 3)) {
      // Android CameraX frequently emits YUV_420_888 3-plane images; convert
      // cleanly into contiguous NV21 bytes in volatile memory for ML Kit.
      bytes = _yuv420ToNv21(image);
      effectiveFormat = InputImageFormat.nv21;
    } else if (image.planes.length == 1) {
      bytes = image.planes.first.bytes;
    } else {
      final allBytes = WriteBuffer();
      for (final plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      bytes = allBytes.done().buffer.asUint8List();
    }

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: effectiveFormat,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  Uint8List _yuv420ToNv21(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final ySize = width * height;
    final uvSize = (width * height) ~/ 2;
    final nv21 = Uint8List(ySize + uvSize);

    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    // Copy Y plane respecting rowStride and buffer bounds
    if (yPlane.bytesPerRow == width && yPlane.bytes.length >= ySize) {
      nv21.setRange(0, ySize, yPlane.bytes);
    } else {
      for (int row = 0; row < height; row++) {
        final srcStart = row * yPlane.bytesPerRow;
        if (srcStart >= yPlane.bytes.length) break;
        final copyLen = math.min(width, yPlane.bytes.length - srcStart);
        final dstStart = row * width;
        nv21.setRange(dstStart, dstStart + copyLen, yPlane.bytes, srcStart);
      }
    }

    // Interleave VU for NV21
    final uRowStride = uPlane.bytesPerRow;
    final vRowStride = vPlane.bytesPerRow;
    final uPixelStride = uPlane.bytesPerPixel ?? 1;
    final vPixelStride = vPlane.bytesPerPixel ?? 1;
    int offset = ySize;
    final uvHeight = height ~/ 2;
    final uvWidth = width ~/ 2;

    for (int row = 0; row < uvHeight; row++) {
      for (int col = 0; col < uvWidth; col++) {
        final uIndex = row * uRowStride + col * uPixelStride;
        final vIndex = row * vRowStride + col * vPixelStride;
        if (offset + 1 < nv21.length &&
            vIndex < vPlane.bytes.length &&
            uIndex < uPlane.bytes.length) {
          nv21[offset++] = vPlane.bytes[vIndex];
          nv21[offset++] = uPlane.bytes[uIndex];
        }
      }
    }

    return nv21;
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    await _faceDetector?.close();
    _faceDetector = null;
  }
}
