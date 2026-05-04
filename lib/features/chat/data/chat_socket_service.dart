import 'dart:async';

import 'chat_message.dart';

enum ChatConnectionStatus { disconnected, connecting, connected }

abstract interface class ChatSocketService {
  Stream<ChatConnectionStatus> get connectionStatus;

  Stream<ChatTypingEvent> get typingStarted;

  Stream<ChatTypingEvent> get typingStopped;

  Stream<ChatMessageEvent> get messageReceived;

  Stream<ChatMessageSentEvent> get messageSent;

  Stream<ChatMessageFailedEvent> get messageFailed;

  Stream<ChatMessageSeenEvent> get messageSeen;

  Future<void> connect();

  Future<void> disconnect();

  Future<void> joinConversation(String conversationId);

  Future<void> leaveConversation(String conversationId);

  Future<void> typingStart(String conversationId);

  Future<void> typingStop(String conversationId);

  Future<void> sendMessage({
    required String conversationId,
    required String clientTempId,
    required String content,
    String type = 'text',
    String? mediaUrl,
  });

  Future<void> markSeen({
    required String conversationId,
    required String messageId,
  });
}

class ChatTypingEvent {
  const ChatTypingEvent({
    required this.conversationId,
    required this.userId,
    this.username,
  });

  final String conversationId;
  final String userId;
  final String? username;
}

class ChatMessageEvent {
  const ChatMessageEvent({required this.conversationId, required this.message});

  final String conversationId;
  final ChatMessage message;
}

class ChatMessageSentEvent {
  const ChatMessageSentEvent({
    required this.clientTempId,
    required this.message,
  });

  final String clientTempId;
  final ChatMessage message;
}

class ChatMessageFailedEvent {
  const ChatMessageFailedEvent({
    required this.conversationId,
    required this.clientTempId,
    required this.message,
  });

  final String conversationId;
  final String clientTempId;
  final String message;
}

class ChatMessageSeenEvent {
  const ChatMessageSeenEvent({
    required this.conversationId,
    required this.userId,
    required this.messageId,
    required this.seenAt,
  });

  final String conversationId;
  final String userId;
  final String messageId;
  final DateTime seenAt;
}
