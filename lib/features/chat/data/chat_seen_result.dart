import 'package:equatable/equatable.dart';

class ChatSeenResult extends Equatable {
  const ChatSeenResult({
    required this.conversationId,
    required this.userId,
    required this.messageId,
    required this.seenAt,
    required this.skipped,
  });

  factory ChatSeenResult.fromJson(Map<String, dynamic> json) {
    return ChatSeenResult(
      conversationId: json['conversationId'] as String,
      userId: json['userId'] as String,
      messageId: json['messageId'] as String,
      seenAt: DateTime.parse(json['seenAt'] as String),
      skipped: json['skipped'] as bool? ?? false,
    );
  }

  final String conversationId;
  final String userId;
  final String messageId;
  final DateTime seenAt;
  final bool skipped;

  @override
  List<Object?> get props => [
    conversationId,
    userId,
    messageId,
    seenAt,
    skipped,
  ];
}
