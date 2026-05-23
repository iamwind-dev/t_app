import 'package:equatable/equatable.dart';
import 'package:t_app/core/utils/time_formatter.dart';
import 'package:t_app/features/activity/data/models/activity_item_model.dart';
import 'package:t_app/features/post_detail/data/models/user.dart';

class NotificationRecord extends Equatable {
  const NotificationRecord({
    required this.id,
    required this.type,
    required this.recipientId,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
    required this.targetType,
    required this.targetId,
    this.actor,
    this.readAt,
  });

  factory NotificationRecord.fromJson(Map<String, dynamic> json) {
    final actorJson = json['actor'];
    final targetJson = json['target'];
    final target = targetJson is Map<String, dynamic> ? targetJson : null;

    return NotificationRecord(
      id: json['id'] as String,
      type: json['type'] as String,
      recipientId: json['recipientId'] as String,
      actor: actorJson is Map<String, dynamic>
          ? NotificationActor.fromJson(actorJson)
          : null,
      targetType: target?['type'] as String?,
      targetId: target?['id'] as String?,
      message: json['message'] as String? ?? '',
      readAt: _parseDate(json['readAt']),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updatedAt']) ?? DateTime.now(),
    );
  }

  final String id;
  final String type;
  final String recipientId;
  final NotificationActor? actor;
  final String? targetType;
  final String? targetId;
  final String message;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ActivityItemModel toActivityItem() {
    final actorUser =
        actor?.toUser() ??
        const User(id: 'system', name: 'Together', username: 'together');

    return ActivityItemModel(
      id: id,
      type: type == 'FOLLOW'
          ? ActivityItemType.followSuggestion
          : ActivityItemType.contentRecommendation,
      user: actorUser,
      timestampLabel: TimeFormatter.formatSocialTime(createdAt),
      subtitle: message,
      hasPurpleBadge: type == 'FOLLOW',
      targetType: targetType,
      targetId: targetId,
      isRead: readAt != null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    recipientId,
    actor,
    targetType,
    targetId,
    message,
    readAt,
    createdAt,
    updatedAt,
  ];
}

class NotificationActor extends Equatable {
  const NotificationActor({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
  });

  factory NotificationActor.fromJson(Map<String, dynamic> json) {
    return NotificationActor(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String? ?? json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;

  User toUser() {
    return User(
      id: id,
      name: displayName,
      username: username,
      avatarUrl: avatarUrl,
    );
  }

  @override
  List<Object?> get props => [id, username, displayName, avatarUrl];
}

DateTime? _parseDate(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value)?.toLocal();
  }

  return null;
}
