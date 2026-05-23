import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/core/network/api_exception.dart';
import 'package:t_app/features/auth/data/auth_session.dart';

import '../../domain/entities/register_user.dart';
import '../../domain/usecases/register_user.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({required RegisterUser registerUser})
    : _registerUser = registerUser,
      super(const RegisterState());

  final RegisterUser _registerUser;

  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void togglePassword() {
    emit(state.copyWith(hidePassword: !state.hidePassword));
  }

  void setGender(String? value) {
    emit(state.copyWith(gender: value));
  }

  void setBirthday(DateTime value) {
    emit(state.copyWith(birthday: value));
  }

  Future<AuthSession?> register() async {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      emit(state.copyWith(errorMessage: 'Vui lòng nhập đầy đủ thông tin.'));
      return null;
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    final user = RegisterUserEntity(
      fullName: fullNameController.text.trim(),
      username: usernameController.text.trim(),
      gender: state.gender ?? 'unspecified',
      birthday: state.birthday ?? DateTime(1970, 1, 1),
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    try {
      final session = await _registerUser(user);
      emit(state.copyWith(isLoading: false, clearError: true));
      return session;
    } on ApiException catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.message));
      return null;
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Không thể tạo tài khoản. Vui lòng thử lại.',
        ),
      );
      return null;
    }
  }

  @override
  Future<void> close() {
    fullNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
