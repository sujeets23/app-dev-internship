import 'dart:typed_data';

enum BiometricLivenessAction {
  blinkTwice('Blink your eyes twice'),
  turnLeft('Slowly turn your head left'),
  turnRight('Slowly turn your head right'),
  smile('Give a natural smile');

  final String instruction;
  const BiometricLivenessAction(this.instruction);
}

enum BiometricVerificationStatus {
  unverified,
  scanning,
  processing,
  verified,
  failed,
}

class FaceLandmarkPoint {
  final double x;
  final double y;
  const FaceLandmarkPoint(this.x, this.y);
}

class BiometricVerificationResult {
  final bool isSuccess;
  final String message;
  final double confidenceScore;
  final String? verificationId;

  const BiometricVerificationResult({
    required this.isSuccess,
    required this.message,
    required this.confidenceScore,
    this.verificationId,
  });

  factory BiometricVerificationResult.fromJson(Map<String, dynamic> json) {
    return BiometricVerificationResult(
      isSuccess: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.0,
      verificationId: json['verification_id'] as String?,
    );
  }
}

class BiometricFrameData {
  Uint8List? rawBytes; // Cleared in volatile memory immediately after processing
  final bool isLightingAdequate;
  final bool isDistanceAdequate;
  final bool isFaceCentered;
  final List<FaceLandmarkPoint> landmarks;

  BiometricFrameData({
    this.rawBytes,
    required this.isLightingAdequate,
    required this.isDistanceAdequate,
    required this.isFaceCentered,
    required this.landmarks,
  });

  /// Security requirement: Clear volatile memory buffers immediately
  void secureWipe() {
    if (rawBytes != null) {
      rawBytes!.fillRange(0, rawBytes!.length, 0);
      rawBytes = null;
    }
  }
}
