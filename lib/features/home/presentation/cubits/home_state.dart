import 'package:equatable/equatable.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';

enum HomeFeedStatus { initial, loading, loaded, failure }

class FeedUser extends Equatable {
  const FeedUser({required this.username, this.avatarAsset});

  final String username;
  final String? avatarAsset;

  @override
  List<Object?> get props => [username, avatarAsset];
}

class HomeState extends Equatable {
  static const defaultCurrentUser = FeedUser(
    username: '__win.d',
    avatarAsset: 'assets/images/home_avatar_payal.png',
  );

  const HomeState({
    this.status = HomeFeedStatus.initial,
    this.currentUser = defaultCurrentUser,
    this.rootThreads = const [],
    this.selectedTabIndex = 0,
    this.lastLoadedAtEpochMs,
    this.errorMessage,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.nextCursor,
    this.isRefreshing = false,
  });

  final HomeFeedStatus status;
  final FeedUser currentUser;
  final List<ThreadItemModel> rootThreads;
  final int selectedTabIndex;
  final int? lastLoadedAtEpochMs;
  final String? errorMessage;
  final bool isLoadingMore;
  final bool hasMore;
  final String? nextCursor;
  final bool isRefreshing;

  HomeState copyWith({
    HomeFeedStatus? status,
    FeedUser? currentUser,
    List<ThreadItemModel>? rootThreads,
    int? selectedTabIndex,
    int? lastLoadedAtEpochMs,
    String? errorMessage,
    bool clearError = false,
    bool? isLoadingMore,
    bool? hasMore,
    String? nextCursor,
    bool clearCursor = false,
    bool? isRefreshing,
  }) {
    return HomeState(
      status: status ?? this.status,
      currentUser: currentUser ?? this.currentUser,
      rootThreads: rootThreads ?? this.rootThreads,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      lastLoadedAtEpochMs: lastLoadedAtEpochMs ?? this.lastLoadedAtEpochMs,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentUser,
    rootThreads,
    selectedTabIndex,
    lastLoadedAtEpochMs,
    errorMessage,
    isLoadingMore,
    hasMore,
    nextCursor,
    isRefreshing,
  ];
}
