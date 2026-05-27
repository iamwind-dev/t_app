import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/features/reels/data/repositories_impl/reels_repository_impl.dart';
import 'package:t_app/features/reels/domain/repositories/reels_repository.dart';
import 'package:t_app/features/reels/domain/usecases/get_reels.dart';
import 'package:t_app/features/reels/presentation/cubits/reels_cubit.dart';

import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/network/api_token_store.dart';
import 'core/network/secure_api_token_store.dart';
import 'core/notifications/fcm_token_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/system_ui_helper.dart';
import 'core/theme/theme_mode_cubit.dart';
import 'core/theme/theme_mode_storage.dart';
import 'features/activity/data/device_tokens_repository.dart';
import 'features/activity/data/notifications_repository.dart';
import 'features/activity/domain/notifications_activity_repository.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/domain/auth_session_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/auth/presentation/screen/login_screen.dart';
import 'features/chat/data/backend_chat_repository.dart';
import 'features/chat/data/chat_socket_service.dart';
import 'features/chat/data/socket_io_chat_realtime_client.dart';
import 'features/chat/domain/chat_repository.dart';
import 'features/home/presentation/cubits/home_cubit.dart';
import 'features/home/presentation/screen/home_screen.dart';
import 'features/posts/data/posts_repository.dart';
import 'features/posts/domain/posts_feed_repository.dart';
import 'features/uploads/data/uploads_repository.dart';
import 'features/uploads/domain/uploads_image_repository.dart';
import 'features/users/data/users_repository.dart';
import 'features/users/domain/users_profile_repository.dart';

import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Render something immediately. If startup fails, the app will show the error
  // instead of staying forever on the native splash screen.
  runApp(const BootDebugApp(message: 'Starting app...'));

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));
  } catch (error) {
    runApp(
      BootDebugApp(
        message: 'Firebase startup error:\n$error',
      ),
    );
    return;
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  late final ThemeModeStorage themeModeStorage;
  late final ThemeMode initialThemeMode;

  try {
    themeModeStorage = ThemeModeStorage();
    initialThemeMode = await themeModeStorage.load().timeout(
      const Duration(seconds: 10),
    );
  } catch (error) {
    runApp(
      BootDebugApp(
        message: 'Theme startup error:\n$error',
      ),
    );
    return;
  }

  const tokenStore = SecureApiTokenStore();

  final apiBaseUrl = AppConfig.apiBaseUrl.trim();

  final apiClient = ApiClient(
    dio: Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
      ),
    ),
    tokenStore: tokenStore,
  );

  final authRepository = AuthRepository(
    apiClient: apiClient,
    tokenStore: tokenStore,
  );

  final usersRepository = UsersRepository(apiClient: apiClient);
  final postsRepository = PostsRepository(apiClient: apiClient);
  final uploadsRepository = UploadsRepository(apiClient: apiClient);
  final notificationsRepository = NotificationsRepository(apiClient: apiClient);
  final deviceTokensRepository = DeviceTokensRepository(apiClient: apiClient);

  final fcmTokenService = FcmTokenService(
    deviceTokensRepository: deviceTokensRepository,
  );

  // Do not block app startup forever if APNs/FCM fails, especially for
  // sideloaded iOS builds where push capabilities may not be fully available.
  try {
    await fcmTokenService.initialize().timeout(
      const Duration(seconds: 10),
    );
  } catch (error) {
    debugPrint('FCM initialize error: $error');
  }

  final chatSocketService = SocketIoChatRealtimeClient(
    baseUrl: apiBaseUrl,
    tokenStore: tokenStore,
  );

  final chatRepository = BackendChatRepository(
    apiClient: apiClient,
    realtimeClient: chatSocketService,
  );

  final reelsRepository = ReelsRepositoryImpl(apiClient: apiClient);


  runApp(
    TogetherApp(
      themeModeStorage: themeModeStorage,
      initialThemeMode: initialThemeMode,
      apiClient: apiClient,
      tokenStore: tokenStore,
      authRepository: authRepository,
      usersRepository: usersRepository,
      postsRepository: postsRepository,
      uploadsRepository: uploadsRepository,
      notificationsRepository: notificationsRepository,
      fcmTokenService: fcmTokenService,
      chatRepository: chatRepository,
      chatSocketService: chatSocketService,
      reelsRepository: reelsRepository,
    ),
  );
}

