import 'package:equatable/equatable.dart';

import 'chat_user.dart';

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
    final content = json['content'] as String? ?? json['text'] as String? ?? '';

    return ChatMessage(
      id: json['id'] as String,
      clientTempId: json['clientTempId'] as String?,
      conversationId: json['conversationId'] as String,
      sender: ChatUser.fromJson(json['sender'] as Map<String, dynamic>),
      type: json['type'] as String? ?? 'text',
      content: content,
      text: json['text'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
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
