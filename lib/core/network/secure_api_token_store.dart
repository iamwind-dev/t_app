import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_token_store.dart';

class SecureApiTokenStore implements ApiTokenStore {
  const SecureApiTokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'accessToken';

  final FlutterSecureStorage _storage;

  @override
  Future<void> clearToken() {
    return _storage.delete(key: _accessTokenKey);
  }

  @override
  Future<String?> readToken() {
    return _storage.read(key: _accessTokenKey);
  }

  @override
  Future<void> writeToken(String token) {
    return _storage.write(key: _accessTokenKey, value: token);
  }
}
