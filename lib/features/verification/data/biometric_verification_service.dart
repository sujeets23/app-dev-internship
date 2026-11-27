import 'dart:async';
import 'dart:math';
import 'package:inclusive_dating/features/auth/domain/models/auth_state.dart';
import '../domain/models/biometric_verification_model.dart';
import '../domain/models/government_id_model.dart';

abstract class IBiometricVerificationService {
  Future<BiometricVerificationResult> verifyBiometric({
    required BiometricFrameData frameData,
    required BiometricLivenessAction completedAction,
  });

  List<BiometricLivenessAction> generateChallengeSequence();

  Future<Map<String, dynamic>> submitCompanionKyc(
    CompanionKycSubmission submission,
  );
}

/// Production API Client boundary targeting:
/// - POST /v1/auth/biometric-verify
/// - POST /v1/security/face-scan
/// - POST /v1/auth/companion-kyc
///
/// Compliance Contract for future backend integration:
/// 1. Transmission must enforce TLS 1.3+ certificate pinning.
/// 2. Backend MUST extract the mathematical embedding in transient RAM and
///    prohibit persistent raw selfie object storage.
/// 3. Client strips EXIF metadata before upload and wipes local buffers in `finally`.
class ProductionBiometricVerificationService
    implements IBiometricVerificationService {
  final String baseUrl;
  final IBiometricEmbeddingExtractor embeddingExtractor;

  ProductionBiometricVerificationService({
    this.baseUrl = 'https://api.date2.app',
    this.embeddingExtractor = const PendingTfliteEmbeddingExtractor(),
  });

  @override
  List<BiometricLivenessAction> generateChallengeSequence() {
    final actions = List<BiometricLivenessAction>.from(
      BiometricLivenessAction.values,
    )..shuffle(Random());
    return actions;
  }

  @override
  Future<BiometricVerificationResult> verifyBiometric({
    required BiometricFrameData frameData,
    required BiometricLivenessAction completedAction,
  }) async {
    try {
      frameData.stripMetadataInMemory();
      if (frameData.rawBytes != null && embeddingExtractor.isModelBundled) {
        await embeddingExtractor.extractEmbedding(frameData.rawBytes!);
      }
      throw UnimplementedError(
        'Production backend server at $baseUrl/v1/auth/biometric-verify is offline. '
        'No raw biometric images are uploaded during frontend-only development.',
      );
    } finally {
      frameData.secureWipe();
    }
  }

  @override
  Future<Map<String, dynamic>> submitCompanionKyc(
    CompanionKycSubmission submission,
  ) async {
    try {
      throw UnimplementedError(
        'Production backend server at $baseUrl/v1/auth/companion-kyc is offline.',
      );
    } finally {
      submission.secureWipe();
    }
  }
}

/// Frontend Demo Verification Service.
/// Explicitly separates on-device liveness checks from unimplemented backend
/// biometric identity matching and clears raw byte buffers after processing.
class MockBiometricVerificationService
    implements IBiometricVerificationService {
  final IBiometricEmbeddingExtractor embeddingExtractor;

  MockBiometricVerificationService({
    this.embeddingExtractor = const PendingTfliteEmbeddingExtractor(),
  });

  @override
  List<BiometricLivenessAction> generateChallengeSequence() {
    final actions = List<BiometricLivenessAction>.from(
      BiometricLivenessAction.values,
    )..shuffle(Random());
    return actions;
  }

  @override
  Future<BiometricVerificationResult> verifyBiometric({
    required BiometricFrameData frameData,
    required BiometricLivenessAction completedAction,
  }) async {
    try {
      frameData.stripMetadataInMemory();
      await Future.delayed(const Duration(milliseconds: 650));

      if (!frameData.isLightingAdequate) {
        return const BiometricVerificationResult(
          isSuccess: false,
          resultStatus: FaceVerificationStatus.retryRequired,
          isDemoResult: true,
          message:
              'Liveness incomplete: Insufficient lighting detected. Move to a well-lit area and retry.',
          confidenceScore: 0.38,
        );
      }

      if (!frameData.isDistanceAdequate) {
        return const BiometricVerificationResult(
          isSuccess: false,
          resultStatus: FaceVerificationStatus.retryRequired,
          isDemoResult: true,
          message:
              'Liveness incomplete: Face distance was out of range inside the oval guide.',
          confidenceScore: 0.44,
        );
      }

      if (!frameData.isFaceCentered) {
        return const BiometricVerificationResult(
          isSuccess: false,
          resultStatus: FaceVerificationStatus.failed,
          isDemoResult: true,
          message:
              'Verification failed: Face was not centered inside the alignment frame.',
          confidenceScore: 0.49,
        );
      }

      // Check embedding availability transparently (do NOT fake a 512-d match)
      final embeddingRes = frameData.rawBytes != null
          ? await embeddingExtractor.extractEmbedding(frameData.rawBytes!)
          : const BiometricEmbeddingResult(
              isAvailable: false,
              limitationNote:
                  'No 512-d embedding model bundled; verified active liveness in Demo Mode.',
            );

      final timestamp = DateTime.now();
      final proofId = 'VERIF-B3D-${timestamp.millisecondsSinceEpoch}';
      final proofHash =
          'demo-sha256:liveness-${timestamp.microsecondsSinceEpoch.toRadixString(16)}';

      return BiometricVerificationResult(
        isSuccess: true,
        resultStatus: FaceVerificationStatus.verified,
        isDemoResult: true,
        message: embeddingRes.isAvailable
            ? 'Demo Liveness & Biometric Check Passed.'
            : 'Demo Mode: Active camera liveness passed. (${embeddingRes.limitationNote})',
        confidenceScore: 0.96,
        verificationId: proofId,
        cryptographicProofHash: proofHash,
        verifiedAt: timestamp,
      );
    } finally {
      // Best-effort clear of local volatile frame buffer immediately
      frameData.secureWipe();
    }
  }

  @override
  Future<Map<String, dynamic>> submitCompanionKyc(
    CompanionKycSubmission submission,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));
    try {
      if (!submission.policeClearanceAffirmed) {
        return {
          'success': false,
          'status': CompanionKycStatus.rejected.name,
          'message': 'Background & safety affirmation is required.',
        };
      }
      final docNumberError = GovernmentIdValidator.validate(
        submission.idType,
        submission.documentNumber,
      );
      if (docNumberError != null) {
        return {
          'success': false,
          'status': CompanionKycStatus.rejected.name,
          'message': docNumberError,
        };
      }
      if (submission.selfieVerificationProofId == null ||
          submission.selfieVerificationProofId!.isEmpty) {
        return {
          'success': false,
          'status': CompanionKycStatus.retryRequired.name,
          'message': 'A completed live biometric liveness selfie is required.',
        };
      }
      return {
        'success': true,
        'kyc_reference_id': 'DEMO-KYC-${DateTime.now().millisecondsSinceEpoch}',
        'status': CompanionKycStatus.pendingVerification.name,
        'message':
            'Demo Submission Recorded: Government ID and liveness proof submitted (pending backend KYC verification). Local volatile buffers cleared.',
      };
    } finally {
      submission.secureWipe();
    }
  }
}
