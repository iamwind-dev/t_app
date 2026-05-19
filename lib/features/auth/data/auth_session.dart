import 'package:equatable/equatable.dart';

import 'auth_user.dart';

class AuthSession extends Equatable {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    if (userJson is! Map<String, dynamic>) {
      throw const FormatException('Login response missing user.');
    }

    final accessToken = json['accessToken'];
    if (accessToken is! String || accessToken.isEmpty) {
      throw const FormatException('Login response missing accessToken.');
    }

    final refreshToken = json['refreshToken'];
    if (refreshToken is! String || refreshToken.isEmpty) {
      throw const FormatException('Login response missing refreshToken.');
    }

    return AuthSession(
      user: AuthUser.fromJson(userJson),
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  final AuthUser user;
  final String accessToken;
  final String refreshToken;

  @override
  List<Object?> get props => [user, accessToken, refreshToken];
}
