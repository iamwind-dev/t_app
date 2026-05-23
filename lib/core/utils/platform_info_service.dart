import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final class PlatformInfoService {
  const PlatformInfoService._();

  static Future<bool>? _supportsNativeLiquidGlassBottomNavFuture;

  static Future<bool> supportsNativeLiquidGlassBottomNav() {
    return _supportsNativeLiquidGlassBottomNavFuture ??=
        _readNativeLiquidGlassBottomNavSupport();
  }

  static Future<bool> _readNativeLiquidGlassBottomNavSupport() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return false;
    }

    try {
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      final majorVersion = int.tryParse(
        iosInfo.systemVersion.split('.').first,
      );
      return (majorVersion ?? 0) >= 26;
    } catch (_) {
      return false;
    }
  }
}
