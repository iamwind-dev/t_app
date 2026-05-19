import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/core/config/app_config.dart';
import 'package:t_app/core/demo/demo_data.dart';
import 'package:t_app/core/network/api_exception.dart';
import 'package:t_app/features/auth/data/auth_user.dart';
import 'package:t_app/features/auth/domain/auth_session_repository.dart';
import 'package:t_app/features/users/data/user_profile.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthSessionRepository repository})
    : _repository = repository,
      super(const AuthState());

  final AuthSessionRepository _repository;

  Future<void> checkSession() async {
    if (AppConfig.uiPreviewMode) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return;
    }

    emit(const AuthState(status: AuthStatus.checking));

    try {
      final user = await _repository.loadCurrentUser();
      if (user == null) {
        emit(const AuthState(status: AuthStatus.unauthenticated));
        return;
      }

      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } catch (_) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    if (AppConfig.uiPreviewMode) {
      emit(
        const AuthState(
          status: AuthStatus.authenticated,
          user: DemoData.currentUser,
        ),
      );
      return;
    }

    emit(const AuthState(status: AuthStatus.loading));

    try {
      final session = await _repository.login(
        identifier: identifier,
        password: password,
      );
      emit(AuthState(status: AuthStatus.authenticated, user: session.user));
    } on ApiException catch (error) {
      emit(AuthState(status: AuthStatus.failure, errorMessage: error.message));
    } catch (_) {
      emit(
        const AuthState(
          status: AuthStatus.failure,
          errorMessage: 'Không thể đăng nhập. Vui lòng thử lại.',
        ),
      );
    }
  }

  Future<void> logOut() async {
    await _repository.logOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void replaceUserProfile(UserProfile profile) {
    final currentUser = state.user;
    if (currentUser == null || currentUser.id != profile.id) {
      return;
    }

    emit(
      state.copyWith(
        user: AuthUser(
          id: currentUser.id,
          email: currentUser.email,
          username: profile.username,
          displayName: profile.displayName,
          avatarUrl: profile.avatarUrl,
        ),
        clearError: true,
      ),
    );
  }
}
