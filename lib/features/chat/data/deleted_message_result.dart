import 'package:equatable/equatable.dart';

class DeletedMessageResult extends Equatable {
  const DeletedMessageResult({
    required this.id,
    required this.conversationId,
    required this.deletedAt,
  });

  factory DeletedMessageResult.fromJson(Map<String, dynamic> json) {
    return DeletedMessageResult(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      deletedAt: DateTime.parse(json['deletedAt'] as String),
    );
  }

  final String id;
  final String conversationId;
  final DateTime deletedAt;

  @override
  List<Object?> get props => [id, conversationId, deletedAt];
}
