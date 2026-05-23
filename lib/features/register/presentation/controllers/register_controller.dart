import 'package:flutter/material.dart';

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

  Future<bool> register() async {
    final isValid = formKey.currentState?.validate() ?? false;

    if (!isValid || gender == null || birthday == null) {
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();

    final user = RegisterUserEntity(
      fullName: fullNameController.text.trim(),
      username: usernameController.text.trim(),
      gender: gender!,
      birthday: birthday!,
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    final result = await registerUser(user);

    isLoading = false;
    notifyListeners();

    return result;
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
