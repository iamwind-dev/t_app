import 'package:equatable/equatable.dart';
import 'package:t_app/core/network/backend_url_normalizer.dart';

import 'socket_payload_normalizer.dart';

class ChatUser extends Equatable {
  const ChatUser({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    final normalizedJson = coerceSocketPayloadMap(json) ?? json;
    final rawAvatarUrl =
        normalizedJson['avatarUrl'] ??
        normalizedJson['avatar_url'] ??
        normalizedJson['avatar'];

    return ChatUser(
      id: normalizedJson['id'] as String,
      username: normalizedJson['username'] as String,
      displayName: normalizedJson['displayName'] as String? ??
          normalizedJson['username'] as String,
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
