import '../data/chat_conversation.dart';
import '../data/chat_message.dart';
import '../data/chat_pages.dart';
import '../data/chat_seen_result.dart';
import '../data/deleted_message_result.dart';

abstract interface class ChatRepository {
  Future<ConversationPage> listConversations({String? cursor});

  Future<ChatConversation> createDirectConversation(String userId);

  Future<MessagePage> getMessages(String conversationId, {String? cursor});

  Future<ChatMessage> sendTextMessage({
    required String conversationId,
    required String text,
  });

  Future<ChatSeenResult> markSeen({
    required String conversationId,
    required String messageId,
  });

  Future<DeletedMessageResult> deleteMessage({
    required String conversationId,
    required String messageId,
  });
}