class BootDebugApp extends StatelessWidget {
  const BootDebugApp({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Together',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              message,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class TogetherApp extends StatelessWidget {
  const TogetherApp({
    super.key,
    required this.themeModeStorage,
    required this.initialThemeMode,
    required this.apiClient,
    required this.tokenStore,
    required this.authRepository,
    required this.usersRepository,
    required this.postsRepository,
    required this.uploadsRepository,
    required this.notificationsRepository,
    required this.fcmTokenService,
    required this.chatRepository,
    required this.chatSocketService,
    required this.reelsRepository,
  });

  final ThemeModeStorage themeModeStorage;
  final ThemeMode initialThemeMode;
  final ApiClient apiClient;
  final ApiTokenStore tokenStore;
  final AuthSessionRepository authRepository;
  final UsersProfileRepository usersRepository;
  final PostsFeedRepository postsRepository;
  final UploadsImageRepository uploadsRepository;
  final NotificationsActivityRepository notificationsRepository;
  final FcmTokenService fcmTokenService;
  final ChatRepository chatRepository;
  final ChatSocketService chatSocketService;
  final ReelsRepository reelsRepository;

  /// Wires shared repositories and defers authenticated feature loading.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiClient>.value(value: apiClient),
        RepositoryProvider<ApiTokenStore>.value(value: tokenStore),
        RepositoryProvider<AuthSessionRepository>.value(value: authRepository),
        RepositoryProvider<UsersProfileRepository>.value(
          value: usersRepository,
        ),
        RepositoryProvider<PostsFeedRepository>.value(value: postsRepository),
        RepositoryProvider<UploadsImageRepository>.value(
          value: uploadsRepository,
        ),
        RepositoryProvider<NotificationsActivityRepository>.value(
          value: notificationsRepository,
        ),
        RepositoryProvider<FcmTokenService>.value(value: fcmTokenService),
        RepositoryProvider<ChatRepository>.value(value: chatRepository),
        RepositoryProvider<ChatSocketService>.value(value: chatSocketService),
        RepositoryProvider<ReelsRepository>.value(value: reelsRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => ThemeModeCubit(
              initialThemeMode: initialThemeMode,
              storage: themeModeStorage,
            ),
          ),
          BlocProvider(
            create: (_) =>
                AuthCubit(repository: authRepository)..checkSession(),
          ),
          BlocProvider(
            create: (_) =>
                HomeCubit(repository: postsRepository)..loadHomeFeed(),
          ),
          BlocProvider(
            create: (_) =>
                ReelsCubit(
                  getReels: GetReels(reelsRepository),
                  repository: reelsRepository,
                ),
          ),
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
              home: const _AuthGate(),
            );
          },
        ),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  /// Starts authenticated side effects only after the session is confirmed.
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == AuthStatus.authenticated,
      listener: (context, state) {
        unawaited(context.read<ReelsCubit>().loadReels());
        unawaited(_syncFcmTokenSafely(context));
        unawaited(context.read<ChatSocketService>().connect());
        unawaited(context.read<ChatSocketService>().joinRoom('feed:global'));
        unawaited(
          context.read<ChatSocketService>().syncEvents(
            rooms: const ['feed:global'],
          ),
        );
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return switch (state.status) {
            AuthStatus.checking => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            AuthStatus.authenticated => const HomeScreen(),
            _ => const LoginScreen(),
          };
        },
      ),
    );
  }

  Future<void> _syncFcmTokenSafely(BuildContext context) async {
    try {
      await context.read<FcmTokenService>().syncTokenForAuthenticatedUser();
    } catch (error) {
      debugPrint('FCM token sync error: $error');
    }
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
