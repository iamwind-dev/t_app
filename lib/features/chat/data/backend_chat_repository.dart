import 'package:t_app/core/network/api_client.dart';
import 'package:t_app/features/chat/domain/chat_repository.dart';

import 'chat_conversation.dart';
import 'chat_message.dart';
import 'chat_pages.dart';
import 'chat_realtime_client.dart';

class BackendChatRepository implements ChatRepository {
  const BackendChatRepository({
    required ApiClient apiClient,
    ChatRealtimeClient? realtimeClient,
  }) : _apiClient = apiClient,
       _realtimeClient = realtimeClient;

  final ApiClient _apiClient;
  final ChatRealtimeClient? _realtimeClient;

  @override
  Future<ConversationPage> listConversations({String? cursor}) {
    return _apiClient.get<ConversationPage>(
      '/conversations',
      queryParameters: {'limit': 20, if (cursor != null) 'cursor': cursor},
      decode: (value) => ConversationPage.fromJson(_asMap(value)),
    );
  }

  @override
  Future<ChatConversation> createDirectConversation(String userId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/conversations/direct/$userId',
      decode: _asMap,
    );

    return ChatConversation.fromJson(_readObject(response, 'conversation'));
  }

  @override
  Future<MessagePage> getMessages(String conversationId, {String? cursor}) {
    return _apiClient.get<MessagePage>(
      '/conversations/$conversationId/messages',
      queryParameters: {'limit': 30, if (cursor != null) 'cursor': cursor},
      decode: (value) => MessagePage.fromJson(_asMap(value)),
    );
  }

  @override
  Future<ChatMessage> sendTextMessage({
    required String conversationId,
    required String text,
  }) async {
    final realtimeClient = _realtimeClient;
    if (realtimeClient != null) {
      try {
        await realtimeClient.joinConversation(conversationId);
        final result = await realtimeClient.sendTextMessage(
          conversationId: conversationId,
          text: text,
          clientMessageId: 'flutter-${DateTime.now().microsecondsSinceEpoch}',
        );

        return ChatMessage.fromJson(Map<String, dynamic>.from(result.message));
      } catch (_) {
        // Fall through to REST so sending still works when realtime is blocked.
      }
    }

    final response = await _apiClient.post<Map<String, dynamic>>(
      '/conversations/$conversationId/messages',
      data: {'text': text},
      decode: _asMap,
    );

    return ChatMessage.fromJson(_readObject(response, 'message'));
  }

  static Map<String, dynamic> _readObject(
    Map<String, dynamic> response,
    String key,
  ) {
    final value = response[key];
    if (value is Map<String, dynamic>) {
      return value;
    }

    throw FormatException('Phản hồi thiếu trường $key.');
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    throw const FormatException('Cần một đối tượng JSON.');
  }
}
