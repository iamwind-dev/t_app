import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/core/config/app_config.dart';
import 'package:t_app/core/demo/demo_data.dart';
import 'package:t_app/core/network/api_exception.dart';
import 'package:t_app/features/profile/data/profile_mock_data.dart';
import 'package:t_app/features/users/domain/users_profile_repository.dart';

import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required UsersProfileRepository repository})
    : _repository = repository,
      super(const ProfileState());

  final UsersProfileRepository _repository;

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
}
