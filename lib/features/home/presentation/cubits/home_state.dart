import 'package:equatable/equatable.dart';

class FeedUser extends Equatable {
  final String username;
  final String? avatarAsset;

  const FeedUser({required this.username, this.avatarAsset});

  @override
  List<Object?> get props => [username, avatarAsset];
}

enum ThreadItemType { post, reply }

class ThreadAttachmentData extends Equatable {
  final String url;
  final double? height;

  const ThreadAttachmentData({required this.url, this.height});

  @override
  List<Object?> get props => [url, height];
}

class ThreadItemData extends Equatable {
  final String id;
  final String userId;
  final String username;
  final String? userAvatarUrl;
  final String content;
  final String createdAtLabel;
  final String likeCount;
  final String commentCount;
  final String repostCount;
  final String shareCount;
  final bool isLiked;
  final bool isVerified;
  final bool showLikeBadge;
  final String? parentId;
  final ThreadItemType type;
  final List<ThreadAttachmentData> attachments;
  final ThreadItemData? replyPreview;
  final bool showActions;
  final bool showConnector;
  final bool showDivider;

  const ThreadItemData({
    required this.id,
    required this.userId,
    required this.username,
    this.userAvatarUrl,
    required this.content,
    required this.createdAtLabel,
    this.likeCount = '0',
    this.commentCount = '0',
    this.repostCount = '0',
    this.shareCount = '0',
    this.isLiked = false,
    this.isVerified = false,
    this.showLikeBadge = false,
    this.parentId,
    required this.type,
    this.attachments = const [],
    this.replyPreview,
    this.showActions = true,
    this.showConnector = false,
    this.showDivider = false,
  });

  ThreadItemData copyWith({
    String? id,
    String? userId,
    String? username,
    String? userAvatarUrl,
    String? content,
    String? createdAtLabel,
    String? likeCount,
    String? commentCount,
    String? repostCount,
    String? shareCount,
    bool? isLiked,
    bool? isVerified,
    bool? showLikeBadge,
    String? parentId,
    ThreadItemType? type,
    List<ThreadAttachmentData>? attachments,
    ThreadItemData? replyPreview,
    bool? showActions,
    bool? showConnector,
    bool? showDivider,
  }) {
    return ThreadItemData(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      content: content ?? this.content,
      createdAtLabel: createdAtLabel ?? this.createdAtLabel,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      repostCount: repostCount ?? this.repostCount,
      shareCount: shareCount ?? this.shareCount,
      isLiked: isLiked ?? this.isLiked,
      isVerified: isVerified ?? this.isVerified,
      showLikeBadge: showLikeBadge ?? this.showLikeBadge,
      parentId: parentId ?? this.parentId,
      type: type ?? this.type,
      attachments: attachments ?? this.attachments,
      replyPreview: replyPreview ?? this.replyPreview,
      showActions: showActions ?? this.showActions,
      showConnector: showConnector ?? this.showConnector,
      showDivider: showDivider ?? this.showDivider,
    );
  }

  factory ThreadItemData.fromThreadComment(
    ThreadComment comment, {
    required String parentId,
    bool showActions = false,
  }) {
    return ThreadItemData(
      id: '$parentId:${comment.author}:${comment.timeAgo}:${comment.content.hashCode}',
      userId: comment.author.toLowerCase().replaceAll(' ', '_'),
      username: comment.author,
      userAvatarUrl: comment.avatarAsset,
      content: comment.content,
      createdAtLabel: comment.timeAgo,
      likeCount: comment.likeCount,
      commentCount: comment.replyCount,
      repostCount: comment.repostCount,
      shareCount: comment.sendCount,
      showLikeBadge: comment.showLikeBadge,
      parentId: parentId,
      type: ThreadItemType.reply,
      showActions: showActions,
      showConnector: false,
    );
  }

