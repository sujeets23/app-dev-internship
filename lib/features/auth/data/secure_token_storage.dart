import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted OS token storage contract targeting iOS Keychain and Android Keystore
/// as specified in Feature 1 (Login Page & Mail Verification).
///
/// In this frontend-only stage, no real backend access/refresh JWTs are issued.
abstract class ISecureTokenStorage {
  bool get isHardwareEncryptedStorageAvailable;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> clearTokens();
}

/// Production implementation backed by `flutter_secure_storage` (Keychain / Keystore).
class FlutterSecureTokenStorage implements ISecureTokenStorage {
  static const String _accessTokenKey = 'date2_access_token';
  static const String _refreshTokenKey = 'date2_refresh_token';

  final FlutterSecureStorage _storage;

  const FlutterSecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  @override
  bool get isHardwareEncryptedStorageAvailable => true;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  @override
  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}

/// Frontend boundary adapter used during mock/demo authentication.
/// Explicitly avoids fabricating fake JWT access or refresh tokens.
class MockAuthSessionBoundary implements ISecureTokenStorage {
  String? _inMemoryDevSessionMarker;

  @override
  bool get isHardwareEncryptedStorageAvailable => false;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    throw UnsupportedError(
      'Real JWT tokens are only issued by the backend (/v1/auth/login). '
      'Mock mode does not fabricate production tokens.',
    );
  }

  void markDevSessionActive(String sessionMarker) {
    _inMemoryDevSessionMarker = sessionMarker;
  }

  String? get devSessionMarker => _inMemoryDevSessionMarker;

  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<String?> readRefreshToken() async => null;

  @override
  Future<void> clearTokens() async {
    _inMemoryDevSessionMarker = null;
  }
}

/// Session lifecycle and silent token refresh contract ready for backend integration.
abstract class IAuthSessionManager {
  Future<bool> hasActiveSession();

  /// Production endpoint boundary: POST /v1/auth/refresh
  Future<void> silentRefreshToken();

  Future<void> clearSession();
}

class ProductionAuthSessionManager implements IAuthSessionManager {
  final ISecureTokenStorage tokenStorage;

  ProductionAuthSessionManager({required this.tokenStorage});

  @override
  Future<bool> hasActiveSession() async {
    final token = await tokenStorage.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> silentRefreshToken() async {
    final refresh = await tokenStorage.readRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      throw StateError('No refresh token stored in encrypted OS storage.');
    }
    throw UnimplementedError(
      'Silent token refresh requires backend endpoint POST /v1/auth/refresh.',
    );
  }

  @override
  Future<void> clearSession() => tokenStorage.clearTokens();
}
