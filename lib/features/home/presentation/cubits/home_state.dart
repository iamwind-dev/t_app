import 'package:equatable/equatable.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';

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
    this.currentUser = defaultCurrentUser,
    this.rootThreads = const [],
    this.selectedTabIndex = 0,
  });

  final FeedUser currentUser;
  final List<ThreadItemModel> rootThreads;
  final int selectedTabIndex;

  HomeState copyWith({
    FeedUser? currentUser,
    List<ThreadItemModel>? rootThreads,
    int? selectedTabIndex,
  }) {
    return HomeState(
      currentUser: currentUser ?? this.currentUser,
      rootThreads: rootThreads ?? this.rootThreads,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }

  @override
  List<Object?> get props => [currentUser, rootThreads, selectedTabIndex];
}
