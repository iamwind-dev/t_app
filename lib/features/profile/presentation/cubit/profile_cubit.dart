import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/core/config/app_config.dart';
import 'package:t_app/core/demo/demo_data.dart';
import 'package:t_app/core/network/api_exception.dart';
import 'package:t_app/core/realtime/realtime_event_bus.dart';
import 'package:t_app/features/profile/data/profile_mock_data.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/users/domain/users_profile_repository.dart';

import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required UsersProfileRepository repository})
    : _repository = repository,
      super(const ProfileState()) {
    _realtimeSubscription = RealtimeEventBus.instance.stream.listen(
      _handleRealtimeEvent,
    );
  }

  final UsersProfileRepository _repository;
  late final StreamSubscription<RealtimeAppEvent> _realtimeSubscription;

  Future<void> loadProfile(String userId) async {
    if (AppConfig.uiPreviewMode) {
      emit(
        const ProfileState(
          status: ProfileStatus.loaded,
          profile: DemoData.currentProfile,
          threads: profileThreads,
        ),
      );
      return;
    }

    emit(const ProfileState(status: ProfileStatus.loading));

    try {
      final profile = await _repository.getProfileById(userId);
      final postsPage = await _repository.getUserPosts(userId);

      emit(
        ProfileState(
          status: ProfileStatus.loaded,
          profile: profile,
          threads: postsPage.items,
        ),
      );
    } on ApiException catch (error) {
      emit(
        ProfileState(
          status: ProfileStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        const ProfileState(
          status: ProfileStatus.failure,
          errorMessage: 'Không thể tải hồ sơ.',
        ),
      );
    }
  }

  Future<void> loadUserPosts(String userId) async {
    try {
      final postsPage = await _repository.getUserPosts(userId);
      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          threads: postsPage.items,
          clearError: true,
        ),
      );
    } on ApiException catch (error) {
      emit(state.copyWith(errorMessage: error.message));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Không thể tải bài viết hồ sơ.'));
    }
  }

  Future<void> updateProfile({
    required String displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    if (AppConfig.uiPreviewMode) {
      final current = state.profile ?? DemoData.currentProfile;
      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          profile: current.copyWith(
            displayName: displayName,
            bio: bio,
            avatarUrl: avatarUrl,
          ),
          isSaving: false,
          clearError: true,
        ),
      );
      return;
    }

    emit(state.copyWith(isSaving: true, clearError: true));

    try {
      final profile = await _repository.updateMe(
        displayName: displayName,
        bio: bio,
        avatarUrl: avatarUrl,
      );

      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          profile: profile,
          isSaving: false,
          clearError: true,
        ),
      );
    } on ApiException catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: error.message));
    } catch (_) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Không thể cập nhật hồ sơ.',
        ),
      );
    }
  }

  Future<void> followUser(String userId) async {
    if (AppConfig.uiPreviewMode) {
      final current = state.profile ?? DemoData.searchProfile;
      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          profile: current.copyWith(isFollowing: true),
          isFollowUpdating: false,
          clearError: true,
        ),
      );
      return;
    }

    emit(state.copyWith(isFollowUpdating: true, clearError: true));

    try {
      final profile = await _repository.followUser(userId);
      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          profile: profile,
          isFollowUpdating: false,
          clearError: true,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(isFollowUpdating: false, errorMessage: error.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isFollowUpdating: false,
          errorMessage: 'Không thể theo dõi người dùng.',
        ),
      );
    }
  }

  Future<void> unfollowUser(String userId) async {
    if (AppConfig.uiPreviewMode) {
      final current = state.profile ?? DemoData.searchProfile;
      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          profile: current.copyWith(isFollowing: false),
          isFollowUpdating: false,
          clearError: true,
        ),
      );
      return;
    }

    emit(state.copyWith(isFollowUpdating: true, clearError: true));

    try {
      final profile = await _repository.unfollowUser(userId);
      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          profile: profile,
          isFollowUpdating: false,
          clearError: true,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(isFollowUpdating: false, errorMessage: error.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isFollowUpdating: false,
          errorMessage: 'Không thể bỏ theo dõi người dùng.',
        ),
      );
    }
  }

  void _handleRealtimeEvent(RealtimeAppEvent event) {
    if (event.type != 'user.profile.updated') {
      return;
    }

    final currentProfile = state.profile;
    if (currentProfile == null) {
      return;
    }

    final userId = event.payload['userId'] as String?;
    if (userId == null || userId != currentProfile.id) {
      return;
    }

    final displayName = event.payload['displayName'] as String?;
    final username = event.payload['username'] as String?;
    final avatarUrl = event.payload['avatarUrl'] as String?;

    final nextProfile = currentProfile.copyWith(
      displayName: displayName ?? currentProfile.displayName,
      username: username ?? currentProfile.username,
      avatarUrl: avatarUrl ?? currentProfile.avatarUrl,
    );

    emit(
      state.copyWith(
        profile: nextProfile,
        threads: state.threads
            .map(
              (thread) => _patchThreadAuthor(
                thread,
                userId: userId,
                displayName: displayName,
                username: username,
                avatarUrl: avatarUrl,
              ),
            )
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
