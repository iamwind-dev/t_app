import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RealtimeEventCursorStore {
  const RealtimeEventCursorStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _lastEventIdKey = 'realtime.lastEventId';
  final FlutterSecureStorage _storage;

  Future<String?> readLastEventId() {
    return _storage.read(key: _lastEventIdKey);
  }

  Future<void> writeLastEventId(String eventId) {
    return _storage.write(key: _lastEventIdKey, value: eventId);
  }
}

