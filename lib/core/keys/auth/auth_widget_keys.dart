import 'package:flutter/widgets.dart';

@immutable
final class AuthWidgetKeys {
  const AuthWidgetKeys._();

  static const usernameField = Key('auth_username_field');
  static const passwordField = Key('auth_password_field');
  static const loginButton = Key('auth_login_button');
}
