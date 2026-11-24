import 'dart:typed_data';

/// Verification actions required by Module 1 SRS specifications:
/// - Blink twice
/// - Turn head ~15° to the left
/// - Turn head ~15° to the right
enum BiometricLivenessAction {
  blinkTwice(
    'Blink twice',
    'Blink your eyes twice naturally',
    'Keep your head centered while blinking',
  ),
  turnLeft(
    'Turn head ~15° left',
    'Slowly turn your head 15° to the left',
    'Keep your face inside the oval guide',
  ),
  turnRight(
    'Turn head ~15° right',
    'Slowly turn your head 15° to the right',
    'Keep your face inside the oval guide',
  );

  final String title;
  final String instruction;
  final String helper;
  const BiometricLivenessAction(this.title, this.instruction, this.helper);
}

/// Real-time face alignment and distance states
enum FaceAlignmentStatus {
  noFaceDetected('Position your face inside the oval', false),
  tooFar('Move closer', false),
  tooClose('Move slightly back', false),
  poorLighting('Improve lighting', false),
  aligned('Face detected & aligned', true);

  final String guidanceMessage;
  final bool isSatisfied;
  const FaceAlignmentStatus(this.guidanceMessage, this.isSatisfied);
}

/// Camera permission states
enum CameraPermissionState {
  initial,
  checking,
  granted,
  denied,
  restricted,
}

/// Overall biometric verification pipeline states
enum BiometricVerificationStatus {
  unverified,
  requestingPermission,
  aligning,
  challenging,
  processing,
  verified,
  failed,
}

class FaceLandmarkPoint {
  final double x;
  final double y;
  final String? type;
  const FaceLandmarkPoint(this.x, this.y, [this.type]);
}

class BiometricVerificationResult {
  final bool isSuccess;
  final String message;
  final double confidenceScore;
  final String? verificationId;
  final String? cryptographicProofHash;
  final DateTime? verifiedAt;

  const BiometricVerificationResult({
    required this.isSuccess,
    required this.message,
    required this.confidenceScore,
    this.verificationId,
    this.cryptographicProofHash,
    this.verifiedAt,
  });

  factory BiometricVerificationResult.fromJson(Map<String, dynamic> json) {
    return BiometricVerificationResult(
      isSuccess: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.0,
      verificationId: json['verification_id'] as String?,
      cryptographicProofHash: json['proof_hash'] as String?,
      verifiedAt: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': isSuccess,
        'message': message,
        'confidence_score': confidenceScore,
        'verification_id': verificationId,
        'proof_hash': cryptographicProofHash,
        'timestamp': verifiedAt?.toIso8601String(),
      };
}

/// Biometric frame container with mandatory volatile memory zeroing
class BiometricFrameData {
  Uint8List? rawBytes; // Processed strictly in volatile memory
  final bool isLightingAdequate;
  final bool isDistanceAdequate;
  final bool isFaceCentered;
  final FaceAlignmentStatus alignmentStatus;
  final List<FaceLandmarkPoint> landmarks;
  final double headEulerAngleY; // -15.0 to +15.0 degrees
  final double leftEyeOpenProbability; // 0.0 to 1.0
  final double rightEyeOpenProbability; // 0.0 to 1.0

  BiometricFrameData({
    this.rawBytes,
    required this.isLightingAdequate,
    required this.isDistanceAdequate,
    required this.isFaceCentered,
    this.alignmentStatus = FaceAlignmentStatus.aligned,
    required this.landmarks,
    this.headEulerAngleY = 0.0,
    this.leftEyeOpenProbability = 1.0,
    this.rightEyeOpenProbability = 1.0,
  });

  /// Security requirement: Clear volatile memory buffers immediately
  void secureWipe() {
    if (rawBytes != null) {
      rawBytes!.fillRange(0, rawBytes!.length, 0);
      rawBytes = null;
    }
  }
}

/// Companion KYC submission model with volatile memory cleanup
class CompanionKycSubmission {
  final String idType;
  Uint8List? frontIdBytes;
  Uint8List? backIdBytes;
  final String? selfieVerificationProofId;
  final bool policeClearanceAffirmed;
  final String legalFullName;
  final String documentNumber;

  CompanionKycSubmission({
    required this.idType,
    this.frontIdBytes,
    this.backIdBytes,
    required this.selfieVerificationProofId,
    required this.policeClearanceAffirmed,
    required this.legalFullName,
    required this.documentNumber,
  });

  /// Security requirement: Strip all raw image bytes from volatile memory
  void secureWipe() {
    if (frontIdBytes != null) {
      frontIdBytes!.fillRange(0, frontIdBytes!.length, 0);
      frontIdBytes = null;
    }
    if (backIdBytes != null) {
      backIdBytes!.fillRange(0, backIdBytes!.length, 0);
      backIdBytes = null;
    }
  }
}
