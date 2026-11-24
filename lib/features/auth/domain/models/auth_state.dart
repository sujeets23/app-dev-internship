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

class AuthUserState {
  final String? username;
  final String? email;
  final bool isAuthenticated;
  final bool isEmailVerified;
  final bool isFaceVerified;
  final bool isDocVerified;
  final String? faceProofId;
  final String? docProofId;
  final String? selectedCountry;
  final String? selectedDocType;
  final UsernameAvailabilityStatus usernameStatus;
  final EmailOtpStatus emailOtpStatus;
  final String? lastErrorMessage;

  const AuthUserState({
    this.username,
    this.email,
    this.isAuthenticated = false,
    this.isEmailVerified = false,
    this.isFaceVerified = false,
    this.isDocVerified = false,
    this.faceProofId,
    this.docProofId,
    this.selectedCountry = 'India',
    this.selectedDocType = 'Aadhaar Card',
    this.usernameStatus = UsernameAvailabilityStatus.none,
    this.emailOtpStatus = EmailOtpStatus.waiting,
    this.lastErrorMessage,
  });

  bool get isFullyVerified =>
      isEmailVerified && isFaceVerified && isDocVerified;

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
    String? faceProofId,
    String? docProofId,
    String? selectedCountry,
    String? selectedDocType,
    UsernameAvailabilityStatus? usernameStatus,
    EmailOtpStatus? emailOtpStatus,
    String? lastErrorMessage,
  }) {
    return AuthUserState(
      username: username ?? this.username,
      email: email ?? this.email,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isFaceVerified: isFaceVerified ?? this.isFaceVerified,
      isDocVerified: isDocVerified ?? this.isDocVerified,
      faceProofId: faceProofId ?? this.faceProofId,
      docProofId: docProofId ?? this.docProofId,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedDocType: selectedDocType ?? this.selectedDocType,
      usernameStatus: usernameStatus ?? this.usernameStatus,
      emailOtpStatus: emailOtpStatus ?? this.emailOtpStatus,
      lastErrorMessage: lastErrorMessage ?? this.lastErrorMessage,
    );
  }
}
