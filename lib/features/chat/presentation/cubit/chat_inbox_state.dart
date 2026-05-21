import 'package:equatable/equatable.dart';
import 'package:t_app/features/chat/data/chat_conversation.dart';

enum ChatInboxStatus { initial, loading, loaded, failure }

class ChatInboxState extends Equatable {
  const ChatInboxState({
    this.status = ChatInboxStatus.initial,
    this.conversations = const [],
    this.errorMessage,
  });

  final ChatInboxStatus status;
  final List<ChatConversation> conversations;
  final String? errorMessage;

  ChatInboxState copyWith({
    ChatInboxStatus? status,
    List<ChatConversation>? conversations,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatInboxState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, conversations, errorMessage];
}
