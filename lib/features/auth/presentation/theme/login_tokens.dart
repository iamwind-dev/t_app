import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:t_app/generated/fonts.gen.dart';

@immutable
final class LoginTokens {
  const LoginTokens._();

  static const double designWidth = 393;
  static const double designHeight = 852;

  static const double horizontalPadding = 16;
  static const double languageTop = 70;
  static const double logoTop = 188;
  static const double instagramLogoSize = 72;
  static const double formTop = 403;
  static const double formGap = 16;
  static const double fieldWidth = 358;
  static const double fieldHorizontalPadding = 16;
  static const double fieldVerticalPadding = 24;
  static const double fieldRadius = 10;
  static const double buttonPadding = 16;
  static const double buttonRadius = 50;
  static const double metaTop = 802;
  static const double metaWidth = 66;
  static const double metaHeight = 13.3;

  static const BorderRadius fieldBorderRadius = BorderRadius.all(
    Radius.circular(fieldRadius),
  );

  static const BorderRadius buttonBorderRadius = BorderRadius.all(
    Radius.circular(buttonRadius),
  );

  static Color pageBackground(BuildContext context) {
    return const Color(0xFF0D0D0D);
  }

  static Color fieldBackground(BuildContext context) {
    return const Color(0xFF0D0D0D);
  }

  static Color fieldBorder(BuildContext context) {
    return const Color(0xFF312E2E);
  }

  static Color mutedText(BuildContext context) {
    return const Color(0xFF878787);
  }

  static Color buttonBackground(BuildContext context) {
    return const Color(0xFF0070FA);
  }

  static Color buttonForeground(BuildContext context) {
    return Colors.white;
  }

  static double formWidth(BuildContext context) {
    return math.min(
      fieldWidth,
      MediaQuery.sizeOf(context).width - horizontalPadding * 2,
    );
  }

  static TextStyle language(BuildContext context) {
    return const TextStyle(
      fontFamily: FontFamily.roboto,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 22 / 16,
    ).copyWith(color: mutedText(context));
  }

  static TextStyle input(BuildContext context) {
    return const TextStyle(
      fontFamily: FontFamily.roboto,
      fontWeight: FontWeight.w500,
      fontSize: 16,
      height: 22 / 16,
    ).copyWith(color: mutedText(context));
  }

  static TextStyle button(BuildContext context) {
    return const TextStyle(
      fontFamily: FontFamily.roboto,
      fontWeight: FontWeight.w500,
      fontSize: 16,
      height: 20 / 16,
    ).copyWith(color: buttonForeground(context));
  }
}
