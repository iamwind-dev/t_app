import '../entities/reel.dart';

abstract class ReelsRepository {
  Future<List<Reel>> getReels();
}