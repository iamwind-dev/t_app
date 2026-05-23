import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/core/network/api_client.dart';
import 'package:t_app/core/network/api_token_store.dart';

import '../../data/datasources/register_remote_data_source.dart';
import '../../data/repositories/register_repository_impl.dart';
import '../../domain/usecases/register_user.dart';
import '../cubit/register_cubit.dart';
import '../cubit/register_state.dart';
import 'add_profile_photo_screen.dart';
import '../widget/instagram_logo.dart';
import '../widget/primary_button.dart';
import '../widget/register_date_field.dart';
import '../widget/register_dropdown_field.dart';
import '../widget/register_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.cubit});

  final RegisterCubit cubit;

  factory RegisterScreen.withDependencies(BuildContext context, {Key? key}) {
    return RegisterScreen(
      key: key,
      cubit: RegisterCubit(
        registerUser: RegisterUser(
          RegisterRepositoryImpl(
            remoteDataSource: RegisterRemoteDataSourceImpl(
              apiClient: context.read<ApiClient>(),
              tokenStore: context.read<ApiTokenStore>(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _confirmPasswordController.dispose();
    widget.cubit.close();
    super.dispose();
  }

  Future<void> _submitRegister(BuildContext context) async {
    final cubit = context.read<RegisterCubit>();
    final session = await cubit.register();
    if (!mounted) {
      return;
    }

    if (session != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AddProfilePhotoScreen()),
      );
      return;
    }

    final message = cubit.state.errorMessage ?? 'Đăng ký thất bại. Vui lòng thử lại.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickBirthday() async {
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

    if (picked != null && mounted) {
      context.read<RegisterCubit>().setBirthday(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider.value(
      value: widget.cubit,
      child: BlocBuilder<RegisterCubit, RegisterState>(
        builder: (context, state) {
          final cubit = context.read<RegisterCubit>();

          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 18, 32, 24),
                child: Form(
                  key: cubit.formKey,
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
                        controller: cubit.fullNameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập họ và tên';
                          }
                          if (value.trim().length > 80) {
                            return 'Tên hiển thị tối đa 80 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      RegisterTextField(
                        hint: 'Tên người dùng',
                        controller: cubit.usernameController,
                        validator: (value) {
                          final username = value?.trim() ?? '';
                          if (username.isEmpty) {
                            return 'Vui lòng nhập tên người dùng';
                          }
                          if (username.length < 3 || username.length > 30) {
                            return 'Tên người dùng từ 3-30 ký tự';
                          }
                          if (!RegExp(r'^(?!\.)(?!.*\.$)[A-Za-z0-9_.]+$').hasMatch(username)) {
                            return 'Tên người dùng không hợp lệ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      // RegisterDropdownField(
                      //   hint: 'Giới tính',
                      //   value: state.gender,
                      //   items: const ['Nam', 'Nữ', 'Khác'],
                      //   onChanged: cubit.setGender,
                      // ),
                      // const SizedBox(height: 12),
                      // RegisterDateField(
                      //   value: state.birthday,
                      //   onTap: _pickBirthday,
                      // ),
                      // const SizedBox(height: 12),
                      RegisterTextField(
                        hint: 'Email',
                        controller: cubit.emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) {
                            return 'Vui lòng nhập email';
                          }
                          final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
                          if (!ok) {
                            return 'Email không hợp lệ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      RegisterTextField(
                        hint: 'Mật khẩu',
                        controller: cubit.passwordController,
                        obscureText: state.hidePassword,
                        suffixIcon: IconButton(
                          onPressed: cubit.togglePassword,
                          icon: Icon(
                            state.hidePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: colorScheme.onSurfaceVariant,
                            size: 21,
                          ),
                        ),
                        validator: (value) {
                          final password = value ?? '';
                          if (password.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          if (password.length < 8 || password.length > 72) {
                            return 'Mật khẩu từ 8-72 ký tự';
                          }
                          if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d).+$').hasMatch(password)) {
                            return 'Mật khẩu cần có chữ và số';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      RegisterTextField(
                        hint: 'Nhập lại mật khẩu',
                        controller: _confirmPasswordController,
                        obscureText: state.hidePassword,
                        suffixIcon: IconButton(
                          onPressed: cubit.togglePassword,
                          icon: Icon(
                            state.hidePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: colorScheme.onSurfaceVariant,
                            size: 21,
                          ),
                        ),
                        validator: (value) {
                          if ((value ?? '') != cubit.passwordController.text) {
                            return 'Mật khẩu nhập lại không khớp';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      PrimaryButton(
                        text: state.isLoading ? 'Đang đăng ký...' : 'Đăng ký',
                        onPressed: state.isLoading ? null : () => _submitRegister(context),
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
        },
      ),
    );
  }
}
