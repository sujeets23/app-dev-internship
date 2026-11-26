import 'package:inclusive_dating/features/verification/domain/models/government_id_model.dart';

enum UsernameAvailabilityStatus {
  none,
  checking,
  available,
  taken,
  error,
}

enum EmailOtpStatus {
  waiting,
  otpEntered,
  verifying,
  success,
  invalidOtp,
  expiredOtp,
  deliveryFailed,
  resending,
  serviceUnavailable,
}

enum AuthFlowStep {
  signup,
  login,
  emailOtp,
  securityCheck,
  faceScan,
  faceResult,
  govId,
  verificationStatus,
  personalInfo,
  completed,
}

/// Six explicit verification states required by Module 1 specification.
enum FaceVerificationStatus {
  pending('Pending', 'Face verification has not been completed yet.'),
  processing('Processing', 'Evaluating on-device liveness frames in memory.'),
  verified(
    'Liveness Passed (Demo)',
    'On-device camera & ML Kit liveness checks passed in Demo Mode. Backend 512-d embedding verification is not connected.',
  ),
  rejected(
    'Rejected',
    'Verification submission was rejected due to quality or anti-spoofing failure.',
  ),
  failed(
    'Failed',
    'Verification could not be completed due to camera error, timeout, or environmental conditions.',
  ),
  retryRequired(
    'Retry Required',
    'Please repeat the live camera alignment and liveness challenges.',
  );

  final String title;
  final String defaultDescription;
  const FaceVerificationStatus(this.title, this.defaultDescription);
}

/// Companion KYC lifecycle states required under Module 1 Companion KYC.
enum CompanionKycStatus {
  notStarted('Not Started'),
  inProgress('In Progress'),
  submitted('Submitted'),
  pendingVerification('Pending Verification'),
  approved('Approved (Demo)'),
  rejected('Rejected'),
  retryRequired('Retry Required');

  final String label;
  const CompanionKycStatus(this.label);
}

/// Configurable username rules as required by Feature 1 specification.
class UsernameValidationConfig {
  final int minLength;
  final int maxLength;
  final String allowedPatternSource;

  const UsernameValidationConfig({
    this.minLength = 3,
    this.maxLength = 20,
    this.allowedPatternSource = r'^[a-z0-9_]+$',
  });

  String normalize(String raw) => raw.trim().toLowerCase();

  String? validate(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return 'Username is required';
    }
    final normalized = normalize(raw);
    if (normalized.length < minLength) {
      return 'Username must be at least $minLength characters';
    }
    if (normalized.length > maxLength) {
      return 'Username cannot exceed $maxLength characters';
    }
    if (!RegExp(allowedPatternSource).hasMatch(normalized)) {
      return 'Only lowercase letters, numbers, and underscores (_) allowed';
    }
    return null;
  }
}

/// Configurable password policy and strength evaluation.
class PasswordValidationConfig {
  final int minLength;
  final bool requireUppercase;
  final bool requireNumber;
  final bool requireSpecialChar;

  const PasswordValidationConfig({
    this.minLength = 8,
    this.requireUppercase = true,
    this.requireNumber = true,
    this.requireSpecialChar = true,
  });

