import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/core/network/api_exception.dart';
import 'package:t_app/features/activity/data/models/activity_item_model.dart';
import 'package:t_app/features/activity/domain/notifications_activity_repository.dart';
import 'package:t_app/features/users/domain/users_profile_repository.dart';

import 'activity_state.dart';

class ActivityCubit extends Cubit<ActivityState> {
  ActivityCubit({
    required NotificationsActivityRepository notificationsRepository,
    required UsersProfileRepository usersRepository,
  }) : _notificationsRepository = notificationsRepository,
       _usersRepository = usersRepository,
      super(const ActivityState());

  final NotificationsActivityRepository _notificationsRepository;
  final UsersProfileRepository _usersRepository;

  Future<void> loadNotifications() async {
    emit(state.copyWith(status: ActivityStatus.loading, clearError: true));

    try {
      final page = await _notificationsRepository.listNotifications();
      emit(
        ActivityState(
          status: ActivityStatus.loaded,
          items: page.items
              .map((item) => item.toActivityItem())
              .toList(growable: false),
          nextCursor: page.pageInfo.nextCursor,
          hasNextPage: page.pageInfo.hasNextPage,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          status: ActivityStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ActivityStatus.failure,
          errorMessage: 'Unable to load activity.',
        ),
      );
    }
  }

  Future<void> toggleFollow(ActivityItemModel item) async {
    if (item.type != ActivityItemType.followSuggestion) {
      return;
    }

    final userId = item.targetId ?? item.user.id;
    try {
      final profile = item.isFollowed
          ? await _usersRepository.unfollowUser(userId)
          : await _usersRepository.followUser(userId);
      emit(
        state.copyWith(
          items: state.items
              .map(
                (current) => current.id == item.id
                    ? current.copyWith(isFollowed: profile.isFollowing)
                    : current,
              )
              .toList(growable: false),
          clearError: true,
        ),
      );
    } on ApiException catch (error) {
      emit(state.copyWith(errorMessage: error.message));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Unable to update follow.'));
    }
  }
}
