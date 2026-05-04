import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/core/network/api_exception.dart';
import 'package:t_app/features/chat/domain/chat_repository.dart';

import 'chat_inbox_state.dart';

class ChatInboxCubit extends Cubit<ChatInboxState> {
  ChatInboxCubit({required ChatRepository repository})
    : _repository = repository,
      super(const ChatInboxState());

  final ChatRepository _repository;

  Future<void> loadConversations() async {
    emit(state.copyWith(status: ChatInboxStatus.loading, clearError: true));

    try {
      final page = await _repository.listConversations();
      emit(
        ChatInboxState(
          status: ChatInboxStatus.loaded,
          conversations: page.items,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          status: ChatInboxStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ChatInboxStatus.failure,
          errorMessage: 'Unable to load chats.',
        ),
      );
    }
  }
}
