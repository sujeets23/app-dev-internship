import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../../verification/domain/models/government_id_model.dart';
import '../domain/models/auth_state.dart';

/// Development-only snapshot of a locally generated 6-digit demo OTP.
class DemoOtpSnapshot {
  final String code;
  final DateTime expiresAt;
  final bool isPasswordReset;

  const DemoOtpSnapshot({
    required this.code,
    required this.expiresAt,
    this.isPasswordReset = false,
  });

  bool isExpiredAt(DateTime now) => now.isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
        'code': code,
        'expiresAt': expiresAt.toIso8601String(),
        'isPasswordReset': isPasswordReset,
      };

  factory DemoOtpSnapshot.fromJson(Map<String, dynamic> json) =>
      DemoOtpSnapshot(
        code: json['code'] as String,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        isPasswordReset: json['isPasswordReset'] as bool? ?? false,
      );
}

/// Internal mock account record stored strictly for frontend testing & demo flows.
class MockUserRecord {
  final String username;
  final String email;
  final String password;
  final bool isEmailVerified;
  final bool isFaceVerified;
  final bool isDocVerified;
  final String? faceProofId;
  final String? docProofId;

  const MockUserRecord({
    required this.username,
    required this.email,
    required this.password,
    this.isEmailVerified = false,
    this.isFaceVerified = false,
    this.isDocVerified = false,
    this.faceProofId,
    this.docProofId,
  });

  MockUserRecord copyWith({
    String? username,
    String? email,
    String? password,
    bool? isEmailVerified,
    bool? isFaceVerified,
    bool? isDocVerified,
    String? faceProofId,
    String? docProofId,
  }) {
    return MockUserRecord(
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isFaceVerified: isFaceVerified ?? this.isFaceVerified,
      isDocVerified: isDocVerified ?? this.isDocVerified,
      faceProofId: faceProofId ?? this.faceProofId,
      docProofId: docProofId ?? this.docProofId,
    );
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'password': password,
        'isEmailVerified': isEmailVerified,
        'isFaceVerified': isFaceVerified,
        'isDocVerified': isDocVerified,
        'faceProofId': faceProofId,
        'docProofId': docProofId,
      };

  factory MockUserRecord.fromJson(Map<String, dynamic> json) => MockUserRecord(
        username: json['username'] as String,
        email: json['email'] as String,
        password: json['password'] as String,
        isEmailVerified: json['isEmailVerified'] as bool? ?? false,
        isFaceVerified: json['isFaceVerified'] as bool? ?? false,
        isDocVerified: json['isDocVerified'] as bool? ?? false,
        faceProofId: json['faceProofId'] as String?,
        docProofId: json['docProofId'] as String?,
      );
}

abstract class IAuthRepository {
  UsernameValidationConfig get usernameConfig;
  PasswordValidationConfig get passwordConfig;

  Future<UsernameAvailabilityStatus> checkUsernameAvailability(String username);

  Future<bool> registerUser({
    required String username,
    required String email,
    required String password,
  });

  Future<bool> loginUser({
    required String identifier,
    required String password,
  });

  Future<AuthUserState?> getAccountVerificationState(String identifier);

  Future<EmailOtpStatus> sendVerificationOtp(String email);

  Future<EmailOtpStatus> updateUnverifiedEmail({
    required String currentEmail,
    required String updatedEmail,
  });

  Future<EmailOtpStatus> verifyEmailOtp(String email, String enteredOtp);

  Future<bool> sendPasswordResetOtp(String email);

  Future<EmailOtpStatus> verifyPasswordResetOtp(
    String email,
    String enteredOtp,
  );

  Future<bool> resetPassword(String email, String newPassword);

  Future<void> updateAccountVerificationFlags({
    required String email,
    bool? isEmailVerified,
    bool? isFaceVerified,
    bool? isDocVerified,
    String? faceProofId,
    String? docProofId,
  });

  /// Returns an active dev-only OTP snapshot when running against a mock repository.
  /// Production implementations return `null` and never expose OTPs client-side.
  DemoOtpSnapshot? getDemoOtpSnapshot(
    String email, {
    bool isPasswordReset = false,
  });

