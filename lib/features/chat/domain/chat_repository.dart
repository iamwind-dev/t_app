import '../data/chat_conversation.dart';
import '../data/chat_message.dart';
import '../data/chat_pages.dart';

abstract interface class ChatRepository {
  Future<ConversationPage> listConversations({String? cursor});

  Future<ChatConversation> createDirectConversation(String userId);

  Future<MessagePage> getMessages(String conversationId, {String? cursor});

  Future<ChatMessage> sendTextMessage({
    required String conversationId,
    required String text,
  });
}
