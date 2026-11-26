import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inclusive_dating/features/verification/domain/models/government_id_model.dart';
import 'package:inclusive_dating/features/auth/data/auth_repository.dart';
import 'package:inclusive_dating/features/auth/data/secure_token_storage.dart';
import 'package:inclusive_dating/features/auth/domain/models/auth_state.dart';

/// Optional SharedPreferences provider so standalone ProviderContainer unit tests
/// remain decoupled while app execution persists dev mock onboarding/auth state.
final optionalSharedPreferencesProvider =
    Provider<SharedPreferences?>((ref) => null);

/// Guard toggle overridden to `true` in `main.dart` and guard test suites.
/// Defaults to `false` only for unauthenticated legacy single-screen unit tests.
final authGuardEnforcedProvider = Provider<bool>((ref) => false);

final secureTokenStorageProvider = Provider<ISecureTokenStorage>((ref) {
  return MockAuthSessionBoundary();
});

final authSessionManagerProvider = Provider<IAuthSessionManager>((ref) {
  return ProductionAuthSessionManager(
    tokenStorage: ref.watch(secureTokenStorageProvider),
  );
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final prefs = ref.watch(optionalSharedPreferencesProvider);
  return MockAuthRepository(prefs: prefs);
});

class AuthNotifier extends Notifier<AuthUserState> {
  static const String _devMockAuthKey = 'dev_mock_auth_state_v1';

  Timer? _debounceTimer;
  IAuthRepository get _repo => ref.read(authRepositoryProvider);
  SharedPreferences? get _prefs => ref.read(optionalSharedPreferencesProvider);
  ISecureTokenStorage get _tokenBoundary =>
      ref.read(secureTokenStorageProvider);

