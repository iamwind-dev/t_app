import 'package:equatable/equatable.dart';

class Reel extends Equatable {
  final String id;
  final String videoUrl;
  final String username;
  final String caption;
  final String music;
  final String avatarUrl;
  final int likes;
  final int comments;
  final bool isLiked;

  const Reel({
    required this.id,
    required this.videoUrl,
    required this.username,
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
    String? username,
    String? caption,
    String? music,
    String? avatarUrl,
    int? likes,
    int? comments,
    bool? isLiked,
  }) {
    return Reel(
      id: id ?? this.id,
      videoUrl: videoUrl ?? this.videoUrl,
      username: username ?? this.username,
      caption: caption ?? this.caption,
      music: music ?? this.music,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  List<Object?> get props => [
        id,
        videoUrl,
        username,
        caption,
        music,
        avatarUrl,
        likes,
        comments,
        isLiked,
      ];
}