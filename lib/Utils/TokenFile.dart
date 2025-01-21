import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenManager {
  final _storage = const FlutterSecureStorage();

  // Keys for storage
  static const String _keyAccessToken = 'accessToken';
  static const String _keyRefreshToken = 'refreshToken';

  /// Save tokens securely
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  /// Read access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  /// Read refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  /// Update access token
  Future<void> updateAccessToken(String newAccessToken) async {
    await _storage.write(key: _keyAccessToken, value: newAccessToken);
  }

  /// Update refresh token
  Future<void> updateRefreshToken(String newRefreshToken) async {
    await _storage.write(key: _keyRefreshToken, value: newRefreshToken);
  }

  /// Delete tokens (e.g., on logout)
  Future<void> clearTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
  }
}
