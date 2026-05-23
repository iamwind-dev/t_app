import 'dart:async';

class RealtimeAppEvent {
  const RealtimeAppEvent({
    required this.type,
    required this.payload,
    this.eventId,
    this.orderingKey,
    this.orderingValue,
  });

  final String type;
  final Map<String, dynamic> payload;
  final String? eventId;
  final String? orderingKey;
  final String? orderingValue;
}

class RealtimeEventBus {
  RealtimeEventBus._();

  static final RealtimeEventBus instance = RealtimeEventBus._();

  final StreamController<RealtimeAppEvent> _controller =
      StreamController<RealtimeAppEvent>.broadcast();

  Stream<RealtimeAppEvent> get stream => _controller.stream;

  void emit(RealtimeAppEvent event) {
    if (_controller.isClosed) {
      return;
    }
    _controller.add(event);
  }
}

