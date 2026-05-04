import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/core/network/api_exception.dart';
import 'package:t_app/features/chat/domain/chat_repository.dart';

import 'direct_conversation_state.dart';

class DirectConversationCubit extends Cubit<DirectConversationState> {
  DirectConversationCubit({required ChatRepository repository})
    : _repository = repository,
      super(const DirectConversationState());

  final ChatRepository _repository;

  Future<void> createDirectConversation(String targetUserId) async {
    emit(
      const DirectConversationState(
        status: DirectConversationStatus.creating,
      ),
    );

    try {
      final conversation = await _repository.createDirectConversation(
        targetUserId,
      );
      emit(
        DirectConversationState(
          status: DirectConversationStatus.created,
          conversation: conversation,
        ),
      );
    } on ApiException catch (error) {
      emit(
        DirectConversationState(
          status: DirectConversationStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        const DirectConversationState(
          status: DirectConversationStatus.failure,
          errorMessage: 'Unable to start conversation.',
        ),
      );
    }
  }
}
