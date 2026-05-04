import 'package:equatable/equatable.dart';

import 'chat_message.dart';
import 'chat_user.dart';

class ChatConversation extends Equatable {
  const ChatConversation({
    required this.id,
    required this.type,
    required this.members,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    final membersJson = json['members'];
    return ChatConversation(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'direct',
      members: membersJson is List
          ? membersJson
                .whereType<Map<String, dynamic>>()
                .map(ChatConversationMember.fromJson)
                .toList(growable: false)
          : const [],
      lastMessage: json['lastMessage'] is Map<String, dynamic>
          ? ChatMessage.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  final String id;
  final String type;
  final List<ChatConversationMember> members;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatConversationMember? otherMember(String currentUserId) {
    for (final member in members) {
      if (member.user.id != currentUserId) {
        return member;
      }
    }

    return members.isEmpty ? null : members.first;
  }

  @override
  List<Object?> get props => [
    id,
    type,
    members,
    lastMessage,
    unreadCount,
    createdAt,
    updatedAt,
  ];
}

class ChatConversationMember extends Equatable {
  const ChatConversationMember({
    required this.user,
    required this.joinedAt,
    this.lastSeenMessageId,
    this.lastSeenAt,
  });

  factory ChatConversationMember.fromJson(Map<String, dynamic> json) {
    return ChatConversationMember(
      user: ChatUser.fromJson(json['user'] as Map<String, dynamic>),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      lastSeenMessageId: json['lastSeenMessageId'] as String?,
      lastSeenAt: json['lastSeenAt'] is String
          ? DateTime.parse(json['lastSeenAt'] as String)
          : null,
    );
  }

  final ChatUser user;
  final DateTime joinedAt;
  final String? lastSeenMessageId;
  final DateTime? lastSeenAt;

  @override
  List<Object?> get props => [user, joinedAt, lastSeenMessageId, lastSeenAt];
}
