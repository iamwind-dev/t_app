import 'package:flutter/material.dart';

final class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final colorScheme =
        ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: const Color(0xFF101010),
        ).copyWith(
          surface: Colors.white,
          onSurface: const Color(0xFF111111),
          onSurfaceVariant: const Color(0xFF8A8A8A),
          outline: const Color(0xFFCDCDCD),
          outlineVariant: const Color(0xFFF2F2F2),
        );

    return _buildTheme(colorScheme);
  }

  static ThemeData dark() {
    final colorScheme =
        ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF1D1D1D),
        ).copyWith(
          surface: const Color(0xFF121212),
          onSurface: const Color(0xFFF3F3F3),
          onSurfaceVariant: const Color(0xFFB7B7B7),
          outline: const Color(0xFF4D4D4D),
          outlineVariant: const Color(0xFF2C2C2C),
        );

    return _buildTheme(colorScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final baseTextTheme = Typography.material2021(
      platform: TargetPlatform.android,
      colorScheme: colorScheme,
    ).black;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      dividerColor: colorScheme.outlineVariant,
      textTheme: baseTextTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
