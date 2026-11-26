import '../domain/models/government_id_model.dart';
import 'biometric_privacy_guard.dart';

class GovIdSubmissionResult {
  final GovIdStatus status;
  final String? referenceId;
  final String message;
  final bool isDemoResult;

  const GovIdSubmissionResult({
    required this.status,
    this.referenceId,
    required this.message,
    this.isDemoResult = true,
  });
}

abstract class IGovernmentIdRepository {
  Future<GovIdSubmissionResult> submitDocument(GovernmentIdData data);
  Future<GovIdSubmissionResult> fetchKycStatus(String referenceId);
}

/// Production API boundary targeting:
/// - POST /v1/security/document-verify
/// - GET  /v1/security/kyc-status
class ProductionGovernmentIdRepository implements IGovernmentIdRepository {
  final String baseUrl;

  const ProductionGovernmentIdRepository({
    this.baseUrl = 'https://api.date2.app',
  });

  @override
  Future<GovIdSubmissionResult> submitDocument(GovernmentIdData data) async {
    try {
      if (data.frontImageBytes != null && !data.isFrontPdf) {
        data.frontImageBytes = BiometricPrivacyGuard.stripExifMetadataInMemory(
          data.frontImageBytes!,
        );
      }
      if (data.backImageBytes != null && !data.isBackPdf) {
        data.backImageBytes = BiometricPrivacyGuard.stripExifMetadataInMemory(
          data.backImageBytes!,
        );
      }
      throw UnimplementedError(
        'Production endpoint $baseUrl/v1/security/document-verify is offline.',
      );
    } finally {
      data.secureWipe();
    }
  }

  @override
  Future<GovIdSubmissionResult> fetchKycStatus(String referenceId) {
    throw UnimplementedError(
      'Production endpoint $baseUrl/v1/security/kyc-status is offline.',
    );
  }
}

/// Mock Government ID repository for frontend verification status transitions.
class MockGovernmentIdRepository implements IGovernmentIdRepository {
  @override
  Future<GovIdSubmissionResult> submitDocument(GovernmentIdData data) async {
    try {
      if (data.frontImageBytes != null && !data.isFrontPdf) {
        data.frontImageBytes = BiometricPrivacyGuard.stripExifMetadataInMemory(
          data.frontImageBytes!,
        );
      }
      if (data.backImageBytes != null && !data.isBackPdf) {
        data.backImageBytes = BiometricPrivacyGuard.stripExifMetadataInMemory(
          data.backImageBytes!,
        );
      }

      await Future.delayed(const Duration(milliseconds: 700));

      final docUpper = data.documentNumber.trim().toUpperCase();
      final prefix = data.country.name.substring(0, 2).toUpperCase();
      final refId = 'DEMO-DOC-$prefix-${DateTime.now().millisecondsSinceEpoch}';

      if (docUpper.startsWith('PENDING')) {
        return GovIdSubmissionResult(
          status: GovIdStatus.pendingReview,
          referenceId: refId,
          message:
              'Demo Status (Pending Review): Submitted to mock queue. Refresh status or retry with a valid number.',
        );
      }

      if (docUpper.startsWith('REJECT')) {
        return GovIdSubmissionResult(
          status: GovIdStatus.rejected,
          referenceId: refId,
          message:
              'Demo Status (Rejected): Document details could not be validated. Re-upload clear ID photos.',
        );
      }

      if (docUpper.startsWith('RETRY')) {
        return GovIdSubmissionResult(
          status: GovIdStatus.retryRequired,
          referenceId: refId,
          message:
              'Demo Status (Retry Required): Document quality check needs a clearer retake.',
        );
      }

      return GovIdSubmissionResult(
        status: GovIdStatus.verified,
        referenceId: refId,
        message:
            'Demo Mode: Local document quality checks passed for ${data.documentType}. Real server OCR & official KYC validation require backend integration.',
      );
    } finally {
      // Clear local image byte buffers immediately after mock processing
      data.secureWipe();
    }
  }

  @override
  Future<GovIdSubmissionResult> fetchKycStatus(String referenceId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return GovIdSubmissionResult(
      status: GovIdStatus.verified,
      referenceId: referenceId,
      message: 'Demo KYC Status: Verified after mock check.',
    );
  }
}
