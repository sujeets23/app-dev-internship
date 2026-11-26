import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import '../domain/models/biometric_verification_model.dart';
import 'face_liveness_detector.dart';

import 'web_face_landmarker_stub.dart'
    if (dart.library.js_interop) 'web_face_landmarker_web.dart';

enum WebScannerStatus {
  requestingPermission,
  loadingModel,
  ready,
  permissionDenied,
  unavailable,
  interrupted,
  modelError,
}

typedef WebFaceFrameCallback = void Function(FaceAnalysisResult result);
typedef WebFaceStatusCallback = void Function(
  WebScannerStatus status,
  String message,
);

/// Platform-safe interface bridging Chrome `getUserMedia` + MediaPipe FaceLandmarker
/// into Flutter Web while leaving Android/iOS ML Kit untouched.
abstract class IWebFaceScannerBridge {
  bool get isSupported;
  Widget buildPreviewWidget();
  Future<void> start({
    required WebFaceFrameCallback onFrame,
    required WebFaceStatusCallback onStatus,
  });
  Uint8List? captureSnapshotBytes();
  Future<void> stop();
  void dispose();
}

IWebFaceScannerBridge createWebFaceScannerBridge() =>
    createPlatformWebFaceScannerBridge();

/// Pure helper parsing MediaPipe JSON telemetry cleanly into [FaceAnalysisResult].
/// Decoupled from `dart:js_interop` so it can be unit-tested on Dart VM too.
FaceAnalysisResult mapWebLandmarkerMetricsToAnalysis({
  required bool hasFace,
  required int faceCount,
  required double meanLuma,
  required double widthRatio,
  required double centerX,
  required double centerY,
  required double headYawDeg,
  required double leftEyeOpen,
  required double rightEyeOpen,
  List<FaceLandmarkPoint> landmarks = const [],
}) {
  if (!hasFace || faceCount == 0) {
    return FaceAnalysisResult(
      hasFace: false,
      faceCount: 0,
      meanLuma: meanLuma,
      alignmentStatus: meanLuma < 45.0
          ? FaceAlignmentStatus.poorLighting
          : FaceAlignmentStatus.noFaceDetected,
    );
  }

  if (faceCount > 1) {
    return FaceAnalysisResult(
      hasFace: true,
      faceCount: faceCount,
      meanLuma: meanLuma,
      alignmentStatus: FaceAlignmentStatus.multipleFaces,
    );
  }

  final FaceAlignmentStatus alignment;
  if (meanLuma < 45.0) {
    alignment = FaceAlignmentStatus.poorLighting;
  } else if (widthRatio < 0.22) {
    alignment = FaceAlignmentStatus.tooFar;
  } else if (widthRatio > 0.68) {
    alignment = FaceAlignmentStatus.tooClose;
  } else if ((centerX - 0.5).abs() > 0.17) {
    alignment = FaceAlignmentStatus.offCenterHorizontal;
  } else if ((centerY - 0.5).abs() > 0.19) {
    alignment = FaceAlignmentStatus.offCenterVertical;
  } else {
    alignment = FaceAlignmentStatus.aligned;
  }

  return FaceAnalysisResult(
    hasFace: true,
    faceCount: 1,
    meanLuma: meanLuma,
    alignmentStatus: alignment,
    headEulerAngleY: headYawDeg,
    leftEyeOpenProbability: leftEyeOpen,
    rightEyeOpenProbability: rightEyeOpen,
    normalizedLandmarks: landmarks,
    hardwareSupported: true,
  );
}
