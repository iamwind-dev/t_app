import 'package:equatable/equatable.dart';

class Reel extends Equatable {
  final String id;
  final String videoUrl;
  final String authorId;
  final String username;
  final String displayName;
  final String caption;
  final String music;
  final String? avatarUrl;
  final int likes;
  final int comments;
  final bool isLiked;

  const Reel({
    required this.id,
    required this.videoUrl,
    required this.authorId,
    required this.username,
    required this.displayName,
    required this.caption,
    required this.music,
    required this.avatarUrl,
    required this.likes,
    required this.comments,
    required this.isLiked,
  });

  Reel copyWith({
    String? id,
    String? videoUrl,
    String? authorId,
    String? username,
    String? displayName,
    String? caption,
    String? music,
    String? avatarUrl,
    bool clearAvatarUrl = false,
    int? likes,
    int? comments,
    bool? isLiked,
  }) {
    return Reel(
      id: id ?? this.id,
      videoUrl: videoUrl ?? this.videoUrl,
      authorId: authorId ?? this.authorId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      caption: caption ?? this.caption,
      music: music ?? this.music,
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  List<Object?> get props => [
        id,
        videoUrl,
        authorId,
        username,
        displayName,
        caption,
        music,
        avatarUrl,
        likes,
        comments,
        isLiked,
      ];
}
