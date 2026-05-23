import 'package:equatable/equatable.dart';

import 'user.dart';

bool shouldBlurModeratedContent({
  String? moderationStatus,
  String? moderationAction,
  bool? moderationIsWarning,
  String? visibilityLevel,
}) {
  final normalizedStatus = moderationStatus?.trim().toLowerCase();
  if (normalizedStatus != null &&
      normalizedStatus.isNotEmpty &&
      normalizedStatus != 'approved' &&
      normalizedStatus != 'safe' &&
      normalizedStatus != 'clean' &&
      normalizedStatus != 'normal') {
    return true;
  }
  if (moderationAction == 'WARN_USER') {
    return true;
  }
  if (moderationAction == 'BLOCK_OR_REVIEW') {
    return true;
  }
  if (moderationIsWarning == true) {
    return true;
  }
  if (visibilityLevel == 'review') {
    return true;
  }
  if (visibilityLevel == 'hidden') {
    return true;
  }

  return false;
}

String inferModerationAction({
  required String moderationStatus,
  required String moderationAction,
  required bool moderationIsWarning,
  required String visibilityLevel,
}) {
  if (moderationAction != 'ALLOW') {
    return moderationAction;
  }
  if (moderationIsWarning) {
    return 'WARN_USER';
  }

  final normalizedVisibility = visibilityLevel.trim().toLowerCase();
  if (normalizedVisibility == 'hidden' || normalizedVisibility == 'review') {
    return 'BLOCK_OR_REVIEW';
  }

  final normalizedStatus = moderationStatus.trim().toLowerCase();
  if (normalizedStatus == 'approved' ||
      normalizedStatus == 'safe' ||
      normalizedStatus == 'clean' ||
      normalizedStatus == 'normal') {
    return 'ALLOW';
  }

  return 'WARN_USER';
}

class ThreadItemModel extends Equatable {
  const ThreadItemModel({
    required this.id,
    required this.rootThreadId,
    required this.author,
    required this.createdAt,
    required this.content,
    this.parentId,
    this.imageUrls = const [],
    this.likesCount = 0,
    this.replyCount = 0,
    this.repostCount = 0,
    this.shareCount = 0,
    this.isLikedByMe = false,
    this.moderationStatus = 'approved',
    this.moderationLabel = 'clean',
    this.moderationConfidence = 0,
    this.moderationAction = 'ALLOW',
    this.moderationIsWarning = false,
    this.visibilityLevel = 'normal',
    this.replyPreviewAvatars = const [],
    this.previewReplies = const [],
    this.children = const [],
  });

  final String id;
  final String? parentId;
  final String rootThreadId;
  final User author;
  final String createdAt;
  final String content;
  final List<String> imageUrls;
  final int likesCount;
  final int replyCount;
  final int repostCount;
  final int shareCount;
  final bool isLikedByMe;
  final String moderationStatus;
  final String moderationLabel;
  final double moderationConfidence;
  final String moderationAction;
  final bool moderationIsWarning;
  final String visibilityLevel;
  final List<String> replyPreviewAvatars;
  final List<ThreadItemModel> previewReplies;
  final List<ThreadItemModel> children;

  bool get isRootThread => parentId == null;
  bool get hasReplies => replyCount > 0 || children.isNotEmpty;
  bool get shouldShowWarningChip => false;
  bool get shouldCollapseModeratedContent => false;
  String get effectiveModerationAction => inferModerationAction(
    moderationStatus: moderationStatus,
    moderationAction: moderationAction,
    moderationIsWarning: moderationIsWarning,
    visibilityLevel: visibilityLevel,
  );
  String get effectiveModerationLabel => moderationLabel.trim().isEmpty
      ? 'other'
      : moderationLabel;
  bool get shouldBlurVisibleContent => shouldBlurModeratedContent(
    moderationStatus: moderationStatus,
    moderationAction: moderationAction,
    moderationIsWarning: moderationIsWarning,
    visibilityLevel: visibilityLevel,
  );
  ThreadItemModel? get previewReply => previewReplies.isNotEmpty
      ? previewReplies.first
      : (children.isNotEmpty ? children.first : null);
  List<ThreadItemModel> get effectivePreviewReplies => previewReplies.isNotEmpty
      ? previewReplies
      : children.take(2).toList(growable: false);

  ThreadItemModel copyWith({
    String? id,
    String? parentId,
    String? rootThreadId,
    User? author,
    String? createdAt,
    String? content,
    List<String>? imageUrls,
    int? likesCount,
    int? replyCount,
    int? repostCount,
    int? shareCount,
    bool? isLikedByMe,
    String? moderationStatus,
    String? moderationLabel,
    double? moderationConfidence,
    String? moderationAction,
    bool? moderationIsWarning,
    String? visibilityLevel,
    List<String>? replyPreviewAvatars,
    List<ThreadItemModel>? previewReplies,
    List<ThreadItemModel>? children,
  }) {
    return ThreadItemModel(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      rootThreadId: rootThreadId ?? this.rootThreadId,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      likesCount: likesCount ?? this.likesCount,
      replyCount: replyCount ?? this.replyCount,
      repostCount: repostCount ?? this.repostCount,
      shareCount: shareCount ?? this.shareCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      moderationLabel: moderationLabel ?? this.moderationLabel,
      moderationConfidence: moderationConfidence ?? this.moderationConfidence,
      moderationAction: moderationAction ?? this.moderationAction,
      moderationIsWarning: moderationIsWarning ?? this.moderationIsWarning,
      visibilityLevel: visibilityLevel ?? this.visibilityLevel,
      replyPreviewAvatars: replyPreviewAvatars ?? this.replyPreviewAvatars,
      previewReplies: previewReplies ?? this.previewReplies,
      children: children ?? this.children,
    );
  }

  ThreadItemModel? findById(String threadId) {
    if (id == threadId) {
      return this;
    }

    for (final child in children) {
      final found = child.findById(threadId);
      if (found != null) {
        return found;
      }
    }

    return null;
  }

  List<ThreadItemModel> buildAncestorPath(String threadId) {
    final path = <ThreadItemModel>[];
    final found = _collectAncestorPath(threadId, path);
    if (!found) {
      return const <ThreadItemModel>[];
    }

    return path;
  }

  bool _collectAncestorPath(String threadId, List<ThreadItemModel> path) {
    path.add(this);
    if (id == threadId) {
      return true;
    }

    for (final child in children) {
      if (child._collectAncestorPath(threadId, path)) {
        return true;
      }
    }

    path.removeLast();
    return false;
  }

  @override
  List<Object?> get props => [
    id,
    parentId,
    rootThreadId,
    author,
    createdAt,
    content,
    imageUrls,
    likesCount,
    replyCount,
    repostCount,
    shareCount,
    isLikedByMe,
    moderationStatus,
    moderationLabel,
    moderationConfidence,
    moderationAction,
    moderationIsWarning,
    visibilityLevel,
    replyPreviewAvatars,
    previewReplies,
    children,
  ];
}
