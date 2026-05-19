import 'package:equatable/equatable.dart';

import 'auth_user.dart';

class AuthSession extends Equatable {
  const AuthSession({required this.user, required this.accessToken});

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    if (userJson is! Map<String, dynamic>) {
      throw const FormatException('Phản hồi đăng nhập thiếu trường user.');
    }

    final accessToken = json['accessToken'];
    if (accessToken is! String || accessToken.isEmpty) {
      throw const FormatException('Phản hồi đăng nhập thiếu accessToken.');
    }

    return AuthSession(
      user: AuthUser.fromJson(userJson),
      accessToken: accessToken,
    );
  }

  final AuthUser user;
  final String accessToken;

  @override
  List<Object?> get props => [user, accessToken];
}