  /// Expires an active dev demo OTP immediately for deterministic expiry testing.
  Future<void> expireDemoOtpForTesting(
    String email, {
    bool isPasswordReset = false,
  });
}

/// Production API boundary targeting:
/// - GET  /v1/auth/check-username
/// - POST /v1/auth/register
/// - POST /v1/auth/login
/// - POST /v1/auth/send-otp
/// - POST /v1/auth/verify-otp
/// - POST /v1/auth/reset-password
class ProductionAuthRepository implements IAuthRepository {
  final String baseUrl;
  @override
  final UsernameValidationConfig usernameConfig;
  @override
  final PasswordValidationConfig passwordConfig;

  const ProductionAuthRepository({
    this.baseUrl = 'https://api.date2.app',
    this.usernameConfig = const UsernameValidationConfig(),
    this.passwordConfig = const PasswordValidationConfig(),
  });

  @override
  Future<UsernameAvailabilityStatus> checkUsernameAvailability(String username) {
    throw UnimplementedError(
      'Backend endpoint $baseUrl/v1/auth/check-username is not connected.',
    );
  }

  @override
  Future<bool> registerUser({
    required String username,
    required String email,
    required String password,
  }) {
    throw UnimplementedError(
      'Backend endpoint $baseUrl/v1/auth/register is not connected.',
    );
  }

  @override
  Future<bool> loginUser({
    required String identifier,
    required String password,
  }) {
    throw UnimplementedError(
      'Backend endpoint $baseUrl/v1/auth/login is not connected.',
    );
  }

  @override
  Future<AuthUserState?> getAccountVerificationState(String identifier) {
    throw UnimplementedError(
      'Backend account status lookup is not connected.',
    );
  }

  @override
  Future<EmailOtpStatus> sendVerificationOtp(String email) {
    throw UnimplementedError(
      'Backend endpoint $baseUrl/v1/auth/send-otp is not connected.',
    );
  }

  @override
  Future<EmailOtpStatus> updateUnverifiedEmail({
    required String currentEmail,
    required String updatedEmail,
  }) {
    throw UnimplementedError('Backend email update endpoint is not connected.');
  }

  @override
  Future<EmailOtpStatus> verifyEmailOtp(String email, String enteredOtp) {
    throw UnimplementedError(
      'Backend endpoint $baseUrl/v1/auth/verify-otp is not connected.',
    );
  }

  @override
  Future<bool> sendPasswordResetOtp(String email) {
    throw UnimplementedError(
      'Backend endpoint $baseUrl/v1/auth/send-otp (password reset) is not connected.',
    );
  }

  @override
  Future<EmailOtpStatus> verifyPasswordResetOtp(
    String email,
    String enteredOtp,
  ) {
    throw UnimplementedError(
      'Backend endpoint $baseUrl/v1/auth/verify-otp (password reset) is not connected.',
    );
  }

  @override
  Future<bool> resetPassword(String email, String newPassword) {
    throw UnimplementedError(
      'Backend password reset endpoint is not connected.',
    );
  }

  @override
  Future<void> updateAccountVerificationFlags({
    required String email,
    bool? isEmailVerified,
    bool? isFaceVerified,
    bool? isDocVerified,
    String? faceProofId,
    String? docProofId,
  }) async {}

  @override
  DemoOtpSnapshot? getDemoOtpSnapshot(
    String email, {
    bool isPasswordReset = false,
  }) =>
      null;

  @override
  Future<void> expireDemoOtpForTesting(
    String email, {
    bool isPasswordReset = false,
  }) async {}
}

/// Development & QA mock repository supporting full offline end-to-end testing.
class MockAuthRepository implements IAuthRepository {
  static const String _mockUsersStorageKey = 'dev_mock_auth_users_v1';
  static const String _mockOtpsStorageKey = 'dev_mock_auth_otps_v1';

  @override
  final UsernameValidationConfig usernameConfig;
  @override
  final PasswordValidationConfig passwordConfig;

  final SharedPreferences? _prefs;
  final Duration otpTtl;
  final Random _random;
  final DateTime Function() _clock;

  static const Set<String> _reservedUsernames = {
    'admin',
    'waseem',
    'alex',
    'date2',
    'support',
    'moderator',
    'official',
    'ananya',
  };

