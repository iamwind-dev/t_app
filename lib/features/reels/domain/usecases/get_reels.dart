

import '../entities/reel.dart';
import '../entities/reels_feed_chunk.dart';
import '../repositories/reels_repository.dart';

class GetReels {
  final ReelsRepository repository;

  GetReels(this.repository);

  Future<List<Reel>> call() {
    return repository.getReels();
  }

  Future<ReelsFeedChunk> chunk({
    String? cursor,
    int limit = 20,
  }) {
    return repository.getReelsChunk(
      cursor: cursor,
      limit: limit,
    );
  }
}