  PasswordStrengthEvaluation evaluate(String password) {
    final hasMinLength = password.length >= minLength;
    final hasUppercase =
        !requireUppercase || password.contains(RegExp(r'[A-Z]'));
    final hasNumber = !requireNumber || password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = !requireSpecialChar ||
        password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>\-_+=~`\[\]\\/;]'));

    int totalChecks = 1;
    int satisfiedChecks = hasMinLength ? 1 : 0;

    if (requireUppercase) {
      totalChecks++;
      if (hasUppercase) satisfiedChecks++;
    }
    if (requireNumber) {
      totalChecks++;
      if (hasNumber) satisfiedChecks++;
    }
    if (requireSpecialChar) {
      totalChecks++;
      if (hasSpecialChar) satisfiedChecks++;
    }

    return PasswordStrengthEvaluation(
      hasMinLength: hasMinLength,
      hasUppercase: hasUppercase,
      hasNumber: hasNumber,
      hasSpecialChar: hasSpecialChar,
      satisfiedCount: satisfiedChecks,
      totalCount: totalChecks,
    );
  }
}

class PasswordStrengthEvaluation {
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasNumber;
  final bool hasSpecialChar;
  final int satisfiedCount;
  final int totalCount;

  const PasswordStrengthEvaluation({
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasNumber,
    required this.hasSpecialChar,
    required this.satisfiedCount,
    required this.totalCount,
  });

  bool get isSatisfied => satisfiedCount >= totalCount;
  double get score => totalCount == 0 ? 0.0 : satisfiedCount / totalCount;

  String get label {
    if (satisfiedCount == 0) return '';
    if (score <= 0.5) return 'Weak';
    if (score < 1.0) return 'Moderate';
    return 'Strong';
  }
}

class AuthUserState {
  final String? username;
  final String? email;
  final bool isAuthenticated;
  final bool isEmailVerified;
  final bool isFaceVerified;
  final bool isDocVerified;
  final bool isPersonalInfoCompleted;
  final String? faceProofId;
  final String? docProofId;
  final String? selectedCountry;
  final String? selectedDocType;
  final UsernameAvailabilityStatus usernameStatus;
  final EmailOtpStatus emailOtpStatus;
  final FaceVerificationStatus faceVerificationStatus;
  final GovIdStatus docVerificationStatus;
  final CompanionKycStatus companionKycStatus;
  final String? companionKycReferenceId;
  final String? lastErrorMessage;

  const AuthUserState({
    this.username,
    this.email,
    this.isAuthenticated = false,
    this.isEmailVerified = false,
    this.isFaceVerified = false,
    this.isDocVerified = false,
    this.isPersonalInfoCompleted = false,
    this.faceProofId,
    this.docProofId,
    this.selectedCountry = 'India',
    this.selectedDocType = 'Aadhaar Card',
    this.usernameStatus = UsernameAvailabilityStatus.none,
    this.emailOtpStatus = EmailOtpStatus.waiting,
    this.faceVerificationStatus = FaceVerificationStatus.pending,
    this.docVerificationStatus = GovIdStatus.notStarted,
    this.companionKycStatus = CompanionKycStatus.notStarted,
    this.companionKycReferenceId,
    this.lastErrorMessage,
  });

  bool get isFullyVerified =>
      isAuthenticated && isEmailVerified && isFaceVerified && isDocVerified;

  double get verificationProgress {
    int count = 0;
    if (isEmailVerified) count++;
    if (isFaceVerified) count++;
    if (isDocVerified) count++;
    return count / 3.0;
  }

  AuthUserState copyWith({
    String? username,
    String? email,
    bool? isAuthenticated,
    bool? isEmailVerified,
    bool? isFaceVerified,
    bool? isDocVerified,
    bool? isPersonalInfoCompleted,
    String? faceProofId,
    String? docProofId,
    String? selectedCountry,
    String? selectedDocType,
    UsernameAvailabilityStatus? usernameStatus,
    EmailOtpStatus? emailOtpStatus,
    FaceVerificationStatus? faceVerificationStatus,
    GovIdStatus? docVerificationStatus,
    CompanionKycStatus? companionKycStatus,
    String? companionKycReferenceId,
    String? lastErrorMessage,
    bool clearError = false,
  }) {
    return AuthUserState(
      username: username ?? this.username,
      email: email ?? this.email,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isFaceVerified: isFaceVerified ?? this.isFaceVerified,
      isDocVerified: isDocVerified ?? this.isDocVerified,
      isPersonalInfoCompleted:
          isPersonalInfoCompleted ?? this.isPersonalInfoCompleted,
      faceProofId: faceProofId ?? this.faceProofId,
      docProofId: docProofId ?? this.docProofId,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedDocType: selectedDocType ?? this.selectedDocType,
      usernameStatus: usernameStatus ?? this.usernameStatus,
      emailOtpStatus: emailOtpStatus ?? this.emailOtpStatus,
      faceVerificationStatus:
          faceVerificationStatus ?? this.faceVerificationStatus,
      docVerificationStatus:
          docVerificationStatus ?? this.docVerificationStatus,
      companionKycStatus: companionKycStatus ?? this.companionKycStatus,
      companionKycReferenceId:
          companionKycReferenceId ?? this.companionKycReferenceId,
      lastErrorMessage: clearError ? null : (lastErrorMessage ?? this.lastErrorMessage),
    );
  }

  /// Development mock persistence serialization. Not intended for production
  /// security enforcement without server-verified signed tokens.
  Map<String, dynamic> toMockJson() => {
        'username': username,
        'email': email,
        'isAuthenticated': isAuthenticated,
        'isEmailVerified': isEmailVerified,
        'isFaceVerified': isFaceVerified,
        'isDocVerified': isDocVerified,
        'isPersonalInfoCompleted': isPersonalInfoCompleted,
        'faceProofId': faceProofId,
        'docProofId': docProofId,
        'selectedCountry': selectedCountry,
        'selectedDocType': selectedDocType,
        'faceVerificationStatus': faceVerificationStatus.name,
        'docVerificationStatus': docVerificationStatus.name,
        'companionKycStatus': companionKycStatus.name,
        'companionKycReferenceId': companionKycReferenceId,
      };

  factory AuthUserState.fromMockJson(Map<String, dynamic> json) {
    return AuthUserState(
      username: json['username'] as String?,
      email: json['email'] as String?,
      isAuthenticated: json['isAuthenticated'] as bool? ?? false,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isFaceVerified: json['isFaceVerified'] as bool? ?? false,
      isDocVerified: json['isDocVerified'] as bool? ?? false,
      isPersonalInfoCompleted: json['isPersonalInfoCompleted'] as bool? ?? false,
      faceProofId: json['faceProofId'] as String?,
      docProofId: json['docProofId'] as String?,
      selectedCountry: json['selectedCountry'] as String? ?? 'India',
      selectedDocType: json['selectedDocType'] as String? ?? 'Aadhaar Card',
      faceVerificationStatus: FaceVerificationStatus.values.firstWhere(
        (e) => e.name == json['faceVerificationStatus'],
        orElse: () => FaceVerificationStatus.pending,
      ),
      docVerificationStatus: GovIdStatus.values.firstWhere(
        (e) => e.name == json['docVerificationStatus'],
        orElse: () => GovIdStatus.notStarted,
      ),
      companionKycStatus: CompanionKycStatus.values.firstWhere(
        (e) => e.name == json['companionKycStatus'],
        orElse: () => CompanionKycStatus.notStarted,
      ),
      companionKycReferenceId: json['companionKycReferenceId'] as String?,
    );
  }
}
