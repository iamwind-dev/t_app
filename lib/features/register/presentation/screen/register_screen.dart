import 'package:flutter/material.dart';

import '../../data/datasources/register_local_data_source.dart';
import '../../data/repositories/register_repository_impl.dart';
import '../../domain/usecases/register_user.dart';
import '../controllers/register_controller.dart';
import '../screen/add_profile_photo_screen.dart';
import '../widget/instagram_logo.dart';
import '../widget/primary_button.dart';
import '../widget/register_date_field.dart';
import '../widget/register_dropdown_field.dart';
import '../widget/register_text_field.dart';

class RegisterScreen extends StatefulWidget {
  final RegisterController controller;

  const RegisterScreen({
    super.key,
    required this.controller,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();

  factory RegisterScreen.withDependencies({Key? key}) {
    return RegisterScreen(
      key: key,
      controller: RegisterController(
        registerUser: RegisterUser(
          RegisterRepositoryImpl(
            localDataSource: RegisterLocalDataSourceImpl(),
          ),
        ),
      ),
    );
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final RegisterController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> pickBirthday() async {
    final now = DateTime.now();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: 'Chọn ngày sinh',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              brightness: colorScheme.brightness,
              seedColor: Colors.blue,
            ).copyWith(
              primary: Colors.blue,
              surface: isDark ? const Color(0xFF111111) : colorScheme.surface,
              onSurface: colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.setBirthday(picked);
    }
  }

  Future<void> submitRegister() async {
    final success = await controller.register();

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AddProfilePhotoScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ thông tin'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 18, 32, 24),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                const SizedBox(height: 18),
                Text(
                  'Tiếng Việt',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 54),
                const InstagramLogo(),
                const SizedBox(height: 54),
                RegisterTextField(
                  hint: 'Họ và tên',
                  controller: controller.fullNameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập họ và tên';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                RegisterTextField(
                  hint: 'Tên người dùng',
                  controller: controller.usernameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên người dùng';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                RegisterDropdownField(
                  hint: 'Giới tính',
                  value: controller.gender,
                  items: const ['Nam', 'Nữ', 'Khác'],
                  onChanged: controller.setGender,
                ),
                const SizedBox(height: 12),
                RegisterDateField(
                  value: controller.birthday,
                  onTap: pickBirthday,
                ),
                const SizedBox(height: 12),
                RegisterTextField(
                  hint: 'Email',
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) return 'Vui lòng nhập email';
                    if (!email.contains('@')) return 'Email không hợp lệ';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                RegisterTextField(
                  hint: 'Mật khẩu',
                  controller: controller.passwordController,
                  obscureText: controller.hidePassword,
                  suffixIcon: IconButton(
                    onPressed: controller.togglePassword,
                    icon: Icon(
                      controller.hidePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: colorScheme.onSurfaceVariant,
                      size: 21,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                PrimaryButton(
                  text: controller.isLoading ? 'Đang đăng ký...' : 'Đăng ký',
                  onPressed: controller.isLoading ? null : submitRegister,
                ),
                const SizedBox(height: 22),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Tôi có tài khoản rồi',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