  factory ThreadItemData.fromThreadPost(ThreadPost post) {
    final postId = '${post.author}:${post.timeAgo}:${post.content.hashCode}';
    final previewReply = post.comments.isEmpty
        ? null
        : ThreadItemData.fromThreadComment(
            post.comments.first,
            parentId: postId,
          );

    return ThreadItemData(
      id: postId,
      userId: post.author.toLowerCase().replaceAll(' ', '_'),
      username: post.author,
      userAvatarUrl: post.avatarAsset,
      content: post.content,
      createdAtLabel: post.timeAgo,
      likeCount: post.likeCount,
      commentCount: post.replyCount,
      repostCount: post.repostCount,
      shareCount: post.sendCount,
      isVerified: post.isVerified,
      type: ThreadItemType.post,
      attachments: post.postImageAsset == null
          ? const []
          : [
              ThreadAttachmentData(
                url: post.postImageAsset!,
                height: post.postImageHeight,
              ),
            ],
      replyPreview: previewReply,
      showActions: true,
      showConnector: previewReply != null,
      showDivider: true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    username,
    userAvatarUrl,
    content,
    createdAtLabel,
    likeCount,
    commentCount,
    repostCount,
    shareCount,
    isLiked,
    isVerified,
    showLikeBadge,
    parentId,
    type,
    attachments,
    replyPreview,
    showActions,
    showConnector,
    showDivider,
  ];
}

class ThreadComment extends Equatable {
  final String author;
  final String? avatarAsset;
  final String timeAgo;
  final String content;
  final bool showLikeBadge;
  final String likeCount;
  final String replyCount;
  final String repostCount;
  final String sendCount;

  const ThreadComment({
    required this.author,
    this.avatarAsset,
    required this.timeAgo,
    required this.content,
    this.showLikeBadge = false,
    this.likeCount = '0',
    this.replyCount = '0',
    this.repostCount = '0',
    this.sendCount = '0',
  });

  @override
  List<Object?> get props => [
    author,
    avatarAsset,
    timeAgo,
    content,
    showLikeBadge,
    likeCount,
    replyCount,
    repostCount,
    sendCount,
  ];
}

class ThreadPost extends Equatable {
  final String author;
  final String? avatarAsset;
  final String timeAgo;
  final String content;
  final String threadStackAsset;
  final double threadStackHeight;
  final String likeCount;
  final String replyCount;
  final String repostCount;
  final String sendCount;
  final String? postImageAsset;
  final double? postImageHeight;
  final List<ThreadComment> comments;
  final bool isVerified;
  final String? primaryMeta;
  final String? secondaryMeta;

  const ThreadPost({
    required this.author,
    this.avatarAsset,
    required this.timeAgo,
    required this.content,
    required this.threadStackAsset,
    required this.threadStackHeight,
    this.likeCount = '0',
    this.replyCount = '0',
    this.repostCount = '0',
    this.sendCount = '0',
    this.postImageAsset,
    this.postImageHeight,
    this.comments = const [],
    this.isVerified = false,
    this.primaryMeta,
    this.secondaryMeta,
  });

  @override
  List<Object?> get props => [
    author,
    avatarAsset,
    timeAgo,
    content,
    threadStackAsset,
    threadStackHeight,
    likeCount,
    replyCount,
    repostCount,
    sendCount,
    postImageAsset,
    postImageHeight,
    comments,
    isVerified,
    primaryMeta,
    secondaryMeta,
  ];
}

class HomeState extends Equatable {
  static const defaultCurrentUser = FeedUser(
    username: '__win.d',
    avatarAsset: 'assets/images/home_avatar_payal.png',
  );

  final FeedUser currentUser;
  final List<ThreadItemData> feedItems;
  final int selectedTabIndex;

  const HomeState({
    this.currentUser = defaultCurrentUser,
    this.feedItems = const [],
    this.selectedTabIndex = 0,
  });

  HomeState copyWith({
    FeedUser? currentUser,
    List<ThreadItemData>? feedItems,
    int? selectedTabIndex,
  }) {
    return HomeState(
      currentUser: currentUser ?? this.currentUser,
      feedItems: feedItems ?? this.feedItems,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }

  @override
  List<Object?> get props => [currentUser, feedItems, selectedTabIndex];
}
