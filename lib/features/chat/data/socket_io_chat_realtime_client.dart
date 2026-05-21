import 'dart:async';
import 'dart:collection';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:t_app/core/network/api_exception.dart';
import 'package:t_app/core/network/api_token_store.dart';
import 'package:t_app/core/realtime/realtime_event_bus.dart';
import 'package:t_app/core/realtime/realtime_event_cursor_store.dart';

import 'chat_message.dart';
import 'chat_realtime_client.dart';
import 'socket_payload_normalizer.dart';
import 'chat_socket_service.dart';

typedef SocketDebugLog = void Function(String message);

class SocketIoChatRealtimeClient
    implements ChatRealtimeClient, ChatSocketService {
  SocketIoChatRealtimeClient({
    required String baseUrl,
    required ApiTokenStore tokenStore,
    RealtimeEventCursorStore? eventCursorStore,
    SocketDebugLog? debugLog,
  }) : _baseUrl = baseUrl,
       _tokenStore = tokenStore,
       _eventCursorStore = eventCursorStore ?? const RealtimeEventCursorStore(),
       _debugLog = debugLog ?? _defaultDebugLog;

  final String _baseUrl;
  final ApiTokenStore _tokenStore;
  final RealtimeEventCursorStore _eventCursorStore;
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
  final Set<String> _joinedConversationIds = <String>{};
  final Set<String> _seenEventIds = <String>{};
  final Queue<String> _seenEventQueue = Queue<String>();
  final Map<String, String> _latestOrderingByKey = <String, String>{};
  final Set<String> _joinedRooms = <String>{};
  static const int _maxSeenEventIds = 500;
  io.Socket? _chatSocket;
  io.Socket? _realtimeSocket;

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
  Future<void> connect() {
    return _connect(allowRefresh: true);
  }

  Future<void> _connect({required bool allowRefresh}) async {
    final chatExisting = _chatSocket;
    final realtimeExisting = _realtimeSocket;
    if (chatExisting?.connected == true && realtimeExisting?.connected == true) {
      return;
    }

    final token = _normalizeSocketAuthToken(await _tokenStore.readToken());
    if (token == null || token.isEmpty) {
      _debug('Socket.IO cannot connect: missing auth token.');
      throw const ApiException(message: 'Can not connect chat without login.');
    }

    _connectionStatusController.add(ChatConnectionStatus.connecting);
    final chatSocket = io.io(
      _chatUrl(_baseUrl),
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );
    final realtimeSocket = io.io(
      _realtimeUrl(_baseUrl),
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );
    _chatSocket = chatSocket;
    _realtimeSocket = realtimeSocket;
    _bindChatSocketEvents(chatSocket);
    _bindRealtimeSocketEvents(realtimeSocket);

    try {
      await _waitForSocketConnection(chatSocket, label: 'chat');
      await _waitForSocketConnection(realtimeSocket, label: 'realtime');
      _connectionStatusController.add(ChatConnectionStatus.connected);
      await _joinDefaultRooms();
      await _resubscribeRooms();
      await _syncMissedEvents(rooms: _joinedRooms.toList(growable: false));
    } catch (error) {
      await disconnect();
      if (allowRefresh && _isTokenExpiredError(error)) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          return _connect(allowRefresh: false);
        }
      }

      _debug('Socket.IO connect failed: $error');
      throw ApiException(message: 'Can not connect chat: $error');
    }
  }

  @override
  Future<void> disconnect() async {
    _chatSocket?.disconnect();
    _chatSocket?.dispose();
    _chatSocket = null;
    _realtimeSocket?.disconnect();
    _realtimeSocket?.dispose();
    _realtimeSocket = null;
    _connectionStatusController.add(ChatConnectionStatus.disconnected);
  }

  @override
  Future<void> joinConversation(String conversationId) async {
    await connect();
    await _emitChatWithAck('join_conversation', {'conversationId': conversationId});
    _joinedConversationIds.add(conversationId);
  }

  @override
  Future<void> leaveConversation(String conversationId) async {
    await _emitChatWithAck('leave_conversation', {
      'conversationId': conversationId,
    });
    _joinedConversationIds.remove(conversationId);
  }

  @override
  Future<void> joinRoom(String room) async {
    if (room.trim().isEmpty) {
      return;
    }
    await connect();
    await _emitRealtimeWithAck('subscribe_rooms', {
      'rooms': [room],
    });
    _joinedRooms.add(room);
  }

  @override
  Future<void> leaveRoom(String room) async {
    if (room.trim().isEmpty) {
      return;
    }
    await _emitRealtimeWithAck('unsubscribe_rooms', {
      'rooms': [room],
    });
    _joinedRooms.remove(room);
  }

  @override
  Future<void> syncEvents({List<String> rooms = const []}) async {
    await _syncMissedEvents(rooms: rooms);
  }

  @override
  Future<void> typingStart(String conversationId) async {
    await _emitChatWithAck('typing_start', {'conversationId': conversationId});
  }

  @override
  Future<void> typingStop(String conversationId) async {
    await _emitChatWithAck('typing_stop', {'conversationId': conversationId});
  }

  @override
  Future<void> markSeen({
    required String conversationId,
    required String messageId,
  }) async {
    await _emitChatWithAck('mark_seen', {
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
      throw const ApiException(message: 'Chat response missing message payload.');
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
    return _emitChatWithAck('send_message', {
      'conversationId': conversationId,
      if (clientTempId != null) 'clientTempId': clientTempId,
      'content': content,
      'type': type,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
    });
  }

  Future<Map<String, dynamic>> _emitChatWithAck(
    String event,
    Map<String, Object?> payload,
  ) {
    return _emitWithAck(
      socket: _chatSocket,
      event: event,
      payload: payload,
    );
  }

  Future<Map<String, dynamic>> _emitRealtimeWithAck(
    String event,
    Map<String, Object?> payload,
  ) {
    return _emitWithAck(
      socket: _realtimeSocket,
      event: event,
      payload: payload,
    );
  }

  Future<Map<String, dynamic>> _emitWithAck({
    required io.Socket? socket,
    required String event,
    required Map<String, Object?> payload,
  }) async {
    if (socket == null) {
      _debug('Socket.IO emit blocked for $event: socket unavailable.');
      throw const ApiException(message: 'Chat connection is unavailable.');
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

    try {
      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _debug('Socket.IO $event timed out after 10 seconds.');
          throw const ApiException(message: 'Chat request timed out.');
        },
      );
    } on ApiException catch (error) {
      if (_isAuthExpiredApiError(error) && await _refreshAccessToken()) {
        final isRealtimeSocket = identical(socket, _realtimeSocket);
        await _connect(allowRefresh: false);
        if (isRealtimeSocket) {
          return _emitRealtimeWithAck(event, payload);
        }
        return _emitChatWithAck(event, payload);
      }
      rethrow;
    }
  }

  Map<String, dynamic> _readAckData(Object? response) {
    if (response is! Map) {
      throw const ApiException(message: 'Invalid chat response format.');
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
        message:
            errorMap['message'] as String? ?? 'Chat request failed unexpectedly.',
      );
    }

    throw const ApiException(message: 'Chat request failed unexpectedly.');
  }

  void _debug(String message) {
    _debugLog(message);
  }

  void _bindChatSocketEvents(io.Socket socket) {
    socket
      ..on('disconnect', (_) {
        _connectionStatusController.add(ChatConnectionStatus.disconnected);
      })
      ..on('user_typing_start', (payload) {
        _dispatchEvent(type: 'user_typing_start', payload: payload);
      })
      ..on('user_typing_stop', (payload) {
        _dispatchEvent(type: 'user_typing_stop', payload: payload);
      })
      ..on('new_message', (payload) {
        _dispatchEvent(type: 'new_message', payload: payload);
      })
      ..on('message_sent', (payload) {
        _dispatchEvent(type: 'message_sent', payload: payload);
      })
      ..on('message_failed', (payload) {
        _dispatchEvent(type: 'message_failed', payload: payload);
      })
      ..on('message_seen', (payload) {
        _dispatchEvent(type: 'message_seen', payload: payload);
      });
  }

  void _bindRealtimeSocketEvents(io.Socket socket) {
    socket
      ..on('disconnect', (_) {
        _connectionStatusController.add(ChatConnectionStatus.disconnected);
      })
      ..on('domain_event', (payload) {
        final event = _mapOrNull(payload);
        if (event == null) {
          return;
        }
        final type = event['type'] as String?;
        if (type == null || type.isEmpty) {
          return;
        }
        _dispatchEvent(
          type: type,
          payload: event['payload'],
          eventId: event['eventId'] as String?,
          orderingKey: event['orderingKey'] as String?,
          orderingValue: event['orderingValue']?.toString(),
        );
      });
  }

  void _dispatchEvent({
    required String type,
    required Object? payload,
    String? eventId,
    String? orderingKey,
    String? orderingValue,
  }) {
    final normalizedPayload = _normalizePayload(payload);
    final normalizedEventId = eventId ?? normalizedPayload['eventId'] as String?;
    final normalizedOrderingKey =
        orderingKey ?? normalizedPayload['orderingKey'] as String?;
    final normalizedOrderingValue = orderingValue ??
        (normalizedPayload['orderingValue'] as String? ??
            normalizedPayload['orderingVersion']?.toString());

    if (!_shouldApplyEvent(
      eventId: normalizedEventId,
      orderingKey: normalizedOrderingKey,
      orderingValue: normalizedOrderingValue,
    )) {
      return;
    }

    switch (type) {
      case 'user_typing_start':
        final typing = _typingEvent(normalizedPayload);
        if (typing != null) {
          _typingStartedController.add(typing);
        }
        break;
      case 'user_typing_stop':
        final typing = _typingEvent(normalizedPayload);
        if (typing != null) {
          _typingStoppedController.add(typing);
        }
        break;
      case 'new_message':
        final messageEvent = _messageEvent(normalizedPayload);
        if (messageEvent != null) {
          _messageReceivedController.add(messageEvent);
        }
        break;
      case 'message_sent':
        final sentEvent = _messageSentEvent(normalizedPayload);
        if (sentEvent != null) {
          _messageSentController.add(sentEvent);
        }
        break;
      case 'message_failed':
        final failedEvent = _messageFailedEvent(normalizedPayload);
        if (failedEvent != null) {
          _messageFailedController.add(failedEvent);
        }
        break;
      case 'message_seen':
        final seenEvent = _messageSeenEvent(normalizedPayload);
        if (seenEvent != null) {
          _messageSeenController.add(seenEvent);
        }
        break;
      default:
        break;
    }

    RealtimeEventBus.instance.emit(
      RealtimeAppEvent(
        type: type,
        payload: normalizedPayload,
        eventId: normalizedEventId,
        orderingKey: normalizedOrderingKey,
        orderingValue: normalizedOrderingValue,
      ),
    );

    if (normalizedEventId != null && normalizedEventId.isNotEmpty) {
      unawaited(_eventCursorStore.writeLastEventId(normalizedEventId));
    }
  }

  Map<String, dynamic> _normalizePayload(Object? payload) {
    final asMap = _mapOrNull(payload) ?? const <String, dynamic>{};
    if (asMap['payload'] is Map) {
      return {
        ...Map<String, dynamic>.from(asMap['payload'] as Map),
        if (asMap['eventId'] is String) 'eventId': asMap['eventId'],
        if (asMap['orderingKey'] is String) 'orderingKey': asMap['orderingKey'],
        if (asMap['orderingValue'] != null)
          'orderingValue': asMap['orderingValue'].toString(),
      };
    }
    return asMap;
  }

  bool _shouldApplyEvent({
    required String? eventId,
    required String? orderingKey,
    required String? orderingValue,
  }) {
    if (eventId != null && eventId.isNotEmpty) {
      if (_seenEventIds.contains(eventId)) {
        return false;
      }
      _seenEventIds.add(eventId);
      _seenEventQueue.add(eventId);
      if (_seenEventQueue.length > _maxSeenEventIds) {
        final removed = _seenEventQueue.removeFirst();
        _seenEventIds.remove(removed);
      }
    }

    if (orderingKey == null ||
        orderingKey.isEmpty ||
        orderingValue == null ||
        orderingValue.isEmpty) {
      return true;
    }

    final previous = _latestOrderingByKey[orderingKey];
    if (previous != null && _compareOrdering(orderingValue, previous) <= 0) {
      return false;
    }

    _latestOrderingByKey[orderingKey] = orderingValue;
    return true;
  }

  int _compareOrdering(String next, String current) {
    final nextInt = int.tryParse(next);
    final currentInt = int.tryParse(current);
    if (nextInt != null && currentInt != null) {
      return nextInt.compareTo(currentInt);
    }

    final nextTime = DateTime.tryParse(next);
    final currentTime = DateTime.tryParse(current);
    if (nextTime != null && currentTime != null) {
      return nextTime.compareTo(currentTime);
    }

    return next.compareTo(current);
  }

  bool _isTokenExpiredError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('jwt expired') ||
        message.contains('auth_token_expired') ||
        message.contains('invalid_token');
  }

  bool _isAuthExpiredApiError(ApiException error) {
    final code = error.code?.toUpperCase();
    final message = error.message.toLowerCase();
    return code == 'AUTH_TOKEN_EXPIRED' ||
        code == 'INVALID_TOKEN' ||
        message.contains('jwt expired');
  }

  Future<bool> _refreshAccessToken() async {
    final refreshToken = await _tokenStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        validateStatus: (_) => true,
      ),
    );

    try {
      final response = await dio.post<Object?>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final body = response.data;
      if (body is! Map<String, dynamic>) {
        return false;
      }

      final success = body['success'] == true;
      final data = body['data'];
      if (!success || data is! Map<String, dynamic>) {
        return false;
      }

      final nextAccessToken = data['accessToken'] as String?;
      final nextRefreshToken = data['refreshToken'] as String?;
      if (nextAccessToken == null ||
          nextAccessToken.isEmpty ||
          nextRefreshToken == null ||
          nextRefreshToken.isEmpty) {
        return false;
      }

      await _tokenStore.writeToken(nextAccessToken);
      await _tokenStore.writeRefreshToken(nextRefreshToken);
      return true;
    } catch (_) {
      return false;
    } finally {
      dio.close();
    }
  }

  Future<void> _resubscribeRooms() async {
    if (_joinedConversationIds.isEmpty && _joinedRooms.isEmpty) {
      return;
    }

    for (final room in _joinedRooms) {
      try {
        await _emitRealtimeWithAck('subscribe_rooms', {
          'rooms': [room],
        });
      } catch (error) {
        _debug('Failed to resubscribe room $room: $error');
      }
    }

    final roomIds = List<String>.from(_joinedConversationIds);
    for (final conversationId in roomIds) {
      try {
        await _emitChatWithAck('join_conversation', {
          'conversationId': conversationId,
        });
      } catch (error) {
        _debug('Failed to resubscribe room $conversationId: $error');
      }
    }
  }

  Future<void> _syncMissedEvents({List<String> rooms = const []}) async {
    final sinceEventId = await _eventCursorStore.readLastEventId();
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        validateStatus: (_) => true,
      ),
    );

    final token = await _tokenStore.readToken();
    if (token != null && token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await dio.get<Object?>(
        '/sync/events',
        queryParameters: {
          if (sinceEventId != null && sinceEventId.isNotEmpty)
            'sinceEventId': sinceEventId,
          if (rooms.isNotEmpty) 'rooms': rooms.join(','),
        },
      );
      final body = response.data;
      if (body is! Map<String, dynamic> || body['success'] != true) {
        return;
      }

      final data = body['data'];
      if (data is! Map<String, dynamic>) {
        return;
      }

      final items = data['items'];
      if (items is! List) {
        return;
      }

      for (final raw in items) {
        if (raw is! Map) {
          continue;
        }
        final event = Map<String, dynamic>.from(raw);
        final type = event['type'] as String?;
        if (type == null || type.isEmpty) {
          continue;
        }

        _dispatchEvent(
          type: type,
          payload: event['payload'],
          eventId: event['eventId'] as String?,
          orderingKey: event['orderingKey'] as String?,
          orderingValue: event['orderingValue']?.toString(),
        );
      }
    } catch (error) {
      _debug('Sync missed events failed: $error');
    } finally {
      dio.close();
    }
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
      message: error?['message'] as String? ?? 'Chat request failed unexpectedly.',
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
    return coerceSocketPayloadMap(value);
  }

  static void _defaultDebugLog(String message) {
    developer.log(message, name: 'Socket.IO');
  }

  Future<void> _joinDefaultRooms() async {
    _joinedRooms.add('feed:global');
    try {
      await _emitRealtimeWithAck('subscribe_rooms', {
        'rooms': ['feed:global'],
      });
    } catch (error) {
      _debug('Failed to join default room feed:global: $error');
    }
  }

  String _realtimeUrl(String baseUrl) {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null) {
      return '$baseUrl/realtime';
    }
    final segments = List<String>.from(uri.pathSegments)
      ..removeWhere((segment) => segment.isEmpty);
    if (segments.isEmpty || segments.last != 'realtime') {
      segments.add('realtime');
    }
    return uri.replace(pathSegments: segments).toString();
  }

  String _chatUrl(String baseUrl) {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null) {
      return baseUrl;
    }
    return uri.replace(pathSegments: const <String>[]).toString();
  }

  String? _normalizeSocketAuthToken(String? token) {
    if (token == null) {
      return null;
    }

    var normalized = token.trim();
    if (normalized.isEmpty) {
      return null;
    }

    if ((normalized.startsWith('"') && normalized.endsWith('"')) ||
        (normalized.startsWith("'") && normalized.endsWith("'"))) {
      normalized = normalized.substring(1, normalized.length - 1).trim();
    }

    final lower = normalized.toLowerCase();
    if (lower.startsWith('bearer ')) {
      normalized = normalized.substring(7).trim();
    }

    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  Future<void> _waitForSocketConnection(
    io.Socket socket, {
    required String label,
  }) async {
    final completer = Completer<void>();
    socket
      ..once('connect', (_) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      })
      ..once('connect_error', (error) {
        _debug('Socket.IO $label connect_error: $error');
        if (!completer.isCompleted) {
          completer.completeError(error ?? 'unknown_error');
        }
      })
      ..connect();

    await completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw '${label}_connect_timeout',
    );
  }
}

