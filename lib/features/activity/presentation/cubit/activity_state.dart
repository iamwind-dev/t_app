import 'package:equatable/equatable.dart';
import 'package:t_app/features/activity/data/models/activity_item_model.dart';

enum ActivityStatus { initial, loading, loaded, failure }

class ActivityState extends Equatable {
  const ActivityState({
    this.status = ActivityStatus.initial,
    this.items = const [],
    this.nextCursor,
    this.hasNextPage = false,
    this.errorMessage,
  });

  final ActivityStatus status;
  final List<ActivityItemModel> items;
  final String? nextCursor;
  final bool hasNextPage;
  final String? errorMessage;

  ActivityState copyWith({
    ActivityStatus? status,
    List<ActivityItemModel>? items,
    String? nextCursor,
    bool? hasNextPage,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ActivityState(
      status: status ?? this.status,
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    nextCursor,
    hasNextPage,
    errorMessage,
  ];
}
