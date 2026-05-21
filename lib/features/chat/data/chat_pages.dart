import 'chat_conversation.dart';
import 'chat_message.dart';

class ChatPageInfo {
  const ChatPageInfo({required this.nextCursor, required this.hasNextPage});

  factory ChatPageInfo.fromJson(Map<String, dynamic> json) {
    return ChatPageInfo(
      nextCursor: json['nextCursor'] as String?,
      hasNextPage: (json['hasNextPage'] ?? json['hasMore']) as bool? ?? false,
    );
  }

  final String? nextCursor;
  final bool hasNextPage;
}

class ConversationPage {
  const ConversationPage({required this.items, required this.pageInfo});

  factory ConversationPage.fromJson(Map<String, dynamic> json) {
    return ConversationPage(
      items: (json['items'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ChatConversation.fromJson)
          .toList(growable: false),
      pageInfo: json['pageInfo'] is Map<String, dynamic>
          ? ChatPageInfo.fromJson(json['pageInfo'] as Map<String, dynamic>)
          : ChatPageInfo.fromJson(json),
    );
  }

  final List<ChatConversation> items;
  final ChatPageInfo pageInfo;
}

class MessagePage {
  const MessagePage({required this.items, required this.pageInfo});

  factory MessagePage.fromJson(Map<String, dynamic> json) {
    return MessagePage(
      items: (json['items'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ChatMessage.fromJson)
          .toList(growable: false),
      pageInfo: json['pageInfo'] is Map<String, dynamic>
          ? ChatPageInfo.fromJson(json['pageInfo'] as Map<String, dynamic>)
          : ChatPageInfo.fromJson(json),
    );
  }

  final List<ChatMessage> items;
  final ChatPageInfo pageInfo;
}
