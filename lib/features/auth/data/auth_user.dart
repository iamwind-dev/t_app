import 'package:equatable/equatable.dart';
import 'package:t_app/core/network/backend_url_normalizer.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    this.avatarUrl,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final rawAvatarUrl =
        json['avatarUrl'] ?? json['avatar_url'] ?? json['avatar'];

    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      username: json['username'] as String,
      displayName: json['displayName'] as String? ?? json['username'] as String,
      avatarUrl: BackendUrlNormalizer.normalizeNullable(
        rawAvatarUrl as String?,
      ),
    );
  }

  final String id;
  final String email;
  final String username;
  final String displayName;
  final String? avatarUrl;

  @override
  List<Object?> get props => [id, email, username, displayName, avatarUrl];
}