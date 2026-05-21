import 'package:equatable/equatable.dart';
import 'package:t_app/core/network/backend_url_normalizer.dart';

class ChatUser extends Equatable {
  const ChatUser({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    final rawAvatarUrl =
        json['avatarUrl'] ?? json['avatar_url'] ?? json['avatar'];

    return ChatUser(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String? ?? json['username'] as String,
      avatarUrl: BackendUrlNormalizer.normalizeNullable(
        rawAvatarUrl as String?,
      ),
    );
  }

  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;

  @override
  List<Object?> get props => [id, username, displayName, avatarUrl];
}