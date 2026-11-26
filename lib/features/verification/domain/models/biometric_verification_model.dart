import 'dart:typed_data';
import 'package:inclusive_dating/features/auth/domain/models/auth_state.dart';
import 'package:inclusive_dating/features/verification/data/biometric_privacy_guard.dart';

/// Verification actions required by Module 1 SRS specifications:
/// - Blink twice
/// - Turn head ~15° to the left
/// - Turn head ~15° to the right
enum BiometricLivenessAction {
  blinkTwice(
    'Blink twice',
    'Blink your eyes twice naturally',
    'Keep your head centered inside the oval while blinking',
  ),
  turnLeft(
    'Turn head ~15° left',
    'Turn head ~15° to the left',
    'Keep your face inside the oval guide',
  ),
  turnRight(
    'Turn head ~15° right',
    'Turn head ~15° to the right',
    'Keep your face inside the oval guide',
  );

  final String title;
  final String instruction;
  final String helper;
  const BiometricLivenessAction(this.title, this.instruction, this.helper);
}

/// Real-time face alignment and distance states matching Section 7 prompts.
enum FaceAlignmentStatus {
  noFaceDetected('Center your face', false),
  multipleFaces('Only one face should be visible', false),
  tooFar('Move closer', false),
  tooClose('Move farther away', false),
  offCenterHorizontal('Move slightly left or right', false),
  offCenterVertical('Center your face', false),
  poorLighting('Improve lighting', false),
  holdStill('Hold still', false),
  aligned('Face correctly positioned', true);

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
  permanentlyDenied,
  restricted,
  unavailable,
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

/// Output of biometric embedding extraction boundary.
class BiometricEmbeddingResult {
  final bool isAvailable;
  final List<double>? embeddingVector;
  final String limitationNote;

  const BiometricEmbeddingResult({
    required this.isAvailable,
    this.embeddingVector,
    required this.limitationNote,
  });
}

/// Abstract biometric feature-extraction interface required for future
/// integration of a 512-d FaceNet / ArcFace TFLite model.
///
/// Google ML Kit face detection only yields 2D bounding boxes, landmarks,
/// Euler head pose, and eye probabilities — it does NOT extract biometric
/// identity embeddings.
abstract class IBiometricEmbeddingExtractor {
  bool get isModelBundled;
  Future<BiometricEmbeddingResult> extractEmbedding(Uint8List sanitizedFrameBytes);
}

class PendingTfliteEmbeddingExtractor implements IBiometricEmbeddingExtractor {
  const PendingTfliteEmbeddingExtractor();

  @override
  bool get isModelBundled => false;

  @override
  Future<BiometricEmbeddingResult> extractEmbedding(
    Uint8List sanitizedFrameBytes,
  ) async {
    return const BiometricEmbeddingResult(
      isAvailable: false,
      embeddingVector: null,
      limitationNote:
          'No 512-d face-recognition TFLite model is bundled in assets. '
          'On-device ML Kit performs alignment and anti-spoofing liveness only.',
    );
  }
}

class BiometricVerificationResult {
  final bool isSuccess;
  final FaceVerificationStatus resultStatus;
  final bool isDemoResult;
  final String message;
  final double confidenceScore;
  final String? verificationId;
  final String? cryptographicProofHash;
  final DateTime? verifiedAt;

  const BiometricVerificationResult({
    required this.isSuccess,
    this.resultStatus = FaceVerificationStatus.verified,
    this.isDemoResult = true,
    required this.message,
    required this.confidenceScore,
    this.verificationId,
    this.cryptographicProofHash,
    this.verifiedAt,
  });

  factory BiometricVerificationResult.fromJson(Map<String, dynamic> json) {
    final success = json['success'] as bool? ?? false;
    return BiometricVerificationResult(
      isSuccess: success,
      resultStatus: success
          ? FaceVerificationStatus.verified
          : FaceVerificationStatus.failed,
      isDemoResult: json['is_demo_result'] as bool? ?? true,
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
        'result_status': resultStatus.name,
        'is_demo_result': isDemoResult,
        'message': message,
        'confidence_score': confidenceScore,
        'verification_id': verificationId,
        'proof_hash': cryptographicProofHash,
        'timestamp': verifiedAt?.toIso8601String(),
      };
}

/// Biometric frame container with best-effort volatile memory buffer cleanup
/// and EXIF metadata stripping.
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
  final bool metadataStripped;

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
    this.metadataStripped = false,
  });

  /// Strips sensitive EXIF/camera metadata from rawBytes in volatile memory.
  void stripMetadataInMemory() {
    if (rawBytes != null && rawBytes!.isNotEmpty) {
      final sanitized =
          BiometricPrivacyGuard.stripExifMetadataInMemory(rawBytes!);
      if (!identical(sanitized, rawBytes)) {
        BiometricPrivacyGuard.bestEffortWipeBytes(rawBytes);
        rawBytes = sanitized;
      }
    }
  }

  /// Best-effort volatile buffer clearing: fills byte array with zeroes and
  /// drops Dart reference immediately.
  void secureWipe() {
    if (rawBytes != null) {
      BiometricPrivacyGuard.bestEffortWipeBytes(rawBytes);
      rawBytes = null;
    }
  }
}

/// Companion KYC submission model with best-effort volatile memory cleanup.
class CompanionKycSubmission {
  final String countryName;
  final String idType;
  Uint8List? frontIdBytes;
  Uint8List? backIdBytes;
  final String? selfieVerificationProofId;
  final bool policeClearanceAffirmed;
  final String legalFullName;
  final String documentNumber;

  CompanionKycSubmission({
    this.countryName = 'India',
    required this.idType,
    this.frontIdBytes,
    this.backIdBytes,
    required this.selfieVerificationProofId,
    required this.policeClearanceAffirmed,
    required this.legalFullName,
    required this.documentNumber,
  });

  /// Best-effort volatile buffer clearing for raw ID byte arrays.
  void secureWipe() {
    if (frontIdBytes != null) {
      BiometricPrivacyGuard.bestEffortWipeBytes(frontIdBytes);
      frontIdBytes = null;
    }
    if (backIdBytes != null) {
      BiometricPrivacyGuard.bestEffortWipeBytes(backIdBytes);
      backIdBytes = null;
    }
  }
}
