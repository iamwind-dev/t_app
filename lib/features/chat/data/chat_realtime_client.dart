abstract interface class ChatRealtimeClient {
  Future<void> connect();

  Future<void> disconnect();

  Future<void> joinConversation(String conversationId);

  Future<ChatMessageSendResult> sendTextMessage({
    required String conversationId,
    required String text,
    String? clientMessageId,
  });
}

class ChatMessageSendResult {
  const ChatMessageSendResult({
    required this.message,
    this.clientMessageId,
  });

  final String? clientMessageId;
  final Map<String, Object?> message;
}
