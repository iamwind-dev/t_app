import 'package:equatable/equatable.dart';

import 'reel.dart';

class ReelsFeedChunk extends Equatable {
  const ReelsFeedChunk({
    required this.reels,
    required this.nextCursor,
    required this.hasNextPage,
  });

  final List<Reel> reels;
  final String? nextCursor;
  final bool hasNextPage;

  @override
  List<Object?> get props => [reels, nextCursor, hasNextPage];
}
