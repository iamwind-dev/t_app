import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class ThemeModeStorage {
  static const String storageKey = 'app_theme_mode';

  Future<ThemeMode> load() async {
    final prefs = await SharedPreferences.getInstance();
    return _fromPersistedValue(prefs.getString(storageKey));
  }

  Future<void> save(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, _toPersistedValue(themeMode));
  }

  ThemeMode _fromPersistedValue(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _toPersistedValue(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
