import 'dart:io';

import 'package:t_app/core/network/api_client.dart';

class DeviceTokensRepository {
  const DeviceTokensRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<void> registerFcmToken(String token) async {
    await _apiClient.post<Map<String, dynamic>>(
      '/devices/fcm-token',
      data: {'token': token, 'platform': _platform},
      decode: _asMap,
    );
  }

  static String get _platform => Platform.isIOS ? 'ios' : 'android';

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    throw const FormatException('Expected a JSON object.');
  }
}
