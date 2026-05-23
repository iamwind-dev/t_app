import 'package:t_app/core/network/api_client.dart';

import '../../domain/entities/reel.dart';
import '../../domain/entities/reel_comment.dart';
import '../../domain/entities/reel_reaction_result.dart';
import '../../domain/repositories/reels_repository.dart';
import '../models/reel_comment_model.dart';
import '../models/reel_model.dart';

class ReelsRepositoryImpl implements ReelsRepository {
  const ReelsRepositoryImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<Reel>> getReels() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/reels/feed',
      decode: _asMap,
    );

    final items = response['items'];
    if (items is! List) {
      return const [];
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(ReelModel.fromJson)
        .toList(growable: false);
  }

  @override
  Future<Reel> getReelById(String reelId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/reels/$reelId',
      decode: _asMap,
    );

    final payload = response['reel'];
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
      '/reels',
      data: {
        'videoUrl': videoUrl,
        'caption': caption,
        if (durationSeconds != null) 'durationSeconds': durationSeconds,
      },
      decode: _asMap,
    );

    final reel = response['reel'];
    if (reel is Map<String, dynamic>) {
      return ReelModel.fromJson(reel);
    }

    throw const FormatException('Response missing reel.');
  }

  @override
  Future<ReelReactionResult> likeReel(String reelId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/reels/$reelId/like',
      decode: _asMap,
    );

    return ReelReactionResult(
      reelId: response['reelId'] as String? ?? reelId,
      likeCount: response['likeCount'] as int? ?? 0,
      isLiked: response['isLiked'] as bool? ?? false,
    );
  }

  @override
  Future<ReelReactionResult> unlikeReel(String reelId) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      '/reels/$reelId/like',
      decode: _asMap,
    );

    return ReelReactionResult(
      reelId: response['reelId'] as String? ?? reelId,
      likeCount: response['likeCount'] as int? ?? 0,
      isLiked: response['isLiked'] as bool? ?? false,
    );
  }

  @override
  Future<void> deleteReel(String reelId) async {
    await _apiClient.delete<Map<String, dynamic>>(
      '/reels/$reelId',
      decode: _asMap,
    );
  }

  @override
  Future<List<ReelComment>> getComments(String reelId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/reels/$reelId/comments',
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
      '/reels/$reelId/comments',
      data: {'content': content},
      decode: _asMap,
    );

    final comment = response['comment'];
    if (comment is Map<String, dynamic>) {
      return ReelCommentModel.fromJson(comment);
    }

    throw const FormatException('Response missing reel comment.');
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    throw const FormatException('Expected a JSON object.');
  }
}
