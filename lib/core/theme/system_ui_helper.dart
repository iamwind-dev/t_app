import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final class SystemUiHelper {
  const SystemUiHelper._();

  static SystemUiOverlayStyle overlayStyleFor(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final iconBrightness = isDark ? Brightness.light : Brightness.dark;

    return SystemUiOverlayStyle(
      systemNavigationBarColor: theme.scaffoldBackgroundColor,
      systemNavigationBarIconBrightness: iconBrightness,
      statusBarColor: theme.scaffoldBackgroundColor,
      statusBarIconBrightness: iconBrightness,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    );
  }
}