  @override
  AuthUserState build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return _restoreDevMockState();
  }

  AuthUserState _restoreDevMockState() {
    final raw = _prefs?.getString(_devMockAuthKey);
    if (raw == null || raw.isEmpty) {
      return const AuthUserState();
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AuthUserState.fromMockJson(map);
    } catch (_) {
      return const AuthUserState();
    }
  }

  Future<void> _persistDevMockState() async {
    final prefs = _prefs;
    if (prefs == null) return;
    if (!state.isAuthenticated) {
      await prefs.remove(_devMockAuthKey);
    } else {
      await prefs.setString(_devMockAuthKey, jsonEncode(state.toMockJson()));
    }
  }

  /// Debounced username validation and availability check using configurable rules
  void checkUsername(String username) {
    _debounceTimer?.cancel();
    final cfg = _repo.usernameConfig;
    final clean = cfg.normalize(username);

    if (clean.length < cfg.minLength || cfg.validate(clean) != null) {
      state = state.copyWith(
        usernameStatus: UsernameAvailabilityStatus.none,
        clearError: true,
      );
      return;
    }

    state = state.copyWith(
      usernameStatus: UsernameAvailabilityStatus.checking,
      clearError: true,
    );

    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      try {
        final status = await _repo.checkUsernameAvailability(clean);
        state = state.copyWith(
          username: clean,
          usernameStatus: status,
          clearError: true,
        );
      } catch (e) {
        state = state.copyWith(
          usernameStatus: UsernameAvailabilityStatus.error,
          lastErrorMessage:
              'Unable to check username availability. Please retry.',
        );
      }
    });
  }

  /// Signup action creating a mock user record with unverified verification flags.
  Future<bool> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    final normalizedUsername = _repo.usernameConfig.normalize(username);
    final normalizedEmail = email.trim().toLowerCase();

    final success = await _repo.registerUser(
      username: normalizedUsername,
      email: normalizedEmail,
      password: password,
    );
    if (success) {
      final otpStatus = await _repo.sendVerificationOtp(normalizedEmail);
      if (_tokenBoundary is MockAuthSessionBoundary) {
        (_tokenBoundary as MockAuthSessionBoundary)
            .markDevSessionActive(normalizedEmail);
      }
      state = state.copyWith(
        username: normalizedUsername,
        email: normalizedEmail,
        isAuthenticated: true,
        isEmailVerified: false,
        isFaceVerified: false,
        isDocVerified: false,
        isPersonalInfoCompleted: false,
        emailOtpStatus: otpStatus,
        faceVerificationStatus: FaceVerificationStatus.pending,
        docVerificationStatus: GovIdStatus.notStarted,
        clearError: true,
      );
      await _persistDevMockState();
      return true;
    }
    state = state.copyWith(
      lastErrorMessage: 'An account with that email or username already exists.',
    );
    return false;
  }

  /// Login action validating mock credentials and restoring account verification flags.
  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    final success = await _repo.loginUser(
      identifier: identifier,
      password: password,
    );
    if (!success) {
      state = state.copyWith(
        lastErrorMessage: 'Invalid username/email or password.',
      );
      return false;
    }

    final restored = await _repo.getAccountVerificationState(identifier);
    if (restored != null) {
      state = restored.copyWith(
        isPersonalInfoCompleted: state.isPersonalInfoCompleted &&
            restored.isFullyVerified,
        clearError: true,
      );
    } else {
      final isEmail = identifier.contains('@');
      state = state.copyWith(
        email: isEmail ? identifier.trim().toLowerCase() : (state.email ?? ''),
        username: isEmail ? (state.username ?? '') : identifier.trim().toLowerCase(),
        isAuthenticated: true,
        clearError: true,
      );
    }

    if (_tokenBoundary is MockAuthSessionBoundary) {
      (_tokenBoundary as MockAuthSessionBoundary)
          .markDevSessionActive(state.email ?? state.username ?? 'mock_user');
    }

    await _persistDevMockState();
    return true;
  }

  /// Development-only active demo OTP lookup (null in production).
  DemoOtpSnapshot? getDemoOtpSnapshot({
    String? email,
    bool isPasswordReset = false,
  }) {
    final target = (email ?? state.email ?? '').trim().toLowerCase();
    if (target.isEmpty) return null;
    return _repo.getDemoOtpSnapshot(
      target,
      isPasswordReset: isPasswordReset,
    );
  }

  /// Ensures a 6-digit demo OTP is issued (useful on app restart recovery).
  Future<EmailOtpStatus> ensureDemoOtpIssued({
    required String email,
    bool isPasswordReset = false,
  }) async {
    final clean = email.trim().toLowerCase();
    final existing = _repo.getDemoOtpSnapshot(
      clean,
      isPasswordReset: isPasswordReset,
    );
    if (existing != null) {
      return EmailOtpStatus.waiting;
    }
    if (isPasswordReset) {
      final ok = await _repo.sendPasswordResetOtp(clean);
      return ok ? EmailOtpStatus.waiting : EmailOtpStatus.deliveryFailed;
    }
    final status = await _repo.sendVerificationOtp(clean);
    state = state.copyWith(emailOtpStatus: status);
    return status;
  }

  /// Expires the active demo OTP immediately so tests/QA can exercise expiry UI.
  Future<void> expireDemoOtpForTesting({
    required String email,
    bool isPasswordReset = false,
  }) async {
    await _repo.expireDemoOtpForTesting(
      email,
      isPasswordReset: isPasswordReset,
    );
    if (!isPasswordReset) {
      state = state.copyWith(emailOtpStatus: EmailOtpStatus.expiredOtp);
    }
  }

  /// Send or resend 6-digit verification OTP to the current or updated email.
  Future<EmailOtpStatus> sendOrResendOtp({String? overrideEmail}) async {
    state = state.copyWith(emailOtpStatus: EmailOtpStatus.resending);
    final target = (overrideEmail ?? state.email ?? '').trim().toLowerCase();
    final status = await _repo.sendVerificationOtp(target);
    state = state.copyWith(emailOtpStatus: status);
    return status;
  }

  /// Update email during OTP step and trigger fresh OTP delivery.
  Future<EmailOtpStatus> editEmailAndResendOtp(String newEmail) async {
    final cleanNew = newEmail.trim().toLowerCase();
    final oldEmail = (state.email ?? '').trim().toLowerCase();
    state = state.copyWith(emailOtpStatus: EmailOtpStatus.resending);
    final status = await _repo.updateUnverifiedEmail(
      currentEmail: oldEmail,
      updatedEmail: cleanNew,
    );
    state = state.copyWith(
      email: cleanNew,
      isEmailVerified: false,
      emailOtpStatus: status,
    );
    await _persistDevMockState();
    return status;
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
        clearError: true,
      );
      await _persistDevMockState();
    } else {
      state = state.copyWith(emailOtpStatus: status);
    }

    return status;
  }

  /// Track all 6 face verification result states cleanly
  void setFaceVerificationStatus(
    FaceVerificationStatus status, {
    String? proofId,
    String? errorMessage,
  }) {
    final verified = status == FaceVerificationStatus.verified;
    state = state.copyWith(
      isFaceVerified: verified,
      faceVerificationStatus: status,
      faceProofId: verified ? (proofId ?? state.faceProofId) : state.faceProofId,
      lastErrorMessage: errorMessage,
    );
    if (verified && state.email != null) {
      _repo.updateAccountVerificationFlags(
        email: state.email!,
        isFaceVerified: true,
        faceProofId: state.faceProofId,
      );
    }
    _persistDevMockState();
  }

  /// Mark face biometric verification as completed
  void setFaceVerified(String proofId) {
    setFaceVerificationStatus(
      FaceVerificationStatus.verified,
      proofId: proofId,
    );
  }

  /// Track document status transitions cleanly
  void setDocStatus(
    GovIdStatus docStatus, {
    String? country,
    String? docType,
    String? docId,
  }) {
    final isVerified = docStatus == GovIdStatus.verified;
    state = state.copyWith(
      isDocVerified: isVerified,
      docVerificationStatus: docStatus,
      selectedCountry: country ?? state.selectedCountry,
      selectedDocType: docType ?? state.selectedDocType,
      docProofId: docId ?? state.docProofId,
    );
    if (isVerified && state.email != null) {
      _repo.updateAccountVerificationFlags(
        email: state.email!,
        isDocVerified: true,
        docProofId: state.docProofId,
      );
    }
    _persistDevMockState();
  }

  /// Mark government ID verification as completed
  void setDocVerified({
    required String country,
    required String docType,
    required String docId,
  }) {
    setDocStatus(
      GovIdStatus.verified,
      country: country,
      docType: docType,
      docId: docId,
    );
  }

  /// Update Companion KYC lifecycle independently from consumer onboarding gate
  void setCompanionKycState(
    CompanionKycStatus status, {
    String? referenceId,
  }) {
    state = state.copyWith(
      companionKycStatus: status,
      companionKycReferenceId: referenceId ?? state.companionKycReferenceId,
    );
    _persistDevMockState();
  }

  void setPersonalInfoCompleted(bool completed) {
    if (!state.isFullyVerified && completed) return;
    state = state.copyWith(isPersonalInfoCompleted: completed);
    _persistDevMockState();
  }

  /// Strict navigation guard evaluation enforcing sequential Module 1 pipeline
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
        return state.isFullyVerified;
      case AuthFlowStep.completed:
        return state.isFullyVerified && state.isPersonalInfoCompleted;
    }
  }

  /// Returns the next required route in the sequential flow
  AuthFlowStep getNextRequiredStep() {
    if (!state.isAuthenticated) return AuthFlowStep.login;
    if (!state.isEmailVerified) return AuthFlowStep.emailOtp;
    if (!state.isFaceVerified) return AuthFlowStep.securityCheck;
    if (!state.isDocVerified) return AuthFlowStep.govId;
    if (!state.isPersonalInfoCompleted) return AuthFlowStep.personalInfo;
    return AuthFlowStep.completed;
  }

  void resetForTesting() {
    state = const AuthUserState();
    _persistDevMockState();
  }

  Future<void> logout() async {
    await _tokenBoundary.clearTokens();
    state = const AuthUserState();
    await _persistDevMockState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthUserState>(
  AuthNotifier.new,
);
