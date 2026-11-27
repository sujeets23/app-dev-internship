import 'dart:typed_data';
import 'package:inclusive_dating/features/verification/data/biometric_privacy_guard.dart';

enum GovernmentIdCountry {
  india('India', '🇮🇳', [
    'Aadhaar Card',
    'PAN Card',
    'Passport',
    'Driving Licence',
    'Voter ID',
    'Other National ID',
  ]),
  unitedStates('United States', '🇺🇸', [
    'Passport',
    'State ID / National ID',
    'Driving Licence',
  ]),
  unitedKingdom('United Kingdom', '🇬🇧', [
    'Passport',
    'National Identity Card',
    'Driving Licence',
  ]),
  canada('Canada', '🇨🇦', [
    'Passport',
    'Provincial ID Card',
    'Driving Licence',
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
    return true;
  }
}

/// Extensible configuration record allowing dynamic addition of countries and
/// country-specific KYC document schemas without editing enum code.
class CountryDocumentSchema {
  final String code;
  final String name;
  final String flag;
  final List<String> documentTypes;

  const CountryDocumentSchema({
    required this.code,
    required this.name,
    required this.flag,
    required this.documentTypes,
  });

  static List<CountryDocumentSchema> defaultCatalog() =>
      GovernmentIdCountry.values
          .map(
            (c) => CountryDocumentSchema(
              code: c.name,
              name: c.countryName,
              flag: c.flag,
              documentTypes: c.supportedDocuments,
            ),
          )
          .toList();
}

enum GovIdQualityCheckStatus {
  pass('Passed ✓', true),
  warning('Warning', false),
  fail('Failed ✗', false);

  final String label;
  final bool isOk;
  const GovIdQualityCheckStatus(this.label, this.isOk);
}

/// Detailed quality evaluation produced from genuine pixel analysis or PDF verification.
class DocumentQualityFeedback {
  final bool isSharp;
  final bool isNoGlare;
  final bool areEdgesVisible;
  final bool isLightingAdequate;
  final bool isOrientationCorrect;
  final bool isPdfUpload;
  final double sharpnessScore;
  final double meanLuminance;
  final double glareRatio;
  final List<String> issues;

  const DocumentQualityFeedback({
    this.isSharp = true,
    this.isNoGlare = true,
    this.areEdgesVisible = true,
    this.isLightingAdequate = true,
    this.isOrientationCorrect = true,
    this.isPdfUpload = false,
    this.sharpnessScore = 100.0,
    this.meanLuminance = 128.0,
    this.glareRatio = 0.0,
    this.issues = const [],
  });

  bool get isCompliant =>
      isSharp &&
      isNoGlare &&
      areEdgesVisible &&
      isLightingAdequate &&
      isOrientationCorrect;
}

class CapturedDocumentSide {
  Uint8List? bytes;
  final String? fileName;
  final bool isPdf;
  final DocumentQualityFeedback quality;

  CapturedDocumentSide({
    required this.bytes,
    this.fileName,
    this.isPdf = false,
    required this.quality,
  });

  void secureWipe() {
    if (bytes != null) {
      BiometricPrivacyGuard.bestEffortWipeBytes(bytes);
      bytes = null;
    }
  }
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
  final bool isFrontPdf;
  final bool isBackPdf;
  final DocumentQualityFeedback quality;
  final GovIdStatus status;
  final String? proofReferenceId;

  GovernmentIdData({
    required this.country,
    required this.documentType,
    required this.documentNumber,
    this.frontImageBytes,
    this.backImageBytes,
    this.isFrontPdf = false,
    this.isBackPdf = false,
    this.quality = const DocumentQualityFeedback(),
    this.status = GovIdStatus.notStarted,
    this.proofReferenceId,
  });

  String? get documentNumberError =>
      GovernmentIdValidator.validate(documentType, documentNumber);

  bool get hasValidDocumentNumber => documentNumberError == null;