  static const Set<String> _qaErrorOtpTriggers = {
    '000000',
    '888888',
    '999999',
  };

  late final Map<String, MockUserRecord> _accounts;
  final Map<String, DemoOtpSnapshot> _otps = <String, DemoOtpSnapshot>{};
  final Set<String> _userRegisteredEmails = <String>{};

  MockAuthRepository({
    this._prefs,
    this.usernameConfig = const UsernameValidationConfig(),
    this.passwordConfig = const PasswordValidationConfig(),
    this.otpTtl = const Duration(minutes: 2),
    Random? random,
    DateTime Function()? clock,
  })  : _random = random ?? Random(),
        _clock = clock ?? DateTime.now {
    _accounts = _seedDefaultAccounts();
    _loadPersistedAccounts();
    _loadPersistedOtps();
  }

  Map<String, MockUserRecord> _seedDefaultAccounts() => {
        'demo.verified@date2.app': const MockUserRecord(
          username: 'demo_verified',
          email: 'demo.verified@date2.app',
          password: 'Date2Secure!2026',
          isEmailVerified: true,
          isFaceVerified: true,
          isDocVerified: true,
          faceProofId: 'DEMO-FACE-VERIFIED',
          docProofId: 'DEMO-DOC-VERIFIED',
        ),
        'demo.otp@date2.app': const MockUserRecord(
          username: 'demo_otp',
          email: 'demo.otp@date2.app',
          password: 'Date2Secure!2026',
          isEmailVerified: false,
          isFaceVerified: false,
          isDocVerified: false,
        ),
        'demo.face@date2.app': const MockUserRecord(
          username: 'demo_face',
          email: 'demo.face@date2.app',
          password: 'Date2Secure!2026',
          isEmailVerified: true,
          isFaceVerified: false,
          isDocVerified: false,
        ),
        'demo.doc@date2.app': const MockUserRecord(
          username: 'demo_doc',
          email: 'demo.doc@date2.app',
          password: 'Date2Secure!2026',
          isEmailVerified: true,
          isFaceVerified: true,
          isDocVerified: false,
          faceProofId: 'DEMO-FACE-SEEDED',
        ),
      };

