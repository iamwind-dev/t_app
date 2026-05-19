import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/core/config/app_config.dart';
import 'package:t_app/core/demo/demo_data.dart';
import 'package:t_app/core/network/api_exception.dart';
import 'package:t_app/features/users/domain/users_profile_repository.dart';

import 'search_users_state.dart';

class SearchUsersCubit extends Cubit<SearchUsersState> {
  SearchUsersCubit({required UsersProfileRepository repository})
    : _repository = repository,
      super(const SearchUsersState());

  final UsersProfileRepository _repository;

  Future<void> searchByUsername(String rawUsername) async {
    final username = rawUsername.trim();
    if (username.isEmpty) {
      emit(const SearchUsersState(status: SearchUsersStatus.initial));
      return;
    }

    if (AppConfig.uiPreviewMode) {
      emit(
        SearchUsersState(
          status: SearchUsersStatus.loaded,
          query: username,
          result: DemoData.searchProfile,
        ),
      );
      return;
    }

    emit(SearchUsersState(status: SearchUsersStatus.loading, query: username));

    try {
      final profile = await _repository.getProfileByUsername(username);
      emit(
        SearchUsersState(
          status: SearchUsersStatus.loaded,
          query: username,
          result: profile,
        ),
      );
    } on ApiException catch (error) {
      emit(
        SearchUsersState(
          status: SearchUsersStatus.failure,
          query: username,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        SearchUsersState(
          status: SearchUsersStatus.failure,
          query: username,
          errorMessage: 'Không thể tìm kiếm người dùng.',
        ),
      );
    }
  }

  Future<void> toggleFollow() async {
    final profile = state.result;
    if (profile == null || state.isUpdatingFollow) {
      return;
    }

    if (AppConfig.uiPreviewMode) {
      emit(
        state.copyWith(
          status: SearchUsersStatus.loaded,
          result: profile.copyWith(isFollowing: !profile.isFollowing),
          clearError: true,
        ),
      );
      return;
    }

    emit(state.copyWith(isUpdatingFollow: true, clearError: true));

    try {
      final updatedProfile = profile.isFollowing
          ? await _repository.unfollowUser(profile.id)
          : await _repository.followUser(profile.id);
      emit(
        state.copyWith(
          status: SearchUsersStatus.loaded,
          result: updatedProfile,
          isUpdatingFollow: false,
          clearError: true,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(isUpdatingFollow: false, errorMessage: error.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isUpdatingFollow: false,
          errorMessage: 'Không thể cập nhật theo dõi.',
        ),
      );
    }
  }
}
