import 'package:t_app/core/network/api_client.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/posts/domain/posts_feed_repository.dart';

import 'post_page.dart';
import 'reaction_result.dart';
import 'thread_api_mapper.dart';

class PostsRepository implements PostsFeedRepository {
  const PostsRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<PostPage> getFeed({String? cursor}) {
    return _apiClient.get<PostPage>(
      '/posts/feed',
      queryParameters: {'limit': 20, if (cursor != null) 'cursor': cursor},
      decode: (value) => PostPage.fromJson(
        _asMap(value),
        itemMapper: ThreadApiMapper.postFromJson,
      ),
    );
  }

  @override
  Future<ThreadItemModel> createPost({required String content}) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/posts',
      data: {'content': content, 'mediaUrls': const <String>[]},
      decode: _asMap,
    );

    return ThreadApiMapper.postFromJson(_readObject(response, 'post'));
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
  Future<PostPage> getPostReplies(String postId, {String? cursor}) {
    return _apiClient.get<PostPage>(
      '/posts/$postId/replies',
      queryParameters: {'limit': 20, if (cursor != null) 'cursor': cursor},
      decode: (value) => PostPage.fromJson(
        _asMap(value),
        itemMapper: ThreadApiMapper.replyFromJson,
      ),
    );
  }

  @override
  Future<PostPage> getReplyChildren(String replyId, {String? cursor}) {
    return _apiClient.get<PostPage>(
      '/replies/$replyId/children',
      queryParameters: {'limit': 10, if (cursor != null) 'cursor': cursor},
      decode: (value) => PostPage.fromJson(
        _asMap(value),
        itemMapper: ThreadApiMapper.replyFromJson,
      ),
    );
  }

  @override
  Future<ThreadItemModel> createPostReply({
    required String postId,
    required String content,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/posts/$postId/replies',
      data: {'content': content, 'mediaUrls': const <String>[]},
      decode: _asMap,
    );

    return ThreadApiMapper.replyFromJson(_readObject(response, 'reply'));
  }

  @override
  Future<ThreadItemModel> createChildReply({
    required String replyId,
    required String content,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/replies/$replyId/replies',
      data: {'content': content, 'mediaUrls': const <String>[]},
      decode: _asMap,
    );

    return ThreadApiMapper.replyFromJson(_readObject(response, 'reply'));
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
    if (value is Map<String, dynamic>) {
      return value;
    }

    throw FormatException('Phản hồi thiếu trường $key.');
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    throw const FormatException('Cần một đối tượng JSON.');
  }
}
