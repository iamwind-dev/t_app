import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/system_ui_helper.dart';
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

class TogetherApp extends StatelessWidget {
  const TogetherApp({
    super.key,
    required this.themeModeStorage,
    required this.initialThemeMode,
  });

  final ThemeModeStorage themeModeStorage;
  final ThemeMode initialThemeMode;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ThemeModeCubit(
            initialThemeMode: initialThemeMode,
            storage: themeModeStorage,
          ),
        ),
        BlocProvider(create: (_) => HomeCubit()),
      ],
      child: BlocBuilder<ThemeModeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Together',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            builder: (context, child) {
              return _SystemUiOverlaySync(
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}

class _SystemUiOverlaySync extends StatefulWidget {
  const _SystemUiOverlaySync({required this.child});

  final Widget child;

  @override
  State<_SystemUiOverlaySync> createState() => _SystemUiOverlaySyncState();
}

class _SystemUiOverlaySyncState extends State<_SystemUiOverlaySync> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiHelper.overlayStyleFor(Theme.of(context)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final overlayStyle = SystemUiHelper.overlayStyleFor(Theme.of(context));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: widget.child,
    );
  }
}
