import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_reels.dart';
import 'reels_state.dart';

class ReelsCubit extends Cubit<ReelsState> {
  final GetReels getReels;

  ReelsCubit({
    required this.getReels,
  }) : super(const ReelsInitial());

  Future<void> loadReels() async {
    try {
      emit(const ReelsLoading());

      final reels = await getReels();

      emit(ReelsLoaded(reels));
    } catch (_) {
      emit(const ReelsError('Không thể tải reels'));
    }
  }

  void toggleLike(String reelId) {
    final currentState = state;

    if (currentState is! ReelsLoaded) return;

    final updatedReels = currentState.reels.map((reel) {
      if (reel.id != reelId) return reel;

      return reel.copyWith(
        isLiked: !reel.isLiked,
        likes: reel.isLiked ? reel.likes - 1 : reel.likes + 1,
      );
    }).toList();

    emit(ReelsLoaded(updatedReels));
  }
}