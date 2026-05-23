import 'package:flutter/material.dart';
import 'package:t_app/generated/assets.gen.dart';

class InstagramLogo extends StatelessWidget {
  const InstagramLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Assets.icons.logo.svg(
      width: 72,
      height: 72,
    );
  }
}
