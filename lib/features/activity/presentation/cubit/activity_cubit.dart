import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/core/config/app_config.dart';
import 'package:t_app/core/network/api_exception.dart';
import 'package:t_app/core/realtime/realtime_event_bus.dart';
import 'package:t_app/features/activity/data/mock_activity_data.dart';
import 'package:t_app/features/activity/data/models/activity_item_model.dart';
import 'package:t_app/features/activity/domain/notifications_activity_repository.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/users/domain/users_profile_repository.dart';

import 'activity_state.dart';

class ActivityCubit extends Cubit<ActivityState> {
  ActivityCubit({
    required NotificationsActivityRepository notificationsRepository,
    required UsersProfileRepository usersRepository,
  }) : _notificationsRepository = notificationsRepository,
       _usersRepository = usersRepository,
       super(const ActivityState()) {
    _realtimeSubscription = RealtimeEventBus.instance.stream.listen(
      _handleRealtimeEvent,
    );
  }

  final NotificationsActivityRepository _notificationsRepository;
  final UsersProfileRepository _usersRepository;
  late final StreamSubscription<RealtimeAppEvent> _realtimeSubscription;

  /// Loads notifications and the current unread count from the backend.
  Future<void> loadNotifications() async {
    if (AppConfig.uiPreviewMode) {
      emit(
        const ActivityState(
          status: ActivityStatus.loaded,
          items: activityItems,
        ),
      );
      return;
    }

    emit(state.copyWith(status: ActivityStatus.loading, clearError: true));

    try {
      final page = await _notificationsRepository.listNotifications();
      final unreadCount = await _notificationsRepository.getUnreadCount();
      emit(
        ActivityState(
          status: ActivityStatus.loaded,
          items: page.items
              .map((item) => item.toActivityItem())
              .toList(growable: false),
          nextCursor: page.pageInfo.nextCursor,
          hasNextPage: page.pageInfo.hasNextPage,
          unreadCount: unreadCount,
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
          errorMessage: 'Không thể tải hoạt động.',
        ),
      );
    }
  }

  /// Marks one notification as read and decrements the local unread badge.
  Future<void> markAsRead(String notificationId) async {
    if (AppConfig.uiPreviewMode) {
      return;
    }

    ActivityItemModel? current;
    for (final item in state.items) {
      if (item.id == notificationId) {
        current = item;
        break;
      }
    }
    if (current == null || current.isRead) {
      return;
    }

    try {
      await _notificationsRepository.markAsRead(notificationId);
      emit(
        state.copyWith(
          items: state.items
              .map(
                (item) => item.id == notificationId
                    ? item.copyWith(isRead: true)
                    : item,
              )
              .toList(growable: false),
          unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
          clearError: true,
        ),
      );
    } on ApiException catch (error) {
      emit(state.copyWith(errorMessage: error.message));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Khong the cap nhat thong bao.'));
    }
  }

  /// Marks all currently listed notifications as read through the API.
  Future<void> markAllAsRead() async {
    if (AppConfig.uiPreviewMode || state.unreadCount == 0) {
      return;
    }

    emit(state.copyWith(isMarkingAllRead: true, clearError: true));

    try {
      await _notificationsRepository.markAllAsRead();
      emit(
        state.copyWith(
          items: state.items
              .map((item) => item.copyWith(isRead: true))
              .toList(growable: false),
          unreadCount: 0,
          isMarkingAllRead: false,
          clearError: true,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(isMarkingAllRead: false, errorMessage: error.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isMarkingAllRead: false,
          errorMessage: 'Khong the danh dau da doc.',
        ),
      );
    }
  }

  /// Toggles follow state for a follow suggestion item.
  Future<void> toggleFollow(ActivityItemModel item) async {
    if (item.type != ActivityItemType.followSuggestion) {
      return;
    }

    if (AppConfig.uiPreviewMode) {
      emit(
        state.copyWith(
          items: state.items
              .map(
                (current) => current.id == item.id
                    ? current.copyWith(isFollowed: !current.isFollowed)
                    : current,
              )
              .toList(growable: false),
          clearError: true,
        ),
      );
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
      emit(state.copyWith(errorMessage: 'Không thể cập nhật theo dõi.'));
    }
  }

  void _handleRealtimeEvent(RealtimeAppEvent event) {
    if (event.type != 'user.profile.updated') {
      return;
    }

    final userId = event.payload['userId'] as String?;
    if (userId == null || userId.isEmpty) {
      return;
    }

    final displayName = event.payload['displayName'] as String?;
    final username = event.payload['username'] as String?;
    final avatarUrl = event.payload['avatarUrl'] as String?;

    emit(
      state.copyWith(
        items: state.items
            .map((item) {
              final nextThread = item.thread == null
                  ? null
                  : _patchThreadAuthor(
                      item.thread!,
                      userId: userId,
                      displayName: displayName,
                      username: username,
                      avatarUrl: avatarUrl,
                    );
              if (item.user.id != userId && nextThread == item.thread) {
                return item;
              }

              final nextUser = item.user.id == userId
                  ? item.user.copyWith(
                      name: displayName ?? item.user.name,
                      username: username ?? item.user.username,
                      avatarUrl: avatarUrl ?? item.user.avatarUrl,
                      avatarAssetPath: avatarUrl != null
                          ? null
                          : item.user.avatarAssetPath,
                    )
                  : item.user;

              return item.copyWith(user: nextUser, thread: nextThread);
            })
            .toList(growable: false),
      ),
    );
  }

  ThreadItemModel _patchThreadAuthor(
    ThreadItemModel thread, {
    required String userId,
    String? displayName,
    String? username,
    String? avatarUrl,
  }) {
    final nextChildren = thread.children
        .map(
          (child) => _patchThreadAuthor(
            child,
            userId: userId,
            displayName: displayName,
            username: username,
            avatarUrl: avatarUrl,
          ),
        )
        .toList(growable: false);
    final nextPreviews = thread.previewReplies
        .map(
          (child) => _patchThreadAuthor(
            child,
            userId: userId,
            displayName: displayName,
            username: username,
            avatarUrl: avatarUrl,
          ),
        )
        .toList(growable: false);

    if (thread.author.id != userId) {
      return thread.copyWith(children: nextChildren, previewReplies: nextPreviews);
    }

    final nextAuthor = thread.author.copyWith(
      name: displayName ?? thread.author.name,
      username: username ?? thread.author.username,
      avatarUrl: avatarUrl ?? thread.author.avatarUrl,
      avatarAssetPath: avatarUrl != null ? null : thread.author.avatarAssetPath,
    );

    return thread.copyWith(
      author: nextAuthor,
      children: nextChildren,
      previewReplies: nextPreviews,
    );
  }

  @override
  Future<void> close() async {
    await _realtimeSubscription.cancel();
    return super.close();
  }
}