  void _loadPersistedAccounts() {
    final raw = _prefs?.getString(_mockUsersStorageKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        _accounts[entry.key] =
            MockUserRecord.fromJson(entry.value as Map<String, dynamic>);
      }
    } catch (_) {
      // Ignore corrupt dev cache and retain seeded defaults
    }
  }

  void _loadPersistedOtps() {
    final raw = _prefs?.getString(_mockOtpsStorageKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        _otps[entry.key] =
            DemoOtpSnapshot.fromJson(entry.value as Map<String, dynamic>);
      }
    } catch (_) {
      // Ignore corrupt dev cache
    }
  }

  Future<void> _savePersistedAccounts() async {
    if (_prefs == null) return;
    final map = <String, dynamic>{};
    for (final entry in _accounts.entries) {
      map[entry.key] = entry.value.toJson();
    }
    await _prefs.setString(_mockUsersStorageKey, jsonEncode(map));
  }

  Future<void> _savePersistedOtps() async {
    if (_prefs == null) return;
    final map = <String, dynamic>{};
    for (final entry in _otps.entries) {
      map[entry.key] = entry.value.toJson();
    }
    await _prefs.setString(_mockOtpsStorageKey, jsonEncode(map));
  }

  String _otpKey(String email, bool isPasswordReset) =>
      '${email.trim().toLowerCase()}::${isPasswordReset ? 'reset' : 'verify'}';

  String _generateSixDigitCode() {
    while (true) {
      final value = 100000 + _random.nextInt(900000);
      final code = value.toString();
      if (!_qaErrorOtpTriggers.contains(code)) {
        return code;
      }
    }
  }

  Future<DemoOtpSnapshot> _issueOtp(
    String email, {
    required bool isPasswordReset,
  }) async {
    final snapshot = DemoOtpSnapshot(
      code: _generateSixDigitCode(),
      expiresAt: _clock().add(otpTtl),
      isPasswordReset: isPasswordReset,
    );
    _otps[_otpKey(email, isPasswordReset)] = snapshot;
    await _savePersistedOtps();
    return snapshot;
  }

  MockUserRecord? _findByIdentifier(String identifier) {
    final clean = identifier.trim().toLowerCase();
    if (_accounts.containsKey(clean)) {
      return _accounts[clean];
    }
    for (final record in _accounts.values) {
      if (record.username.toLowerCase() == clean) {
        return record;
      }
    }
    return null;
  }

  @override
  Future<UsernameAvailabilityStatus> checkUsernameAvailability(
    String username,
  ) async {
    final clean = usernameConfig.normalize(username);
    if (clean.length < usernameConfig.minLength) {
      return UsernameAvailabilityStatus.none;
    }

    await Future.delayed(const Duration(milliseconds: 300));

    // Deterministic test trigger for network/repository failure
    if (clean == 'error_check' || clean == 'net_err') {
      throw Exception('Simulated network error checking username.');
    }

    if (_reservedUsernames.contains(clean) ||
        _accounts.values.any((u) => u.username == clean)) {
      return UsernameAvailabilityStatus.taken;
    }
    return UsernameAvailabilityStatus.available;
  }

  @override
  Future<bool> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final normalizedUsername = usernameConfig.normalize(username);
    final normalizedEmail = email.trim().toLowerCase();

    if (_userRegisteredEmails.contains(normalizedEmail) ||
        _accounts.containsKey(normalizedEmail) ||
        _accounts.values.any((u) => u.username.toLowerCase() == normalizedUsername)) {
      return false;
    }

    _userRegisteredEmails.add(normalizedEmail);
    _accounts[normalizedEmail] = MockUserRecord(
      username: normalizedUsername,
      email: normalizedEmail,
      password: password,
      isEmailVerified: false,
      isFaceVerified: false,
      isDocVerified: false,
    );
    await _savePersistedAccounts();
    return true;
  }

  @override
  Future<bool> loginUser({
    required String identifier,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final record = _findByIdentifier(identifier);
    if (record != null) {
      return record.password == password;
    }
    // Reject unregistered credentials when identifier looks invalid, or allow
    // only explicitly registered mock users. If someone signs up first or uses
    // one of the seeded demo accounts, record is found cleanly.
    return false;
  }

  @override
  Future<AuthUserState?> getAccountVerificationState(String identifier) async {
    final record = _findByIdentifier(identifier);
    if (record == null) return null;
    return AuthUserState(
      username: record.username,
      email: record.email,
      isAuthenticated: true,
      isEmailVerified: record.isEmailVerified,
      isFaceVerified: record.isFaceVerified,
      isDocVerified: record.isDocVerified,
      faceProofId: record.faceProofId,
      docProofId: record.docProofId,
      faceVerificationStatus: record.isFaceVerified
          ? FaceVerificationStatus.verified
          : FaceVerificationStatus.pending,
      docVerificationStatus:
          record.isDocVerified ? GovIdStatus.verified : GovIdStatus.notStarted,
    );
  }

  @override
  Future<EmailOtpStatus> sendVerificationOtp(String email) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final clean = email.trim().toLowerCase();
    if (clean.startsWith('fail')) {
      return EmailOtpStatus.deliveryFailed;
    }
    if (clean.startsWith('offline')) {
      return EmailOtpStatus.serviceUnavailable;
    }
    await _issueOtp(clean, isPasswordReset: false);
    return EmailOtpStatus.waiting;
  }

  @override
  Future<EmailOtpStatus> updateUnverifiedEmail({
    required String currentEmail,
    required String updatedEmail,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final oldKey = currentEmail.trim().toLowerCase();
    final newKey = updatedEmail.trim().toLowerCase();
    if (newKey.startsWith('fail')) {
      return EmailOtpStatus.deliveryFailed;
    }
    final existing = _accounts.remove(oldKey);
    if (existing != null) {
      _userRegisteredEmails.remove(oldKey);
      _userRegisteredEmails.add(newKey);
      _accounts[newKey] = existing.copyWith(
        email: newKey,
        isEmailVerified: false,
      );
      await _savePersistedAccounts();
    }
    _otps.remove(_otpKey(oldKey, false));
    await _issueOtp(newKey, isPasswordReset: false);
    return EmailOtpStatus.waiting;
  }

  EmailOtpStatus _validateOtpRecord({
    required String cleanEmail,
    required String enteredOtp,
    required bool isPasswordReset,
  }) {
    if (enteredOtp == '000000') {
      return EmailOtpStatus.expiredOtp;
    }
    if (enteredOtp == '888888') {
      return EmailOtpStatus.serviceUnavailable;
    }
    if (enteredOtp == '999999') {
      return EmailOtpStatus.deliveryFailed;
    }

    final active = _otps[_otpKey(cleanEmail, isPasswordReset)];
    if (active == null) {
      return EmailOtpStatus.invalidOtp;
    }
    if (active.isExpiredAt(_clock())) {
      return EmailOtpStatus.expiredOtp;
    }
    if (enteredOtp.trim() != active.code) {
      return EmailOtpStatus.invalidOtp;
    }
    return EmailOtpStatus.success;
  }

  @override
  Future<EmailOtpStatus> verifyEmailOtp(
    String email,
    String enteredOtp,
  ) async {
    await Future.delayed(const Duration(milliseconds: 450));
    final clean = email.trim().toLowerCase();
    final status = _validateOtpRecord(
      cleanEmail: clean,
      enteredOtp: enteredOtp,
      isPasswordReset: false,
    );
    if (status == EmailOtpStatus.success) {
      _otps.remove(_otpKey(clean, false));
      await _savePersistedOtps();
      final existing = _accounts[clean];
      if (existing != null) {
        _accounts[clean] = existing.copyWith(isEmailVerified: true);
        await _savePersistedAccounts();
      }
    }
    return status;
  }

  @override
  Future<bool> sendPasswordResetOtp(String email) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final clean = email.trim().toLowerCase();
    if (clean.startsWith('fail') || clean.startsWith('unknown')) {
      return false;
    }
    await _issueOtp(clean, isPasswordReset: true);
    return true;
  }

  @override
  Future<EmailOtpStatus> verifyPasswordResetOtp(
    String email,
    String enteredOtp,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final clean = email.trim().toLowerCase();
    final status = _validateOtpRecord(
      cleanEmail: clean,
      enteredOtp: enteredOtp,
      isPasswordReset: true,
    );
    if (status == EmailOtpStatus.success) {
      _otps.remove(_otpKey(clean, true));
      await _savePersistedOtps();
    }
    return status;
  }

  @override
  DemoOtpSnapshot? getDemoOtpSnapshot(
    String email, {
    bool isPasswordReset = false,
  }) {
    return _otps[_otpKey(email, isPasswordReset)];
  }

  @override
  Future<void> expireDemoOtpForTesting(
    String email, {
    bool isPasswordReset = false,
  }) async {
    final key = _otpKey(email, isPasswordReset);
    final active = _otps[key];
    if (active == null) return;
    _otps[key] = DemoOtpSnapshot(
      code: active.code,
      expiresAt: _clock().subtract(const Duration(seconds: 1)),
      isPasswordReset: isPasswordReset,
    );
    await _savePersistedOtps();
  }

  @override
  Future<bool> resetPassword(String email, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 450));
    final clean = email.trim().toLowerCase();
    final existing = _findByIdentifier(clean);
    if (existing != null) {
      _accounts[existing.email] = existing.copyWith(password: newPassword);
      await _savePersistedAccounts();
    }
    return true;
  }

  @override
  Future<void> updateAccountVerificationFlags({
    required String email,
    bool? isEmailVerified,
    bool? isFaceVerified,
    bool? isDocVerified,
    String? faceProofId,
    String? docProofId,
  }) async {
    final clean = email.trim().toLowerCase();
    final existing = _accounts[clean];
    if (existing != null) {
      _accounts[clean] = existing.copyWith(
        isEmailVerified: isEmailVerified,
        isFaceVerified: isFaceVerified,
        isDocVerified: isDocVerified,
        faceProofId: faceProofId,
        docProofId: docProofId,
      );
      await _savePersistedAccounts();
    }
  }
}
