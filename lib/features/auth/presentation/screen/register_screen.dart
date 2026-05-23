import 'package:flutter/material.dart';
import 'package:t_app/features/register/presentation/screen/register_screen.dart' as register_feature;

@Deprecated('Use features/register/presentation/screen/register_screen.dart')
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return register_feature.RegisterScreen.withDependencies(context);
  }
}