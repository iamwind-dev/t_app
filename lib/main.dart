import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_cubit.dart';
import 'core/theme/theme_mode_storage.dart';
import 'features/home/presentation/cubits/home_cubit.dart';
import 'features/home/presentation/screen/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeModeStorage = ThemeModeStorage();
  final initialThemeMode = await themeModeStorage.load();
  runApp(
    TogetherApp(
      themeModeStorage: themeModeStorage,
      initialThemeMode: initialThemeMode,
    ),
  );
}

class TogetherApp extends StatefulWidget {
  const TogetherApp({
    super.key,
    required this.themeModeStorage,
    required this.initialThemeMode,
  });

  final ThemeModeStorage themeModeStorage;
  final ThemeMode initialThemeMode;

  @override
  State<TogetherApp> createState() => _TogetherAppState();
}

class _TogetherAppState extends State<TogetherApp> {
  late final ThemeModeCubit _themeModeCubit = ThemeModeCubit(
    initialThemeMode: widget.initialThemeMode,
    storage: widget.themeModeStorage,
  );
  late final HomeCubit _homeCubit = HomeCubit();

  @override
  void dispose() {
    _themeModeCubit.close();
    _homeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeModeCubit>.value(value: _themeModeCubit),
        BlocProvider<HomeCubit>.value(value: _homeCubit),
      ],
      child: BlocBuilder<ThemeModeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Together',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