  bool get hasRequiredSides {
    final needsBack = GovernmentIdCountry.requiresBackSide(documentType);
    if (needsBack) {
      return frontImageBytes != null && backImageBytes != null;
    }
    return frontImageBytes != null;
  }

  bool get isCompleteProof => hasValidDocumentNumber && hasRequiredSides;

  void secureWipe() {
    if (frontImageBytes != null) {
      BiometricPrivacyGuard.bestEffortWipeBytes(frontImageBytes);
      frontImageBytes = null;
    }
    if (backImageBytes != null) {
      BiometricPrivacyGuard.bestEffortWipeBytes(backImageBytes);
      backImageBytes = null;
    }
  }
}

/// Shared mandatory validation for Government ID numbers across consumer
/// verification and Companion KYC.
class GovernmentIdValidator {
  const GovernmentIdValidator._();

  static final RegExp _allowedChars = RegExp(r'^[A-Za-z0-9\s\-/]+$');
  static final RegExp _separators = RegExp(r'[\s\-/]');
  static final RegExp _aadhaarRegex = RegExp(r'^\d{12}$');
  static final RegExp _panRegex = RegExp(r'^[A-Z]{5}\d{4}[A-Z]$');
  static final RegExp _passportRegex = RegExp(r'^(?=.*\d)[A-Z0-9]{6,12}$');
  static final RegExp _generalIdRegex = RegExp(r'^(?=.*\d)[A-Z0-9]{6,20}$');

  static bool isDemoKeyword(String rawValue) {
    final compact = rawValue.trim().replaceAll(_separators, '').toUpperCase();
    return compact.startsWith('PENDING') ||
        compact.startsWith('REJECT') ||
        compact.startsWith('RETRY') ||
        compact.startsWith('APPROVE');
  }

  static String hintForDocumentType(String docType) {
    switch (docType) {
      case 'Aadhaar Card':
        return '12-digit Aadhaar number (e.g. 1234 5678 9012)';
      case 'PAN Card':
        return '10-character PAN (e.g. ABCDE1234F)';
      case 'Passport':
        return '6–12 character passport no. (e.g. K1234567)';
      case 'Driving Licence':
        return '6–20 character licence no. (e.g. DL1420110012345)';
      case 'Voter ID':
        return '6–20 character EPIC / Voter ID (e.g. ABC1234567)';
      default:
        return '6–20 character ID number (e.g. ID-123456)';
    }
  }

  /// Returns `null` when [rawValue] satisfies mandatory proof requirements for
  /// [docType], or an actionable error message otherwise.
  static String? validate(String docType, String rawValue) {
    final trimmed = rawValue.trim();
    if (trimmed.isEmpty) {
      return 'Mandatory proof: Enter your $docType number.';
    }
    if (!_allowedChars.hasMatch(trimmed)) {
      return 'Use only letters, numbers, spaces, hyphens, or slashes.';
    }
    if (isDemoKeyword(trimmed)) {
      return null;
    }

    final compact = trimmed.replaceAll(_separators, '').toUpperCase();
    if (docType == 'Aadhaar Card') {
      if (!_aadhaarRegex.hasMatch(compact)) {
        return 'Enter the complete 12-digit Aadhaar number (e.g. 1234 5678 9012).';
      }
      return null;
    }

    if (docType == 'PAN Card') {
      if (!_panRegex.hasMatch(compact)) {
        return 'Enter a valid 10-character PAN (e.g. ABCDE1234F).';
      }
      return null;
    }

    if (docType == 'Passport') {
      if (!_passportRegex.hasMatch(compact)) {
        return 'Enter a valid 6–12 character Passport number containing at least 1 digit.';
      }
      return null;
    }

    if (!_generalIdRegex.hasMatch(compact)) {
      return 'Enter a valid 6–20 character $docType number containing at least 1 digit.';
    }
    return null;
  }
}
