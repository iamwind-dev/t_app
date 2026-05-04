import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:t_app/core/keys/auth/auth_widget_keys.dart';
import 'package:t_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_app/features/auth/presentation/theme/login_tokens.dart';
import 'package:t_app/generated/assets.gen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pageBackground = LoginTokens.pageBackground(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: pageBackground,
        systemNavigationBarColor: pageBackground,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: pageBackground,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final verticalScale = math.min(
                constraints.maxHeight / LoginTokens.designHeight,
                1.0,
              );

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: _LoginContent(verticalScale: verticalScale),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoginContent extends StatelessWidget {
  const _LoginContent({required this.verticalScale});

  final double verticalScale;

  @override
  Widget build(BuildContext context) {
    final formWidth = LoginTokens.formWidth(context);
    final safeTop = MediaQuery.paddingOf(context).top;

    return Stack(
      children: [
        Positioned(
          top: _scaledTop(LoginTokens.languageTop, safeTop),
          left: 0,
          right: 0,
          child: Text(
            'English (US)',
            textAlign: TextAlign.center,
            style: LoginTokens.language(context),
          ),
        ),
        Positioned(
          top: _scaledTop(LoginTokens.logoTop, safeTop),
          left: 0,
          right: 0,
          child: const Center(child: _InstagramLogo()),
        ),
        Positioned(
          top: _scaledTop(LoginTokens.formTop, safeTop),
          left: (MediaQuery.sizeOf(context).width - formWidth) / 2,
          width: formWidth,
          child: const _LoginForm(),
        ),
        Positioned(
          top: _scaledTop(LoginTokens.metaTop, safeTop),
          left: 0,
          right: 0,
          child: const Center(child: _MetaLogo()),
        ),
      ],
    );
  }

  double _scaledTop(double designTop, double safeTop) {
    return math.max(0, designTop * verticalScale - safeTop);
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  late final TextEditingController _identifierController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _identifierController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().login(
      identifier: _identifierController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;

        return Column(
          children: [
            _LoginTextField(
              key: AuthWidgetKeys.usernameField,
              controller: _identifierController,
              hintText: 'Username, email or mobile number',
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              enabled: !isLoading,
            ),
            const SizedBox(height: LoginTokens.formGap),
            _LoginTextField(
              key: AuthWidgetKeys.passwordField,
              controller: _passwordController,
              hintText: 'Password',
              obscureText: true,
              textInputAction: TextInputAction.done,
              enabled: !isLoading,
              onSubmitted: (_) => _submit(),
            ),
            if (state.status == AuthStatus.failure &&
                state.errorMessage != null) ...[
              const SizedBox(height: LoginTokens.formGap),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: LoginTokens.input(
                  context,
                ).copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: LoginTokens.formGap),
            _LoginButton(
              isLoading: isLoading,
              onPressed: isLoading ? null : _submit,
            ),
          ],
        );
      },
    );
  }
}

class _LoginTextField extends StatelessWidget {
  const _LoginTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.textInputAction,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: LoginTokens.fieldBorderRadius,
      borderSide: BorderSide(color: LoginTokens.fieldBorder(context)),
    );

    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: LoginTokens.input(context),
      cursorColor: LoginTokens.buttonBackground(context),
      decoration: InputDecoration(
        filled: true,
        fillColor: LoginTokens.fieldBackground(context),
        hintText: hintText,
        hintStyle: LoginTokens.input(context),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: LoginTokens.fieldHorizontalPadding,
          vertical: LoginTokens.fieldVerticalPadding,
        ),
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        key: AuthWidgetKeys.loginButton,
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: LoginTokens.buttonBackground(context),
          foregroundColor: LoginTokens.buttonForeground(context),
          padding: const EdgeInsets.all(LoginTokens.buttonPadding),
          shape: const RoundedRectangleBorder(
            borderRadius: LoginTokens.buttonBorderRadius,
          ),
          textStyle: LoginTokens.button(context),
        ),
        child: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: LoginTokens.buttonForeground(context),
                ),
              )
            : Text('Log in', style: LoginTokens.button(context)),
      ),
    );
  }
}

class _InstagramLogo extends StatelessWidget {
  const _InstagramLogo();

  @override
  Widget build(BuildContext context) {
    return Assets.images.login.loginInstagramLogo.svg(
      width: LoginTokens.instagramLogoSize,
      height: LoginTokens.instagramLogoSize,
    );
  }
}

class _MetaLogo extends StatelessWidget {
  const _MetaLogo();

  @override
  Widget build(BuildContext context) {
    return Assets.images.login.loginMetaLogo.svg(
      width: LoginTokens.metaWidth,
      height: LoginTokens.metaHeight,
    );
  }
}
