import 'package:equatable/equatable.dart';

import 'chat_user.dart';
import 'socket_payload_normalizer.dart';

enum MessageDeliveryStatus { sending, sent, seen, failed }

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.clientTempId,
    this.content,
    this.text,
    this.mediaUrl,
    this.deletedAt,
    this.status = MessageDeliveryStatus.sent,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final normalizedJson = coerceSocketPayloadMap(json) ?? json;
    final senderJson = coerceSocketPayloadMap(normalizedJson['sender']);
    final content = normalizedJson['content'] as String? ??
        normalizedJson['text'] as String? ??
        '';

    return ChatMessage(
      id: normalizedJson['id'] as String,
      clientTempId: normalizedJson['clientTempId'] as String?,
      conversationId: normalizedJson['conversationId'] as String,
      sender: ChatUser.fromJson(senderJson ?? const <String, dynamic>{}),
      type: normalizedJson['type'] as String? ?? 'text',
      content: content,
      text: normalizedJson['text'] as String?,
      mediaUrl: normalizedJson['mediaUrl'] as String?,
      deletedAt: normalizedJson['deletedAt'] == null
          ? null
          : DateTime.parse(normalizedJson['deletedAt'] as String),
      createdAt: DateTime.parse(normalizedJson['createdAt'] as String),
      updatedAt: DateTime.parse(normalizedJson['updatedAt'] as String),
    );
  }

  final String id;
  final String? clientTempId;
  final String conversationId;
  final ChatUser sender;
  final String type;
  final String? content;
  final String? text;
  final String? mediaUrl;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MessageDeliveryStatus status;

  String get displayContent => content ?? text ?? '';

  ChatMessage copyWith({
    String? id,
    String? clientTempId,
    String? conversationId,
    ChatUser? sender,
    String? type,
    String? content,
    String? text,
    String? mediaUrl,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    MessageDeliveryStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      clientTempId: clientTempId ?? this.clientTempId,
      conversationId: conversationId ?? this.conversationId,
      sender: sender ?? this.sender,
      type: type ?? this.type,
      content: content ?? this.content,
      text: text ?? this.text,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    id,
    clientTempId,
    conversationId,
    sender,
    type,
    content,
    text,
    mediaUrl,
    deletedAt,
    createdAt,
    updatedAt,
    status,
  ];
}
