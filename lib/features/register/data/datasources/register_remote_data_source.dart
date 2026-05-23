import 'package:t_app/core/network/api_client.dart';
import 'package:t_app/core/network/api_token_store.dart';

import '../../../auth/data/auth_session.dart';
import '../../domain/entities/register_user.dart';

abstract class RegisterRemoteDataSource {
  Future<AuthSession> register(RegisterUserEntity user);
}

class RegisterRemoteDataSourceImpl implements RegisterRemoteDataSource {
  const RegisterRemoteDataSourceImpl({
    required ApiClient apiClient,
    required ApiTokenStore tokenStore,
  }) : _apiClient = apiClient,
       _tokenStore = tokenStore;

  final ApiClient _apiClient;
  final ApiTokenStore _tokenStore;

  @override
  Future<AuthSession> register(RegisterUserEntity user) async {
    final session = await _apiClient.post<AuthSession>(
      '/auth/register',
      data: {
        'email': user.email.trim(),
        'username': user.username.trim(),
        'password': user.password,
        'displayName': user.fullName.trim(),
      },
      decode: (value) => AuthSession.fromJson(_asMap(value)),
    );

    await _tokenStore.writeToken(session.accessToken);
    await _tokenStore.writeRefreshToken(session.refreshToken);

    return session;
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    throw const FormatException('Expected a JSON object.');
  }
}
