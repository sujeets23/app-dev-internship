import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import '../domain/models/government_id_model.dart';

/// Pure in-memory on-device image quality analyzer for Government ID uploads
/// and captures. Uses decoded RGBA pixel luminance heuristics for brightness,
/// glare, blur (Laplacian variance), orientation, and edge visibility.
///
/// Does NOT perform fake OCR or document authenticity verification.
class DocumentQualityAnalyzer {
  const DocumentQualityAnalyzer();

  Future<DocumentQualityFeedback> analyzeBytes({
    required Uint8List bytes,
    required bool isPdf,
    String? fileName,
  }) async {
    if (bytes.isEmpty) {
      return const DocumentQualityFeedback(
        isSharp: false,
        isNoGlare: false,
        areEdgesVisible: false,
        isLightingAdequate: false,
        isOrientationCorrect: false,
        issues: ['Captured file or image buffer is empty.'],
      );
    }

    if (isPdf) {
      // Check PDF magic signature (%PDF) purely in RAM
      final hasPdfSignature = bytes.length >= 4 &&
          bytes[0] == 0x25 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x44 &&
          bytes[3] == 0x46;
      if (!hasPdfSignature) {
        return const DocumentQualityFeedback(
          isSharp: false,
          areEdgesVisible: false,
          isPdfUpload: true,
          issues: ['Uploaded PDF appears invalid or corrupted.'],
        );
      }
      return const DocumentQualityFeedback(
        isSharp: true,
        isNoGlare: true,
        areEdgesVisible: true,
        isLightingAdequate: true,
        isOrientationCorrect: true,
        isPdfUpload: true,
      );
    }

    try {
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 320,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final width = image.width;
      final height = image.height;
      image.dispose();
      codec.dispose();

      if (byteData == null || width < 40 || height < 40) {
        return const DocumentQualityFeedback(
          isSharp: false,
          areEdgesVisible: false,
          issues: [
            'Image resolution is too low. Move closer and ensure full card edges are clear.',
          ],
        );
      }

      final rgba = byteData.buffer.asUint8List();
      final luma = Float64List(width * height);
      double totalLuma = 0;
      int blownOutPixels = 0;

      for (int i = 0; i < width * height; i++) {
        final offset = i * 4;
        final r = rgba[offset];
        final g = rgba[offset + 1];
        final b = rgba[offset + 2];
        final y = (0.299 * r) + (0.587 * g) + (0.114 * b);
        luma[i] = y;
        totalLuma += y;
        if (y > 246.0) {
          blownOutPixels++;
        }
      }

      final pixelCount = width * height;
      final meanLuma = totalLuma / pixelCount;
      final glareRatio = blownOutPixels / pixelCount;

      // Discrete 4-neighbor Laplacian variance across interior pixels for focus/blur
      double lapSum = 0;
      double lapSqSum = 0;
      int lapCount = 0;
      for (int y = 1; y < height - 1; y += 2) {
        for (int x = 1; x < width - 1; x += 2) {
          final idx = y * width + x;
          final lap = (luma[idx - 1] +
                  luma[idx + 1] +
                  luma[idx - width] +
                  luma[idx + width]) -
              4.0 * luma[idx];
          lapSum += lap;
          lapSqSum += lap * lap;
          lapCount++;
        }
      }
      final meanLap = lapCount > 0 ? lapSum / lapCount : 0.0;
      final lapVariance =
          lapCount > 0 ? math.max(0.0, (lapSqSum / lapCount) - (meanLap * meanLap)) : 0.0;

      // Edge-frame check: compute variance along outer border band vs center
      double borderSum = 0;
      double borderSqSum = 0;
      int borderCount = 0;
      final marginX = math.max(2, (width * 0.06).round());
      final marginY = math.max(2, (height * 0.06).round());

      for (int y = 0; y < height; y += 2) {
        for (int x = 0; x < width; x += 2) {
          final isBorder = x < marginX ||
              x >= width - marginX ||
              y < marginY ||
              y >= height - marginY;
          if (isBorder) {
            final v = luma[y * width + x];
            borderSum += v;
            borderSqSum += v * v;
            borderCount++;
          }
        }
      }
      final borderMean = borderCount > 0 ? borderSum / borderCount : 0.0;
      final borderVariance = borderCount > 0
          ? math.max(0.0, (borderSqSum / borderCount) - (borderMean * borderMean))
          : 0.0;

      final bool isLightingOk = meanLuma >= 45.0 && meanLuma <= 238.0;
      final bool isNoGlare = glareRatio <= 0.16;
      final bool isSharp = lapVariance >= 45.0;
      final bool isOrientationOk = width >= height;
      // If frame shows some detail across interior and framing isn't uniformly blank
      final bool areEdgesVisible = lapVariance > 10.0 && borderVariance > 5.0;

      final issues = <String>[];
      if (!isLightingOk) {
        issues.add(
          meanLuma < 45.0
              ? 'Poor lighting detected: capture in brighter ambient light.'
              : 'Overexposed image detected: avoid harsh direct light.',
        );
      }
      if (!isNoGlare) {
        issues.add('Glare detected on surface: tilt card slightly away from light.');
      }
      if (!isSharp) {
        issues.add('Blur or low detail detected: hold steady and refocus camera.');
      }
      if (!isOrientationOk) {
        issues.add('Incorrect orientation: rotate document horizontally.');
      }
      if (!areEdgesVisible) {
        issues.add('Document appears cropped or outside frame boundaries.');
      }

      return DocumentQualityFeedback(
        isSharp: isSharp,
        isNoGlare: isNoGlare,
        areEdgesVisible: areEdgesVisible,
        isLightingAdequate: isLightingOk,
        isOrientationCorrect: isOrientationOk,
        isPdfUpload: false,
        sharpnessScore: lapVariance,
        meanLuminance: meanLuma,
        glareRatio: glareRatio,
        issues: issues,
      );
    } catch (_) {
      return const DocumentQualityFeedback(
        isSharp: false,
        areEdgesVisible: false,
        issues: ['Unable to decode image frame. Try capturing again or uploading PNG/JPG/PDF.'],
      );
    }
  }
}
