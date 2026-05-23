import 'package:equatable/equatable.dart';

import '../../domain/entities/reel.dart';

abstract class ReelsState extends Equatable {
  const ReelsState();

  @override
  List<Object?> get props => [];
}

class ReelsInitial extends ReelsState {
  const ReelsInitial();
}

class ReelsLoading extends ReelsState {
  const ReelsLoading();
}

class ReelsLoaded extends ReelsState {
  final List<Reel> reels;

  const ReelsLoaded(this.reels);

  @override
  List<Object?> get props => [reels];
}

class ReelsError extends ReelsState {
  final String message;

  const ReelsError(this.message);

  @override
  List<Object?> get props => [message];
}