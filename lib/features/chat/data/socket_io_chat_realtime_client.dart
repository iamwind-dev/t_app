import 'dart:async';
import 'dart:developer' as developer;

import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:t_app/core/network/api_exception.dart';
import 'package:t_app/core/network/api_token_store.dart';

import 'chat_message.dart';
import 'chat_realtime_client.dart';
import 'chat_socket_service.dart';

typedef SocketDebugLog = void Function(String message);

class SocketIoChatRealtimeClient
    implements ChatRealtimeClient, ChatSocketService {
  SocketIoChatRealtimeClient({
    required String baseUrl,
    required ApiTokenStore tokenStore,
    SocketDebugLog? debugLog,
  }) : _baseUrl = baseUrl,
       _tokenStore = tokenStore,
       _debugLog = debugLog ?? _defaultDebugLog;

  final String _baseUrl;
  final ApiTokenStore _tokenStore;
  final SocketDebugLog _debugLog;
  final _connectionStatusController =
      StreamController<ChatConnectionStatus>.broadcast();
  final _typingStartedController =
      StreamController<ChatTypingEvent>.broadcast();
  final _typingStoppedController =
      StreamController<ChatTypingEvent>.broadcast();
  final _messageReceivedController =
      StreamController<ChatMessageEvent>.broadcast();
  final _messageSentController =
      StreamController<ChatMessageSentEvent>.broadcast();
  final _messageFailedController =
      StreamController<ChatMessageFailedEvent>.broadcast();
  final _messageSeenController =
      StreamController<ChatMessageSeenEvent>.broadcast();
  io.Socket? _socket;

  @override
  Stream<ChatConnectionStatus> get connectionStatus =>
      _connectionStatusController.stream;

  @override
  Stream<ChatMessageFailedEvent> get messageFailed =>
      _messageFailedController.stream;

  @override
  Stream<ChatMessageEvent> get messageReceived =>
      _messageReceivedController.stream;

  @override
  Stream<ChatMessageSeenEvent> get messageSeen => _messageSeenController.stream;

  @override
  Stream<ChatMessageSentEvent> get messageSent => _messageSentController.stream;

  @override
  Stream<ChatTypingEvent> get typingStarted => _typingStartedController.stream;

  @override
  Stream<ChatTypingEvent> get typingStopped => _typingStoppedController.stream;

  @override
  Future<void> connect() async {
    final existing = _socket;
    if (existing?.connected == true) {
      return;
    }

    final token = await _tokenStore.readToken();
    if (token == null || token.isEmpty) {
      _debug('Socket.IO connect blocked: missing auth token.');
      throw const ApiException(message: 'Authentication is required.');
    }

    _connectionStatusController.add(ChatConnectionStatus.connecting);
    final completer = Completer<void>();
    final socket = io.io(
      _baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );
    _socket = socket;
    _bindSocketEvents(socket);

    socket
      ..once('connect', (_) {
        _connectionStatusController.add(ChatConnectionStatus.connected);
        if (!completer.isCompleted) {
          completer.complete();
        }
      })
      ..on('disconnect', (_) {
        _connectionStatusController.add(ChatConnectionStatus.disconnected);
      })
      ..once('connect_error', (error) {
        _debug('Socket.IO connect_error: $error');
        _connectionStatusController.add(ChatConnectionStatus.disconnected);
        if (!completer.isCompleted) {
          completer.completeError(
            ApiException(message: 'Unable to connect chat: $error'),
          );
        }
      })
      ..connect();

    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        _debug('Socket.IO connect timed out after 10 seconds.');
        throw const ApiException(message: 'Unable to connect chat.');
      },
    );
  }

  @override
  Future<void> disconnect() async {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connectionStatusController.add(ChatConnectionStatus.disconnected);
  }

  @override
  Future<void> joinConversation(String conversationId) async {
    await connect();
    await _emitWithAck('join_conversation', {'conversationId': conversationId});
  }

  @override
  Future<void> leaveConversation(String conversationId) async {
    await _emitWithAck('leave_conversation', {
      'conversationId': conversationId,
    });
  }

  @override
  Future<void> typingStart(String conversationId) async {
    await _emitWithAck('typing_start', {'conversationId': conversationId});
  }

  @override
  Future<void> typingStop(String conversationId) async {
    await _emitWithAck('typing_stop', {'conversationId': conversationId});
  }

  @override
  Future<void> markSeen({
    required String conversationId,
    required String messageId,
  }) async {
    await _emitWithAck('mark_seen', {
      'conversationId': conversationId,
      'messageId': messageId,
    });
  }

  @override
  Future<ChatMessageSendResult> sendTextMessage({
    required String conversationId,
    required String text,
    String? clientMessageId,
  }) async {
    final clientTempId = clientMessageId;
    final data = await _sendMessageAck(
      conversationId: conversationId,
      clientTempId: clientTempId,
      content: text,
    );
    final message = data['message'];
    if (message is! Map<String, dynamic>) {
      throw const ApiException(message: 'Chat response is missing message.');
    }

    final returnedClientId =
        data['clientTempId'] as String? ?? data['clientMessageId'] as String?;

    return ChatMessageSendResult(
      clientMessageId: returnedClientId,
      message: Map<String, Object?>.from(message),
    );
  }

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String clientTempId,
    required String content,
    String type = 'text',
    String? mediaUrl,
  }) async {
    await _sendMessageAck(
      conversationId: conversationId,
      clientTempId: clientTempId,
      content: content,
      type: type,
      mediaUrl: mediaUrl,
    );
  }

  Future<Map<String, dynamic>> _sendMessageAck({
    required String conversationId,
    required String content,
    String? clientTempId,
    String type = 'text',
    String? mediaUrl,
  }) async {
    await connect();
    return _emitWithAck('send_message', {
      'conversationId': conversationId,
      if (clientTempId != null) 'clientTempId': clientTempId,
      'content': content,
      'type': type,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
    });
  }

  Future<Map<String, dynamic>> _emitWithAck(
    String event,
    Map<String, Object?> payload,
  ) async {
    final socket = _socket;
    if (socket == null) {
      _debug('Socket.IO emit blocked for $event: socket is unavailable.');
      throw const ApiException(message: 'Chat socket is unavailable.');
    }

    final completer = Completer<Map<String, dynamic>>();
    socket.emitWithAck(
      event,
      payload,
      ack: (response) {
        try {
          completer.complete(_readAckData(response));
        } catch (error) {
          _debug('Socket.IO ack error for $event: $error');
          completer.completeError(error);
        }
      },
    );

    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        _debug('Socket.IO $event timed out after 10 seconds.');
        throw const ApiException(message: 'Chat request timed out.');
      },
    );
  }

  Map<String, dynamic> _readAckData(Object? response) {
    if (response is! Map) {
      throw const ApiException(message: 'Invalid chat response.');
    }

    final ack = Map<String, dynamic>.from(response);
    if (ack['success'] == true) {
      final data = ack['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return const <String, dynamic>{};
    }

    final error = ack['error'];
    if (error is Map) {
      final errorMap = Map<String, dynamic>.from(error);
      throw ApiException(
        code: errorMap['code'] as String?,
        message: errorMap['message'] as String? ?? 'Chat request failed.',
      );
    }

    throw const ApiException(message: 'Chat request failed.');
  }

  void _debug(String message) {
    _debugLog(message);
  }

  void _bindSocketEvents(io.Socket socket) {
    socket
      ..on('user_typing_start', (payload) {
        final event = _typingEvent(payload);
        if (event != null) {
          _typingStartedController.add(event);
        }
      })
      ..on('user_typing_stop', (payload) {
        final event = _typingEvent(payload);
        if (event != null) {
          _typingStoppedController.add(event);
        }
      })
      ..on('new_message', (payload) {
        final event = _messageEvent(payload);
        if (event != null) {
          _messageReceivedController.add(event);
        }
      })
      ..on('message_sent', (payload) {
        final event = _messageSentEvent(payload);
        if (event != null) {
          _messageSentController.add(event);
        }
      })
      ..on('message_failed', (payload) {
        final event = _messageFailedEvent(payload);
        if (event != null) {
          _messageFailedController.add(event);
        }
      })
      ..on('message_seen', (payload) {
        final event = _messageSeenEvent(payload);
        if (event != null) {
          _messageSeenController.add(event);
        }
      });
  }

  ChatTypingEvent? _typingEvent(Object? payload) {
    final data = _mapOrNull(payload);
    if (data == null) {
      return null;
    }

    final conversationId = data['conversationId'];
    final userId = data['userId'];
    if (conversationId is! String || userId is! String) {
      return null;
    }

    return ChatTypingEvent(
      conversationId: conversationId,
      userId: userId,
      username: data['username'] as String?,
    );
  }

  ChatMessageEvent? _messageEvent(Object? payload) {
    final data = _mapOrNull(payload);
    final message = _messageFromPayload(data?['message']);
    final conversationId = data?['conversationId'];
    if (message == null || conversationId is! String) {
      return null;
    }

    return ChatMessageEvent(conversationId: conversationId, message: message);
  }

  ChatMessageSentEvent? _messageSentEvent(Object? payload) {
    final data = _mapOrNull(payload);
    final message = _messageFromPayload(data?['message']);
    final clientTempId = data?['clientTempId'] ?? data?['clientMessageId'];
    if (message == null || clientTempId is! String) {
      return null;
    }

    return ChatMessageSentEvent(clientTempId: clientTempId, message: message);
  }

  ChatMessageFailedEvent? _messageFailedEvent(Object? payload) {
    final data = _mapOrNull(payload);
    final conversationId = data?['conversationId'];
    final clientTempId = data?['clientTempId'] ?? data?['clientMessageId'];
    final error = _mapOrNull(data?['error']);
    if (conversationId is! String || clientTempId is! String) {
      return null;
    }

    return ChatMessageFailedEvent(
      conversationId: conversationId,
      clientTempId: clientTempId,
      message: error?['message'] as String? ?? 'Chat request failed.',
    );
  }

  ChatMessageSeenEvent? _messageSeenEvent(Object? payload) {
    final data = _mapOrNull(payload);
    final conversationId = data?['conversationId'];
    final userId = data?['userId'];
    final messageId = data?['messageId'];
    final seenAt = data?['seenAt'];
    if (conversationId is! String ||
        userId is! String ||
        messageId is! String ||
        seenAt is! String) {
      return null;
    }

    return ChatMessageSeenEvent(
      conversationId: conversationId,
      userId: userId,
      messageId: messageId,
      seenAt: DateTime.parse(seenAt),
    );
  }

  ChatMessage? _messageFromPayload(Object? payload) {
    final message = _mapOrNull(payload);
    if (message == null) {
      return null;
    }

    return ChatMessage.fromJson(message);
  }

  Map<String, dynamic>? _mapOrNull(Object? value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static void _defaultDebugLog(String message) {
    developer.log(message, name: 'Socket.IO');
  }
}
