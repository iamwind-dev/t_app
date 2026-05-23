import '../models/reel_model.dart';

abstract class ReelsLocalDataSource {
  Future<List<ReelModel>> getReels();
}

class ReelsLocalDataSourceImpl implements ReelsLocalDataSource {
  @override
  Future<List<ReelModel>> getReels() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return const [
      ReelModel(
        id: '1',
        videoUrl:
            'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        authorId: 'user_1',
        username: 'hiep.nguyen',
        displayName: 'Hiep Nguyen',
        caption: 'A small local demo reel.',
        music: 'Original audio - hiep.nguyen',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
        likes: 12500,
        comments: 328,
        isLiked: false,
      ),
      ReelModel(
        id: '2',
        videoUrl:
            'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
        authorId: 'user_2',
        username: 'flutter.dev',
        displayName: 'Flutter',
        caption: 'Another local demo reel.',
        music: 'Trending sound',
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
        likes: 8930,
        comments: 194,
        isLiked: false,
      ),
    ];
  }
}
