import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../domain/models/auth_state.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return MockAuthRepository();
});

class AuthNotifier extends Notifier<AuthUserState> {
  Timer? _debounceTimer;
  IAuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  AuthUserState build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return const AuthUserState();
  }

  /// Debounced username validation and availability check
  void checkUsername(String username) {
    _debounceTimer?.cancel();
    final clean = username.trim().toLowerCase();

    if (clean.length < 3) {
      state = state.copyWith(usernameStatus: UsernameAvailabilityStatus.none);
      return;
    }

    state = state.copyWith(usernameStatus: UsernameAvailabilityStatus.checking);

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        final status = await _repo.checkUsernameAvailability(clean);
        state = state.copyWith(
          username: clean,
          usernameStatus: status,
        );
      } catch (e) {
        state = state.copyWith(
          usernameStatus: UsernameAvailabilityStatus.error,
          lastErrorMessage: 'Unable to check username availability.',
        );
      }
    });
  }

  /// Signup action
  Future<bool> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    final success = await _repo.registerUser(
      username: username,
      email: email,
      password: password,
    );
    if (success) {
      state = state.copyWith(
        username: username.trim().toLowerCase(),
        email: email.trim(),
        isAuthenticated: true,
        isEmailVerified: false,
        isFaceVerified: false,
        isDocVerified: false,
        emailOtpStatus: EmailOtpStatus.waiting,
      );
      return true;
    }
    return false;
  }

  /// Login action with smart routing based on verification state
  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    final success = await _repo.loginUser(
      identifier: identifier,
      password: password,
    );
    if (success) {
      final isEmail = identifier.contains('@');
      state = state.copyWith(
        email: isEmail ? identifier : (state.email ?? 'user@date2.app'),
        username: isEmail ? (state.username ?? 'user_demo') : identifier,
        isAuthenticated: true,
      );
      return true;
    }
    return false;
  }

  /// Verify 6-digit email OTP
  Future<EmailOtpStatus> verifyEmailOtp(String enteredOtp) async {
    state = state.copyWith(emailOtpStatus: EmailOtpStatus.verifying);

    final status = await _repo.verifyEmailOtp(
      state.email ?? 'user@date2.app',
      enteredOtp,
    );

    if (status == EmailOtpStatus.success) {
      state = state.copyWith(
        isEmailVerified: true,
        emailOtpStatus: EmailOtpStatus.success,
      );
    } else {
      state = state.copyWith(emailOtpStatus: status);
    }

    return status;
  }

  /// Mark face biometric verification as completed
  void setFaceVerified(String proofId) {
    state = state.copyWith(
      isFaceVerified: true,
      faceProofId: proofId,
    );
  }

  /// Mark government ID verification as completed
  void setDocVerified({
    required String country,
    required String docType,
    required String docId,
  }) {
    state = state.copyWith(
      isDocVerified: true,
      selectedCountry: country,
      selectedDocType: docType,
      docProofId: docId,
    );
  }

  /// Strict navigation guard evaluation
  bool canAccessStep(AuthFlowStep step) {
    switch (step) {
      case AuthFlowStep.signup:
      case AuthFlowStep.login:
        return true;
      case AuthFlowStep.emailOtp:
        return state.isAuthenticated;
      case AuthFlowStep.securityCheck:
      case AuthFlowStep.faceScan:
      case AuthFlowStep.faceResult:
        return state.isAuthenticated && state.isEmailVerified;
      case AuthFlowStep.govId:
        return state.isAuthenticated &&
            state.isEmailVerified &&
            state.isFaceVerified;
      case AuthFlowStep.verificationStatus:
      case AuthFlowStep.personalInfo:
      case AuthFlowStep.completed:
        return state.isFullyVerified;
    }
  }

  /// Returns the next required route in the sequential flow
  AuthFlowStep getNextRequiredStep() {
    if (!state.isAuthenticated) return AuthFlowStep.signup;
    if (!state.isEmailVerified) return AuthFlowStep.emailOtp;
    if (!state.isFaceVerified) return AuthFlowStep.securityCheck;
    if (!state.isDocVerified) return AuthFlowStep.govId;
    return AuthFlowStep.personalInfo;
  }

  /// Reset all verification states for test scenarios
  void resetForTesting() {
    state = const AuthUserState();
  }

  /// Logout action
  void logout() {
    state = const AuthUserState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthUserState>(
  AuthNotifier.new,
);
