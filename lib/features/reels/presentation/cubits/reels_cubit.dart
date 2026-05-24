import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/features/reels/domain/repositories/reels_repository.dart';

import '../../domain/entities/reel.dart';
import '../../domain/usecases/get_reels.dart';
import 'reels_state.dart';

class ReelsCubit extends Cubit<ReelsState> {
  static const int _visibleBatchSize = 3;
  static const int _feedPageSize = 20;

  ReelsCubit({
    required GetReels getReels,
    required ReelsRepository repository,
  })  : _getReels = getReels,
        _repository = repository,
        super(const ReelsInitial());

  final GetReels _getReels;
  final ReelsRepository _repository;
  final List<Reel> _bufferedReels = [];
  String? _nextCursor;
  bool _hasNextPage = true;
  bool _isLoadingMore = false;
  bool _isRefreshing = false;

  Future<void> loadReels() async {
    try {
      emit(const ReelsLoading());
      _resetPagination();
      final reels = await _pullNextBatch();

      emit(ReelsLoaded(reels));
    } catch (_) {
      emit(const ReelsError('Cannot load reels.'));
    }
  }

  Future<void> loadMoreReels() async {
    final currentState = state;
    if (currentState is! ReelsLoaded || _isLoadingMore) {
      return;
    }

    if (!_hasNextPage && _bufferedReels.isEmpty) {
      return;
    }

    _isLoadingMore = true;
    try {
      final nextBatch = await _pullNextBatch(
        excludeIds: currentState.reels.map((reel) => reel.id).toSet(),
      );
      if (nextBatch.isEmpty) {
        return;
      }

      emit(ReelsLoaded([
        ...currentState.reels,
        ...nextBatch,
      ]));
    } catch (_) {
      // Keep current feed when pagination fails.
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refreshReels() async {
    if (_isRefreshing) {
      return;
    }

    _isRefreshing = true;
    try {
      _resetPagination();
      final reels = await _pullNextBatch();
      emit(ReelsLoaded(reels));
    } catch (_) {
      emit(const ReelsError('Cannot load reels.'));
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> toggleLike(String reelId) async {
    final currentState = state;
    if (currentState is! ReelsLoaded) {
      return;
    }

    final targetReel = currentState.reels
        .where((reel) => reel.id == reelId)
        .firstOrNull;
    if (targetReel == null) {
      return;
    }

    final optimisticReels = currentState.reels.map((reel) {
      if (reel.id != reelId) {
        return reel;
      }

      return reel.copyWith(
        isLiked: !reel.isLiked,
        likes: reel.isLiked ? reel.likes - 1 : reel.likes + 1,
      );
    }).toList(growable: false);

    emit(ReelsLoaded(optimisticReels));

    try {
      final result = targetReel.isLiked
          ? await _repository.unlikeReel(reelId)
          : await _repository.likeReel(reelId);

      final syncedReels = optimisticReels.map((reel) {
        if (reel.id != result.reelId) {
          return reel;
        }

        return reel.copyWith(
          likes: result.likeCount,
          isLiked: result.isLiked,
        );
      }).toList(growable: false);

      emit(ReelsLoaded(syncedReels));
    } catch (_) {
      emit(ReelsLoaded(currentState.reels));
    }
  }

  Future<void> createReel({
    required String videoUrl,
    required String caption,
    int? durationSeconds,
  }) async {
    try {
      final createdReel = await _repository.createReel(
        videoUrl: videoUrl,
        caption: caption,
        durationSeconds: durationSeconds,
      );

      final currentState = state;
      if (currentState is ReelsLoaded) {
        emit(ReelsLoaded([createdReel, ...currentState.reels]));
        return;
      }

      emit(ReelsLoaded([createdReel]));
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteReel(String reelId) async {
    final currentState = state;
    if (currentState is! ReelsLoaded) {
      return;
    }

    final nextReels = currentState.reels
        .where((reel) => reel.id != reelId)
        .toList(growable: false);

    emit(ReelsLoaded(nextReels));

    try {
      await _repository.deleteReel(reelId);
    } catch (_) {
      emit(ReelsLoaded(currentState.reels));
      rethrow;
    }
  }

  Future<void> focusOnReel(String reelId) async {
    final currentState = state;
    if (currentState is ReelsLoaded) {
      final existingIndex = currentState.reels.indexWhere(
        (reel) => reel.id == reelId,
      );
      if (existingIndex >= 0) {
        final selectedReel = currentState.reels[existingIndex];
        final reordered = [
          selectedReel,
          ...currentState.reels.where((reel) => reel.id != reelId),
        ];
        emit(ReelsLoaded(reordered));
        return;
      }
    }

    try {
      final focusedReel = await _repository.getReelById(reelId);
      final existingReels = currentState is ReelsLoaded
          ? currentState.reels.where((reel) => reel.id != reelId)
          : const <Reel>[];
      emit(
        ReelsLoaded([
          focusedReel,
          ...existingReels,
        ]),
      );
    } catch (_) {
      // Keep current feed if shared reel can not be loaded.
    }
  }

  void incrementCommentCount(String reelId) {
    final currentState = state;
    if (currentState is! ReelsLoaded) {
      return;
    }

    final nextReels = currentState.reels.map((reel) {
      if (reel.id != reelId) {
        return reel;
      }

      return reel.copyWith(comments: reel.comments + 1);
    }).toList(growable: false);

    emit(ReelsLoaded(nextReels));
  }

  void _resetPagination() {
    _bufferedReels.clear();
    _nextCursor = null;
    _hasNextPage = true;
    _isLoadingMore = false;
  }

  Future<List<Reel>> _pullNextBatch({
    Set<String> excludeIds = const <String>{},
  }) async {
    final batch = <Reel>[];
    final seenIds = {...excludeIds};

    while (batch.length < _visibleBatchSize) {
      while (_bufferedReels.isNotEmpty && batch.length < _visibleBatchSize) {
        final reel = _bufferedReels.removeAt(0);
        if (seenIds.add(reel.id)) {
          batch.add(reel);
        }
      }

      if (batch.length >= _visibleBatchSize) {
        break;
      }

      if (!_hasNextPage) {
        break;
      }

      final chunk = await _getReels.chunk(
        cursor: _nextCursor,
        limit: _feedPageSize,
      );
      _nextCursor = chunk.nextCursor;
      _hasNextPage = chunk.hasNextPage;

      if (chunk.reels.isEmpty) {
        if (!_hasNextPage) {
          break;
        }
        continue;
      }

      for (final reel in chunk.reels) {
        if (!seenIds.contains(reel.id)) {
          _bufferedReels.add(reel);
        }
      }
    }

    return batch;
  }
}
