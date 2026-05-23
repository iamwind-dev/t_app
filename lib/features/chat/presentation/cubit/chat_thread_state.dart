import 'package:equatable/equatable.dart';
import 'package:t_app/features/chat/data/chat_conversation.dart';
import 'package:t_app/features/chat/data/chat_message.dart';
import 'package:t_app/features/chat/data/chat_socket_service.dart';

enum ChatThreadStatus { initial, loading, loaded, sending, failure }

class ChatThreadState extends Equatable {
  const ChatThreadState({
    required this.conversation,
    required this.currentUserId,
    this.status = ChatThreadStatus.initial,
    this.messages = const [],
    this.typingUsers = const {},
    this.connectionStatus = ChatConnectionStatus.disconnected,
    this.errorMessage,
    this.isLoadingOlder = false,
    this.hasMoreOlder = true,
    this.olderCursor,
  });

  final ChatThreadStatus status;
  final ChatConversation conversation;
  final String currentUserId;
  final List<ChatMessage> messages;
  final Map<String, String> typingUsers;
  final ChatConnectionStatus connectionStatus;
  final String? errorMessage;
  final bool isLoadingOlder;
  final bool hasMoreOlder;
  final String? olderCursor;

  ChatThreadState copyWith({
    ChatThreadStatus? status,
    List<ChatMessage>? messages,
    Map<String, String>? typingUsers,
    ChatConnectionStatus? connectionStatus,
    String? errorMessage,
    bool clearError = false,
    bool? isLoadingOlder,
    bool? hasMoreOlder,
    String? olderCursor,
    bool clearOlderCursor = false,
  }) {
    return ChatThreadState(
      status: status ?? this.status,
      conversation: conversation,
      currentUserId: currentUserId,
      messages: messages ?? this.messages,
      typingUsers: typingUsers ?? this.typingUsers,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
      hasMoreOlder: hasMoreOlder ?? this.hasMoreOlder,
      olderCursor: clearOlderCursor ? null : olderCursor ?? this.olderCursor,
    );
  }

  @override
  List<Object?> get props => [
    status,
    conversation,
    currentUserId,
    messages,
    typingUsers,
    connectionStatus,
    errorMessage,
    isLoadingOlder,
    hasMoreOlder,
    olderCursor,
  ];
}
