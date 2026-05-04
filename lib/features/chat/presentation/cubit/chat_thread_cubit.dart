import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/core/network/api_exception.dart';
import 'package:t_app/features/chat/data/chat_conversation.dart';
import 'package:t_app/features/chat/data/chat_message.dart';
import 'package:t_app/features/chat/data/chat_socket_service.dart';
import 'package:t_app/features/chat/data/chat_user.dart';
import 'package:t_app/features/chat/domain/chat_repository.dart';

import 'chat_thread_state.dart';

class ChatThreadCubit extends Cubit<ChatThreadState> {
  ChatThreadCubit({
    required ChatRepository repository,
    required ChatConversation conversation,
    required String currentUserId,
    ChatSocketService? socketService,
  }) : _repository = repository,
       _socketService = socketService,
       super(
         ChatThreadState(
           conversation: conversation,
           currentUserId: currentUserId,
         ),
       );

  final ChatRepository _repository;
  final ChatSocketService? _socketService;
  final List<StreamSubscription<Object?>> _socketSubscriptions = [];
  final Map<String, Timer> _typingExpiryTimers = {};

  ChatSocketService? get socketService => _socketService;

  Future<void> loadMessages() async {
    emit(state.copyWith(status: ChatThreadStatus.loading, clearError: true));

    try {
      final page = await _repository.getMessages(state.conversation.id);
      emit(
        state.copyWith(
          status: ChatThreadStatus.loaded,
          messages: page.items
              .map(
                (message) => message.copyWith(status: _messageStatus(message)),
              )
              .toList(),
          clearError: true,
        ),
      );
      await _markLatestIncomingSeen();
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          status: ChatThreadStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ChatThreadStatus.failure,
          errorMessage: 'Unable to load messages.',
        ),
      );
    }
  }

  Future<void> sendMessage(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty) {
      return;
    }

    final socketService = _socketService;
    if (socketService != null) {
      final clientTempId = 'flutter-${DateTime.now().microsecondsSinceEpoch}';
      final optimisticMessage = ChatMessage(
        id: clientTempId,
        clientTempId: clientTempId,
        conversationId: state.conversation.id,
        sender: ChatUser(
          id: state.currentUserId,
          username: 'me',
          displayName: 'Me',
        ),
        type: 'text',
        content: text,
        text: text,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        status: MessageDeliveryStatus.sending,
      );

      emit(
        state.copyWith(
          status: ChatThreadStatus.loaded,
          messages: [optimisticMessage, ...state.messages],
          clearError: true,
        ),
      );

      try {
        await socketService.sendMessage(
          conversationId: state.conversation.id,
          clientTempId: clientTempId,
          content: text,
        );
      } catch (_) {
        _markMessageFailed(clientTempId);
      }
      return;
    }

    try {
      final message = await _repository.sendTextMessage(
        conversationId: state.conversation.id,
        text: text,
      );
      emit(
        state.copyWith(
          status: ChatThreadStatus.loaded,
          messages: [
            message.copyWith(status: MessageDeliveryStatus.sent),
            ...state.messages,
          ],
          clearError: true,
        ),
      );
    } on ApiException catch (error) {
      emit(state.copyWith(errorMessage: error.message));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Unable to send message.'));
    }
  }

  Future<void> joinRealtime() async {
    final socketService = _socketService;
    if (socketService == null) {
      return;
    }

    attachSocketListeners();
    await socketService.connect();
    await socketService.joinConversation(state.conversation.id);
    await _markLatestIncomingSeen();
  }

  Future<void> leaveRealtime() async {
    final socketService = _socketService;
    if (socketService == null) {
      return;
    }

    await socketService.typingStop(state.conversation.id);
    await socketService.leaveConversation(state.conversation.id);
  }

  void attachSocketListeners() {
    final socketService = _socketService;
    if (socketService == null || _socketSubscriptions.isNotEmpty) {
      return;
    }

    _socketSubscriptions
      ..add(socketService.connectionStatus.listen(_handleConnectionStatus))
      ..add(socketService.typingStarted.listen(_handleTypingStarted))
      ..add(socketService.typingStopped.listen(_handleTypingStopped))
      ..add(socketService.messageReceived.listen(_handleMessageReceived))
      ..add(socketService.messageSent.listen(_handleMessageSent))
      ..add(socketService.messageFailed.listen(_handleMessageFailed))
      ..add(socketService.messageSeen.listen(_handleMessageSeen));
  }

  Future<void> typingStart() async {
    await _socketService?.typingStart(state.conversation.id);
  }

  Future<void> typingStop() async {
    await _socketService?.typingStop(state.conversation.id);
  }

  void _handleConnectionStatus(ChatConnectionStatus status) {
    emit(state.copyWith(connectionStatus: status));
  }

  void _handleTypingStarted(ChatTypingEvent event) {
    if (event.conversationId != state.conversation.id ||
        event.userId == state.currentUserId) {
      return;
    }

    emit(
      state.copyWith(
        typingUsers: {
          ...state.typingUsers,
          event.userId: event.username ?? event.userId,
        },
      ),
    );
    _typingExpiryTimers[event.userId]?.cancel();
    _typingExpiryTimers[event.userId] = Timer(
      const Duration(seconds: 3),
      () => _removeTypingUser(event.userId),
    );
  }

  void _handleTypingStopped(ChatTypingEvent event) {
    if (event.conversationId != state.conversation.id) {
      return;
    }

    _removeTypingUser(event.userId);
  }

  void _removeTypingUser(String userId) {
    final typingUsers = Map<String, String>.from(state.typingUsers)
      ..remove(userId);
    _typingExpiryTimers.remove(userId)?.cancel();
    emit(state.copyWith(typingUsers: typingUsers));
  }

  Future<void> _handleMessageReceived(ChatMessageEvent event) async {
    if (event.conversationId != state.conversation.id ||
        _containsMessage(event.message)) {
      return;
    }

    emit(
      state.copyWith(
        messages: [
          event.message.copyWith(status: _messageStatus(event.message)),
          ...state.messages,
        ],
      ),
    );

    if (event.message.sender.id != state.currentUserId) {
      await _socketService?.markSeen(
        conversationId: state.conversation.id,
        messageId: event.message.id,
      );
    }
  }

  void _handleMessageSent(ChatMessageSentEvent event) {
    final messages = state.messages.map((message) {
      if (message.clientTempId == event.clientTempId ||
          message.id == event.clientTempId) {
        return event.message.copyWith(status: MessageDeliveryStatus.sent);
      }
      return message;
    }).toList();
    emit(state.copyWith(messages: _dedupeMessages(messages)));
  }

  void _handleMessageFailed(ChatMessageFailedEvent event) {
    _markMessageFailed(event.clientTempId);
  }

  void _handleMessageSeen(ChatMessageSeenEvent event) {
    if (event.conversationId != state.conversation.id ||
        event.userId == state.currentUserId) {
      return;
    }

    final messages = state.messages.map((message) {
      if (message.id == event.messageId &&
          message.sender.id == state.currentUserId) {
        return message.copyWith(status: MessageDeliveryStatus.seen);
      }
      return message;
    }).toList();
    emit(state.copyWith(messages: messages));
  }

  void _markMessageFailed(String clientTempId) {
    final messages = state.messages.map((message) {
      if (message.clientTempId == clientTempId || message.id == clientTempId) {
        return message.copyWith(status: MessageDeliveryStatus.failed);
      }
      return message;
    }).toList();
    emit(state.copyWith(messages: messages));
  }

  MessageDeliveryStatus _messageStatus(ChatMessage message) {
    return message.sender.id == state.currentUserId
        ? MessageDeliveryStatus.sent
        : message.status;
  }

  bool _containsMessage(ChatMessage message) {
    return state.messages.any(
      (existing) =>
          existing.id == message.id ||
          (message.clientTempId != null &&
              existing.clientTempId == message.clientTempId),
    );
  }

  List<ChatMessage> _dedupeMessages(List<ChatMessage> messages) {
    final seen = <String>{};
    final deduped = <ChatMessage>[];
    for (final message in messages) {
      final key = message.clientTempId ?? message.id;
      if (seen.add(key)) {
        deduped.add(message);
      }
    }
    return deduped;
  }

  Future<void> _markLatestIncomingSeen() async {
    ChatMessage? latestIncoming;
    for (final message in state.messages) {
      if (message.sender.id != state.currentUserId) {
        latestIncoming = message;
        break;
      }
    }
    if (latestIncoming == null) {
      return;
    }

    await _socketService?.markSeen(
      conversationId: state.conversation.id,
      messageId: latestIncoming.id,
    );
  }

  @override
  Future<void> close() async {
    for (final subscription in _socketSubscriptions) {
      await subscription.cancel();
    }
    for (final timer in _typingExpiryTimers.values) {
      timer.cancel();
    }
    return super.close();
  }
}
