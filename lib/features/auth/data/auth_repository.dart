import 'package:t_app/core/network/api_client.dart';
import 'package:t_app/core/network/api_exception.dart';
import 'package:t_app/core/network/api_token_store.dart';
import 'package:t_app/features/auth/domain/auth_session_repository.dart';

import 'auth_session.dart';
import 'auth_user.dart';

class AuthRepository implements AuthSessionRepository {
  const AuthRepository({
    required ApiClient apiClient,
    required ApiTokenStore tokenStore,
  }) : _apiClient = apiClient,
       _tokenStore = tokenStore;

  final ApiClient _apiClient;
  final ApiTokenStore _tokenStore;

  @override
  Future<AuthSession> login({
    required String identifier,
    required String password,
  }) async {
    final session = await _apiClient.post<AuthSession>(
      '/auth/login',
      data: {'identifier': identifier.trim(), 'password': password},
      decode: (value) => AuthSession.fromJson(_asMap(value)),
    );

    await _persistSession(session);
    return session;
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String username,
    required String password,
    required String displayName,
  }) async {
    final session = await _apiClient.post<AuthSession>(
      '/auth/register',
      data: {
        'email': email.trim(),
        'username': username.trim(),
        'password': password,
        'displayName': displayName.trim(),
      },
      decode: (value) => AuthSession.fromJson(_asMap(value)),
    );

    await _persistSession(session);
    return session;
  }

  @override
  Future<AuthUser?> loadCurrentUser() async {
    final token = await _tokenStore.readToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/auth/me',
        decode: _asMap,
      );
      final userJson = response['user'];
      if (userJson is! Map<String, dynamic>) {
        throw const FormatException('Current-user response missing user.');
      }

      return AuthUser.fromJson(userJson);
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        await _tokenStore.clearToken();
        return null;
      }

      rethrow;
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.post<Map<String, dynamic>>(
      '/auth/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      decode: _asMap,
    );
    await _tokenStore.clearToken();
  }

  @override
  Future<void> logOut() async {
    final refreshToken = await _tokenStore.readRefreshToken();
    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _apiClient.post<Map<String, dynamic>>(
          '/auth/logout',
          data: {'refreshToken': refreshToken},
          decode: _asMap,
        );
      }
    } finally {
      await _tokenStore.clearToken();
    }
  }

  Future<void> _persistSession(AuthSession session) async {
    await _tokenStore.writeToken(session.accessToken);
    await _tokenStore.writeRefreshToken(session.refreshToken);
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    throw const FormatException('Expected a JSON object.');
  }
}
