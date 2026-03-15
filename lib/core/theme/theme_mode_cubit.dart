import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'theme_mode_storage.dart';

class ThemeModeCubit extends Cubit<ThemeMode> {
  ThemeModeCubit({
    required ThemeMode initialThemeMode,
    required ThemeModeStorage storage,
  }) : _storage = storage,
       super(initialThemeMode);

  final ThemeModeStorage _storage;

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (themeMode == state) {
      return;
    }
    emit(themeMode);
    await _storage.save(themeMode);
  }
}
