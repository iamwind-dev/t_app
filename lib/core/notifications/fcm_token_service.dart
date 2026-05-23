import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:t_app/features/activity/data/device_tokens_repository.dart';

class FcmTokenService {
  FcmTokenService({
    required DeviceTokensRepository deviceTokensRepository,
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _deviceTokensRepository = deviceTokensRepository,
        _messaging = messaging ?? FirebaseMessaging.instance,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin();

  final DeviceTokensRepository _deviceTokensRepository;
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;

  bool _initialized = false;

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'default_push_channel',
    'Push notifications',
    description: 'General push notifications',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    if (_initialized || kIsWeb) {
      return;
    }

    _initialized = true;

    try {
      await _initializeLocalNotifications().timeout(
        const Duration(seconds: 10),
      );
    } catch (error, stackTrace) {
      debugPrint('Initialize local notifications failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    try {
      await _messaging
          .requestPermission(
            alert: true,
            badge: true,
            sound: true,
          )
          .timeout(const Duration(seconds: 10));
    } catch (error, stackTrace) {
      debugPrint('Request notification permission failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    try {
      await _messaging
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          )
          .timeout(const Duration(seconds: 10));
    } catch (error, stackTrace) {
      debugPrint(
        'Set foreground notification presentation options failed: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }

    try {
      _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(
        (token) {
          unawaited(_syncToken(token));
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('FCM token refresh stream error: $error');
          debugPrintStack(stackTrace: stackTrace);
        },
      );
    } catch (error, stackTrace) {
      debugPrint('Listen FCM token refresh failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    try {
      _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen(
        _showForegroundNotification,
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('FCM foreground message stream error: $error');
          debugPrintStack(stackTrace: stackTrace);
        },
      );
    } catch (error, stackTrace) {
      debugPrint('Listen FCM foreground messages failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> syncTokenForAuthenticatedUser() async {
    if (kIsWeb) {
      return;
    }

    try {
      // On iOS, FCM token may not be available until APNs token is ready.
      // This is especially fragile for sideloaded builds if push capability
      // or provisioning profile is not fully configured.
      if (Platform.isIOS) {
        final apnsToken = await _messaging.getAPNSToken().timeout(
              const Duration(seconds: 10),
            );

        if (apnsToken == null || apnsToken.isEmpty) {
          debugPrint('APNs token is not available yet. Skip FCM token sync.');
          return;
        }
      }

      final token = await _messaging.getToken().timeout(
            const Duration(seconds: 10),
          );

      if (token == null || token.isEmpty) {
        debugPrint('FCM token is empty. Skip token sync.');
        return;
      }

      await _syncToken(token);
    } catch (error, stackTrace) {
      debugPrint('Get/sync FCM token failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _syncToken(String token) async {
    try {
      debugPrint('FCM token: $token');

      await _deviceTokensRepository.registerFcmToken(token).timeout(
            const Duration(seconds: 15),
          );
    } catch (error, stackTrace) {
      debugPrint('Sync FCM token failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
    );

    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_androidChannel);
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final title = notification?.title;
      final body = notification?.body;

      if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
        return;
      }

      await _localNotifications.show(
        id: message.messageId.hashCode,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: message.data.toString(),
      );
    } catch (error, stackTrace) {
      debugPrint('Show foreground notification failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _foregroundMessageSubscription?.cancel();

    _tokenRefreshSubscription = null;
    _foregroundMessageSubscription = null;
    _initialized = false;
  }
}
