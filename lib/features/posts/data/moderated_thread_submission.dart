import 'package:equatable/equatable.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';

import 'moderation_result.dart';

class ModeratedThreadSubmission extends Equatable {
  const ModeratedThreadSubmission({this.thread, this.moderation});

  final ThreadItemModel? thread;
  final ModerationResult? moderation;

  @override
  List<Object?> get props => [thread, moderation];
}
