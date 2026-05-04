import 'package:equatable/equatable.dart';
import 'package:t_app/features/chat/data/chat_conversation.dart';

enum DirectConversationStatus { initial, creating, created, failure }

class DirectConversationState extends Equatable {
  const DirectConversationState({
    this.status = DirectConversationStatus.initial,
    this.conversation,
    this.errorMessage,
  });

  final DirectConversationStatus status;
  final ChatConversation? conversation;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, conversation, errorMessage];
}
