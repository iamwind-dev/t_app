import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/posts/data/moderated_thread_submission.dart';
import 'package:t_app/features/posts/data/moderation_result.dart';
import 'package:t_app/features/posts/data/post_page.dart';
import 'package:t_app/features/posts/data/reaction_result.dart';

abstract interface class PostsFeedRepository {
  Future<PostPage> getFeed({int limit = 10, String? cursor});

  Future<ModeratedThreadSubmission> createPost({
    required String content,
    List<String> mediaUrls = const <String>[],
  });

  Future<ModerationResult> checkModeration(String text);

  Future<ThreadItemModel> getPost(String postId);

  Future<ThreadItemModel> updatePost({
    required String postId,
    required String content,
    List<String> mediaUrls = const <String>[],
  });

  Future<void> deletePost(String postId);

  Future<ThreadItemModel> getReply(String replyId);

  Future<ThreadItemModel> updateReply({
    required String replyId,
    required String content,
    List<String> mediaUrls = const <String>[],
  });

  Future<void> deleteReply(String replyId);

  Future<PostPage> getPostReplies(String postId, {int limit = 10, String? cursor});

  Future<PostPage> getReplyChildren(String replyId, {int limit = 10, String? cursor});

  Future<ModeratedThreadSubmission> createPostReply({
    required String postId,
    required String content,
    List<String> mediaUrls = const <String>[],
  });

  Future<ModeratedThreadSubmission> createChildReply({
    required String replyId,
    required String content,
    List<String> mediaUrls = const <String>[],
  });

  Future<ReactionResult> likePost(String postId);

  Future<ReactionResult> unlikePost(String postId);

  Future<ReactionResult> likeReply(String replyId);

  Future<ReactionResult> unlikeReply(String replyId);
}
