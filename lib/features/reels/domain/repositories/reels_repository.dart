import '../entities/reel.dart';
import '../entities/reel_comment.dart';
import '../entities/reel_reaction_result.dart';
import '../entities/reels_feed_chunk.dart';

abstract class ReelsRepository {
  Future<List<Reel>> getReels();
  Future<ReelsFeedChunk> getReelsChunk({
    String? cursor,
    int limit = 20,
  });
  Future<Reel> getReelById(String reelId);
  Future<Reel> createReel({
    required String videoUrl,
    required String caption,
    int? durationSeconds,
  });
  Future<ReelReactionResult> likeReel(String reelId);
  Future<ReelReactionResult> unlikeReel(String reelId);
  Future<void> deleteReel(String reelId);
  Future<List<ReelComment>> getComments(String reelId);
  Future<ReelComment> createComment({
    required String reelId,
    required String content,
  });
}
