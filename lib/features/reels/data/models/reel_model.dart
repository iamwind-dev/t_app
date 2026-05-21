import '../../domain/entities/reel.dart';

class ReelModel extends Reel {
  const ReelModel({
    required super.id,
    required super.videoUrl,
    required super.username,
    required super.caption,
    required super.music,
    required super.avatarUrl,
    required super.likes,
    required super.comments,
    required super.isLiked,
  });

  factory ReelModel.fromJson(Map<String, dynamic> json) {
    return ReelModel(
      id: json['id'] as String,
      videoUrl: json['videoUrl'] as String,
      username: json['username'] as String,
      caption: json['caption'] as String,
      music: json['music'] as String,
      avatarUrl: json['avatarUrl'] as String,
      likes: json['likes'] as int,
      comments: json['comments'] as int,
      isLiked: json['isLiked'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoUrl': videoUrl,
      'username': username,
      'caption': caption,
      'music': music,
      'avatarUrl': avatarUrl,
      'likes': likes,
      'comments': comments,
      'isLiked': isLiked,
    };
  }
}