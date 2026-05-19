import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/posts/data/post_page.dart';
import 'package:t_app/features/posts/data/reaction_result.dart';

abstract interface class PostsFeedRepository {
  Future<PostPage> getFeed({String? cursor});

  Future<ThreadItemModel> createPost({
    required String content,
    List<String> mediaUrls = const <String>[],
  });

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

  Future<PostPage> getPostReplies(String postId, {String? cursor});

  Future<PostPage> getReplyChildren(String replyId, {String? cursor});

  Future<ThreadItemModel> createPostReply({
    required String postId,
    required String content,
    List<String> mediaUrls = const <String>[],
  });

  Future<ThreadItemModel> createChildReply({
    required String replyId,
    required String content,
    List<String> mediaUrls = const <String>[],
  });

  Future<ReactionResult> likePost(String postId);

  Future<ReactionResult> unlikePost(String postId);

  Future<ReactionResult> likeReply(String replyId);

  Future<ReactionResult> unlikeReply(String replyId);
}
