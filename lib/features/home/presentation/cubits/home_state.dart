import 'package:equatable/equatable.dart';

class ThreadComment extends Equatable {
  final String author;
  final String timeAgo;
  final String content;
  final bool showLikeBadge;
  final String likeCount;
  final String replyCount;
  final String repostCount;
  final String sendCount;

  const ThreadComment({
    required this.author,
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
  final List<ThreadPost> posts;
  final int selectedTabIndex;

  const HomeState({this.posts = const [], this.selectedTabIndex = 0});

  HomeState copyWith({List<ThreadPost>? posts, int? selectedTabIndex}) {
    return HomeState(
      posts: posts ?? this.posts,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }

  @override
  List<Object?> get props => [posts, selectedTabIndex];
}
