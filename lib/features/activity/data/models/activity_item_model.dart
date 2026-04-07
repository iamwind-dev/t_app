import 'package:equatable/equatable.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/post_detail/data/models/user.dart';

enum ActivityItemType {
  followSuggestion,
  contentRecommendation,
}

enum ActivityFilter {
  all,
  follows,
  conversations,
}

class ActivityItemModel extends Equatable {
  const ActivityItemModel({
    required this.id,
    required this.type,
    required this.user,
    required this.timestampLabel,
    required this.subtitle,
    this.contentPreview,
    this.mediaThumbnail,
    this.hasPurpleBadge = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.repostCount = 0,
    this.shareCount = 0,
    this.isFollowed = false,
    this.thread,
  });

  final String id;
  final ActivityItemType type;
  final User user;
  final String timestampLabel;
  final String subtitle;
  final String? contentPreview;
  final String? mediaThumbnail;
  final bool hasPurpleBadge;
  final int likeCount;
  final int commentCount;
  final int repostCount;
  final int shareCount;
  final bool isFollowed;
  final ThreadItemModel? thread;

  ActivityItemModel copyWith({
    String? id,
    ActivityItemType? type,
    User? user,
    String? timestampLabel,
    String? subtitle,
    String? contentPreview,
    String? mediaThumbnail,
    bool? hasPurpleBadge,
    int? likeCount,
    int? commentCount,
    int? repostCount,
    int? shareCount,
    bool? isFollowed,
    ThreadItemModel? thread,
  }) {
    return ActivityItemModel(
      id: id ?? this.id,
      type: type ?? this.type,
      user: user ?? this.user,
      timestampLabel: timestampLabel ?? this.timestampLabel,
      subtitle: subtitle ?? this.subtitle,
      contentPreview: contentPreview ?? this.contentPreview,
      mediaThumbnail: mediaThumbnail ?? this.mediaThumbnail,
      hasPurpleBadge: hasPurpleBadge ?? this.hasPurpleBadge,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      repostCount: repostCount ?? this.repostCount,
      shareCount: shareCount ?? this.shareCount,
      isFollowed: isFollowed ?? this.isFollowed,
      thread: thread ?? this.thread,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    user,
    timestampLabel,
    subtitle,
    contentPreview,
    mediaThumbnail,
    hasPurpleBadge,
    likeCount,
    commentCount,
    repostCount,
    shareCount,
    isFollowed,
    thread,
  ];
}
