import 'package:t_app/core/network/api_client.dart';

import '../../domain/entities/reel.dart';
import '../../domain/entities/reel_comment.dart';
import '../../domain/entities/reel_reaction_result.dart';
import '../../domain/entities/reels_feed_chunk.dart';
import '../../domain/repositories/reels_repository.dart';
import '../models/reel_comment_model.dart';
import '../models/reel_model.dart';

class ReelsRepositoryImpl implements ReelsRepository {
  const ReelsRepositoryImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<Reel>> getReels() async {
    final chunk = await getReelsChunk();
    return chunk.reels;
  }

  @override
  Future<ReelsFeedChunk> getReelsChunk({
    String? cursor,
    int limit = 20,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/posts/feed',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
      },
      decode: _asMap,
    );

    final items = response['items'];
    final reels = items is! List
        ? const <Reel>[]
        : items
        .whereType<Map<String, dynamic>>()
        .where(_hasVideoMedia)
        .map(ReelModel.fromJson)
        .toList(growable: false);

    final pageInfo = response['pageInfo'];
    final pageInfoMap = pageInfo is Map<String, dynamic> ? pageInfo : const <String, dynamic>{};

    return ReelsFeedChunk(
      reels: reels,
      nextCursor: pageInfoMap['nextCursor'] as String?,
      hasNextPage: pageInfoMap['hasNextPage'] as bool? ?? false,
    );
  }

  @override
  Future<Reel> getReelById(String reelId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/posts/$reelId',
      decode: _asMap,
    );

    final payload = response['post'];
    if (payload is Map<String, dynamic>) {
      return ReelModel.fromJson(payload);
    }

    return ReelModel.fromJson(response);
  }

  @override
  Future<Reel> createReel({
    required String videoUrl,
    required String caption,
    int? durationSeconds,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/posts',
      data: {
        'content': caption,
        'mediaUrls': [videoUrl],
      },
      decode: _asMap,
    );

    final post = response['post'];
    if (post is Map<String, dynamic>) {
      return ReelModel.fromJson(post);
    }

    throw const FormatException('Response missing post.');
  }

  @override
  Future<ReelReactionResult> likeReel(String reelId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/posts/$reelId/like',
      decode: _asMap,
    );

    return ReelReactionResult(
      reelId: response['reelId'] as String? ?? response['postId'] as String? ?? reelId,
      likeCount: response['likeCount'] as int? ?? 0,
      isLiked: response['isLiked'] as bool? ?? false,
    );
  }

  @override
  Future<ReelReactionResult> unlikeReel(String reelId) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      '/posts/$reelId/like',
      decode: _asMap,
    );

    return ReelReactionResult(
      reelId: response['reelId'] as String? ?? response['postId'] as String? ?? reelId,
      likeCount: response['likeCount'] as int? ?? 0,
      isLiked: response['isLiked'] as bool? ?? false,
    );
  }

  @override
  Future<void> deleteReel(String reelId) async {
    await _apiClient.delete<Map<String, dynamic>>(
      '/posts/$reelId',
      decode: _asMap,
    );
  }

  @override
  Future<List<ReelComment>> getComments(String reelId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/posts/$reelId/replies',
      decode: _asMap,
    );

    final items = response['items'];
    if (items is! List) {
      return const [];
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(ReelCommentModel.fromJson)
        .toList(growable: false);
  }

  @override
  Future<ReelComment> createComment({
    required String reelId,
    required String content,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/posts/$reelId/replies',
      data: {
        'content': content,
        'mediaUrls': const <String>[],
      },
      decode: _asMap,
    );

    final comment = response['comment'] ?? response['reply'];
    if (comment is Map<String, dynamic>) {
      return ReelCommentModel.fromJson(comment);
    }

    throw const FormatException('Response missing reply.');
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    throw const FormatException('Expected a JSON object.');
  }

  static bool _hasVideoMedia(Map<String, dynamic> json) {
    final directVideoUrl = json['videoUrl'] as String?;
    if (directVideoUrl != null && directVideoUrl.isNotEmpty) {
      return true;
    }

    final mediaUrls = json['mediaUrls'];
    if (mediaUrls is! List) {
      return false;
    }

    for (final mediaUrl in mediaUrls.whereType<String>()) {
      if (_looksLikeVideoUrl(mediaUrl)) {
        return true;
      }
    }

    return false;
  }

  static bool _looksLikeVideoUrl(String url) {
    final normalized = url.toLowerCase().split('?').first;
    return normalized.endsWith('.mp4') ||
        normalized.endsWith('.mov') ||
        normalized.endsWith('.webm') ||
        normalized.endsWith('.m4v') ||
        normalized.contains('/video/upload/') ||
        url.toLowerCase().contains('player.cloudinary.com/embed/');
  }
}
