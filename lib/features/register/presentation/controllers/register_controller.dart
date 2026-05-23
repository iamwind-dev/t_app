import 'package:flutter/material.dart';

import '../../../auth/data/auth_session.dart';
import '../../domain/entities/register_user.dart';
import '../../domain/usecases/register_user.dart';

class RegisterController extends ChangeNotifier {
  final RegisterUser registerUser;

  RegisterController({required this.registerUser});

  final formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? gender;
  DateTime? birthday;

  bool hidePassword = true;
  bool isLoading = false;
  String? errorMessage;

  void togglePassword() {
    hidePassword = !hidePassword;
    notifyListeners();
  }

  void setGender(String? value) {
    gender = value;
    notifyListeners();
  }

  void setBirthday(DateTime value) {
    birthday = value;
    notifyListeners();
  }

  Future<AuthSession?> register() async {
    final isValid = formKey.currentState?.validate() ?? false;

    if (!isValid) {
      errorMessage = 'Vui lòng nhập đầy đủ thông tin.';
      notifyListeners();
      return null;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final user = RegisterUserEntity(
      fullName: fullNameController.text.trim(),
      username: usernameController.text.trim(),
      gender: gender ?? 'unspecified',
      birthday: birthday ?? DateTime(1970, 1, 1),
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    try {
      final result = await registerUser(user);
      return result;
    } catch (_) {
      errorMessage = 'Không thể tạo tài khoản. Vui lòng thử lại.';
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
