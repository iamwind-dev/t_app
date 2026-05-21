import 'package:t_app/core/network/api_client.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/posts/domain/posts_feed_repository.dart';

import 'moderated_thread_submission.dart';
import 'moderation_result.dart';
import 'post_page.dart';
import 'reaction_result.dart';
import 'thread_api_mapper.dart';

class PostsRepository implements PostsFeedRepository {
  const PostsRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<PostPage> getFeed({int limit = 10, String? cursor}) {
    return _apiClient.get<PostPage>(
      '/posts/feed',
      queryParameters: {'limit': limit, if (cursor != null) 'cursor': cursor},
      decode: (value) => PostPage.fromJson(
        _asMap(value),
        itemMapper: ThreadApiMapper.postFromJson,
      ),
    );
  }

  @override
  /// Creates a post and keeps the backend moderation payload attached to it.
  Future<ModeratedThreadSubmission> createPost({
    required String content,
    List<String> mediaUrls = const <String>[],
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/posts',
      data: {'content': content, 'mediaUrls': mediaUrls},
      decode: _asMap,
    );

    return ModeratedThreadSubmission(
      thread: _readOptionalObject(response, 'post') == null
          ? null
          : ThreadApiMapper.postFromJson(_readObject(response, 'post')),
      moderation: _readOptionalObject(response, 'moderation') == null
          ? null
          : ModerationResult.fromJson(_readObject(response, 'moderation')),
    );
  }

  @override
  /// Calls the NestJS moderation endpoint instead of the AI service directly.
  Future<ModerationResult> checkModeration(String text) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/moderation/check',
      data: {'text': text},
      decode: _asMap,
    );

    // `ApiClient` already unwraps the `{ success, data }` envelope for us.
    return ModerationResult.fromJson(response);
  }

  @override
  Future<ThreadItemModel> getPost(String postId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/posts/$postId',
      decode: _asMap,
    );

    return ThreadApiMapper.postFromJson(_readObject(response, 'post'));
  }

  @override
  Future<ThreadItemModel> updatePost({
    required String postId,
    required String content,
    List<String> mediaUrls = const <String>[],
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/posts/$postId',
      data: {'content': content, 'mediaUrls': mediaUrls},
      decode: _asMap,
    );

    return ThreadApiMapper.postFromJson(_readObject(response, 'post'));
  }

  @override
  Future<void> deletePost(String postId) async {
    await _apiClient.delete<Map<String, dynamic>>(
      '/posts/$postId',
      decode: _asMap,
    );
  }

  @override
  Future<ThreadItemModel> getReply(String replyId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/replies/$replyId',
      decode: _asMap,
    );

    return ThreadApiMapper.replyFromJson(_readObject(response, 'reply'));
  }

  @override
  Future<ThreadItemModel> updateReply({
    required String replyId,
    required String content,
    List<String> mediaUrls = const <String>[],
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/replies/$replyId',
      data: {'content': content, 'mediaUrls': mediaUrls},
      decode: _asMap,
    );

    return ThreadApiMapper.replyFromJson(_readObject(response, 'reply'));
  }

  @override
  Future<void> deleteReply(String replyId) async {
    await _apiClient.delete<Map<String, dynamic>>(
      '/replies/$replyId',
      decode: _asMap,
    );
  }

  @override
  Future<PostPage> getPostReplies(String postId, {int limit = 10, String? cursor}) {
    return _apiClient.get<PostPage>(
      '/posts/$postId/replies',
      queryParameters: {'limit': limit, if (cursor != null) 'cursor': cursor},
      decode: (value) => PostPage.fromJson(
        _asMap(value),
        itemMapper: ThreadApiMapper.replyFromJson,
      ),
    );
  }

  @override
  Future<PostPage> getReplyChildren(String replyId, {int limit = 10, String? cursor}) {
    return _apiClient.get<PostPage>(
      '/replies/$replyId/children',
      queryParameters: {'limit': limit, if (cursor != null) 'cursor': cursor},
      decode: (value) => PostPage.fromJson(
        _asMap(value),
        itemMapper: ThreadApiMapper.replyFromJson,
      ),
    );
  }

  @override
  /// Creates a reply on a post and returns both reply data and moderation.
  Future<ModeratedThreadSubmission> createPostReply({
    required String postId,
    required String content,
    List<String> mediaUrls = const <String>[],
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/posts/$postId/replies',
      data: {'content': content, 'mediaUrls': mediaUrls},
      decode: _asMap,
    );

    return ModeratedThreadSubmission(
      thread: _readOptionalObject(response, 'reply') == null
          ? null
          : ThreadApiMapper.replyFromJson(_readObject(response, 'reply')),
      moderation: _readOptionalObject(response, 'moderation') == null
          ? null
          : ModerationResult.fromJson(_readObject(response, 'moderation')),
    );
  }

  @override
  /// Creates a nested child reply and returns both reply data and moderation.
  Future<ModeratedThreadSubmission> createChildReply({
    required String replyId,
    required String content,
    List<String> mediaUrls = const <String>[],
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/replies/$replyId/replies',
      data: {'content': content, 'mediaUrls': mediaUrls},
      decode: _asMap,
    );

    return ModeratedThreadSubmission(
      thread: _readOptionalObject(response, 'reply') == null
          ? null
          : ThreadApiMapper.replyFromJson(_readObject(response, 'reply')),
      moderation: _readOptionalObject(response, 'moderation') == null
          ? null
          : ModerationResult.fromJson(_readObject(response, 'moderation')),
    );
  }

  @override
  Future<ReactionResult> likePost(String postId) {
    return _apiClient.post<ReactionResult>(
      '/posts/$postId/like',
      decode: (value) => ReactionResult.fromPostJson(_asMap(value)),
    );
  }

  @override
  Future<ReactionResult> unlikePost(String postId) {
    return _apiClient.delete<ReactionResult>(
      '/posts/$postId/like',
      decode: (value) => ReactionResult.fromPostJson(_asMap(value)),
    );
  }

  @override
  Future<ReactionResult> likeReply(String replyId) {
    return _apiClient.post<ReactionResult>(
      '/replies/$replyId/like',
      decode: (value) => ReactionResult.fromReplyJson(_asMap(value)),
    );
  }

  @override
  Future<ReactionResult> unlikeReply(String replyId) {
    return _apiClient.delete<ReactionResult>(
      '/replies/$replyId/like',
      decode: (value) => ReactionResult.fromReplyJson(_asMap(value)),
    );
  }

  static Map<String, dynamic> _readObject(
    Map<String, dynamic> response,
    String key,
  ) {
    final value = response[key];
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    throw FormatException('Response missing $key.');
  }

  /// Reads an optional nested object without forcing older payloads to fail.
  static Map<String, dynamic>? _readOptionalObject(
    Map<String, dynamic> response,
    String key,
  ) {
    final value = response[key];
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    throw const FormatException('Expected a JSON object.');
  }
}
