import '../../domain/entities/reel.dart';
import '../../domain/repositories/reels_repository.dart';
import '../datasources/reels_local_data_source.dart';

class ReelsRepositoryImpl implements ReelsRepository {
  final ReelsLocalDataSource localDataSource;

  ReelsRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<List<Reel>> getReels() async {
    return localDataSource.getReels();
  }
}