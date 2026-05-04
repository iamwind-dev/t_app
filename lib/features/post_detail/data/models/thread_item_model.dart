import 'package:equatable/equatable.dart';

import 'user.dart';

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
  final List<String> replyPreviewAvatars;
  final List<ThreadItemModel> previewReplies;
  final List<ThreadItemModel> children;

  bool get isRootThread => parentId == null;
  bool get hasReplies => replyCount > 0 || children.isNotEmpty;
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
    replyPreviewAvatars,
    previewReplies,
    children,
  ];
}
