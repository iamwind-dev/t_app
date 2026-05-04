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
    this.errorMessage,
  });

  final HomeFeedStatus status;
  final FeedUser currentUser;
  final List<ThreadItemModel> rootThreads;
  final int selectedTabIndex;
  final String? errorMessage;

  HomeState copyWith({
    HomeFeedStatus? status,
    FeedUser? currentUser,
    List<ThreadItemModel>? rootThreads,
    int? selectedTabIndex,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      currentUser: currentUser ?? this.currentUser,
      rootThreads: rootThreads ?? this.rootThreads,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentUser,
    rootThreads,
    selectedTabIndex,
    errorMessage,
  ];
}
