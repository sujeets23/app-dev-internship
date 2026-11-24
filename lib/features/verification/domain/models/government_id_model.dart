import 'dart:typed_data';

enum GovernmentIdCountry {
  india('India', '🇮🇳', [
    'Aadhaar Card',
    'PAN Card',
    'Passport',
    'Driving Licence',
    'Voter ID',
  ]),
  unitedStates('United States', '🇺🇸', [
    'Passport',
    'State ID / National ID',
    'Driver License',
  ]),
  unitedKingdom('United Kingdom', '🇬🇧', [
    'Passport',
    'National Identity Card',
    'Driving Licence',
  ]),
  canada('Canada', '🇨🇦', [
    'Passport',
    'Provincial ID Card',
    'Driver Licence',
  ]),
  international('Other / International', '🌐', [
    'Passport',
    'National ID Card',
    'Driving Licence',
  ]);

  final String countryName;
  final String flag;
  final List<String> supportedDocuments;

  const GovernmentIdCountry(
    this.countryName,
    this.flag,
    this.supportedDocuments,
  );

  static bool requiresBackSide(String docType) {
    final lower = docType.toLowerCase();
    if (lower.contains('passport') || lower.contains('pan card')) {
      return false;
    }
    return true; // Aadhaar, Driver License, National ID, Voter ID require both sides
  }
}

enum GovIdQualityCheckStatus {
  pass('Passed ✓', true),
  warning('Warning', false),
  fail('Failed ✗', false);

  final String label;
  final bool isOk;
  const GovIdQualityCheckStatus(this.label, this.isOk);
}

class DocumentQualityFeedback {
  final bool isSharp; // Not blurry
  final bool isNoGlare; // No glare/reflection
  final bool areEdgesVisible; // Corners and edges inside frame
  final bool isLightingAdequate; // Good lighting
  final bool isOrientationCorrect; // Horizontal orientation

  const DocumentQualityFeedback({
    this.isSharp = true,
    this.isNoGlare = true,
    this.areEdgesVisible = true,
    this.isLightingAdequate = true,
    this.isOrientationCorrect = true,
  });

  bool get isCompliant =>
      isSharp &&
      isNoGlare &&
      areEdgesVisible &&
      isLightingAdequate &&
      isOrientationCorrect;
}

enum GovIdVerificationStage {
  countrySelection,
  documentSelection,
  documentCapture,
  qualityGuidance,
  reviewAndSubmit,
  statusResult,
}

enum GovIdStatus {
  notStarted,
  documentSelected,
  captureInProgress,
  readyForSubmission,
  submitted,
  pendingReview,
  verified,
  rejected,
  retryRequired,
}

class GovernmentIdData {
  final GovernmentIdCountry country;
  final String documentType;
  final String documentNumber;
  Uint8List? frontImageBytes;
  Uint8List? backImageBytes;
  final DocumentQualityFeedback quality;
  final GovIdStatus status;
  final String? proofReferenceId;

  GovernmentIdData({
    required this.country,
    required this.documentType,
    required this.documentNumber,
    this.frontImageBytes,
    this.backImageBytes,
    this.quality = const DocumentQualityFeedback(),
    this.status = GovIdStatus.notStarted,
    this.proofReferenceId,
  });

  bool get hasRequiredSides {
    final needsBack = GovernmentIdCountry.requiresBackSide(documentType);
    if (needsBack) {
      return frontImageBytes != null && backImageBytes != null;
    }
    return frontImageBytes != null;
  }

  void secureWipe() {
    if (frontImageBytes != null) {
      frontImageBytes!.fillRange(0, frontImageBytes!.length, 0);
      frontImageBytes = null;
    }
    if (backImageBytes != null) {
      backImageBytes!.fillRange(0, backImageBytes!.length, 0);
      backImageBytes = null;
    }
  }
}
