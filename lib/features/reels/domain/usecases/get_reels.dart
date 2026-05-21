

import '../entities/reel.dart';
import '../repositories/reels_repository.dart';

class GetReels {
  final ReelsRepository repository;

  GetReels(this.repository);

  Future<List<Reel>> call() {
    return repository.getReels();
  }
}