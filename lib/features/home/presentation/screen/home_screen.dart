import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/features/activity/presentation/screen/activity_screen.dart';
import 'package:t_app/core/widget/home_bottom_tab_bar.dart';
import 'package:t_app/features/auth/data/auth_user.dart';
import 'package:t_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_app/features/chat/data/chat_socket_service.dart';
import 'package:t_app/features/chat/presentation/screen/chat_inbox_screen.dart';
import 'package:t_app/features/create_thread/presentation/sheet/create_thread_sheet.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/post_detail/data/models/user.dart';
import 'package:t_app/features/post_detail/presentation/screen/thread_detail_screen.dart';
import 'package:t_app/features/post_detail/presentation/screen/thread_reply_screen.dart';
import 'package:t_app/features/profile/presentation/screen/profile_screen.dart';
import 'package:t_app/features/reels/presentation/pages/reels_page.dart';
import 'package:t_app/features/reels/presentation/sheet/create_reel_sheet.dart';
import 'package:t_app/features/search/presentation/screen/search_screen.dart';
import 'package:t_app/features/search/presentation/theme/search_tokens.dart';

import '../cubits/home_cubit.dart';
import '../cubits/home_state.dart';
import '../widget/create_post_card.dart';
import '../widget/home_feed_skeleton.dart';
import '../widget/home_thread_preview_block.dart';
import '../widget/home_header.dart';
import '../widget/post_divider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  static const _toggleThreshold = 8.0;
  static const _barHeight = 78.0;

  late final ScrollController _scrollController;
  bool _isBottomBarVisible = true;
  bool _isHeaderCompact = false;
  double _lastOffset = 0;
  double _headerStretchOffset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _scrollController = ScrollController()..addListener(_handleScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(_bindFeedRealtime());
      unawaited(context.read<HomeCubit>().syncIfStale());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_bindFeedRealtime());
      unawaited(_syncOnResume());
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final offset = _scrollController.offset;
    final delta = offset - _lastOffset;

    if (delta > _toggleThreshold && mounted) {
      if (_isBottomBarVisible || !_isHeaderCompact) {
        setState(() {
          _isBottomBarVisible = false;
          _isHeaderCompact = true;
        });
      }
    } else if (delta < -_toggleThreshold && mounted) {
      if (!_isBottomBarVisible || _isHeaderCompact) {
        setState(() {
          _isBottomBarVisible = true;
          _isHeaderCompact = false;
        });
      }
    }

    _lastOffset = offset < 0 ? 0 : offset;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      context.read<HomeCubit>().loadMoreHomeFeed();
    }
  }

  double _bottomSpace(BuildContext context) {
    return _barHeight + MediaQuery.paddingOf(context).bottom + 12;
  }

  bool _handleHomeScrollNotification(ScrollNotification notification) {
    final metrics = notification.metrics;
    if (metrics.axis != Axis.vertical) {
      return false;
    }

    final overscroll = metrics.pixels < metrics.minScrollExtent
        ? (metrics.minScrollExtent - metrics.pixels).clamp(0.0, 64.0)
        : 0.0;

    if (overscroll != _headerStretchOffset && mounted) {
      setState(() {
        _headerStretchOffset = overscroll;
      });
    }

    if (notification is ScrollEndNotification &&
        _headerStretchOffset != 0 &&
        mounted) {
      setState(() {
        _headerStretchOffset = 0;
      });
    }

    return false;
  }

  User _buildCurrentUser(HomeState state, AuthUser? authUser) {
    final username = authUser?.username ?? state.currentUser.username;
    final isDemoUser = username == state.currentUser.username;

    return User(
      id: authUser?.id ?? 'current_user',
      name: username,
      username: username,
      avatarUrl: authUser?.avatarUrl,
      avatarAssetPath: authUser?.avatarUrl == null
          ? (isDemoUser ? state.currentUser.avatarAsset : null)
          : null,
    );
  }


  Future<void> _openCreateThreadSheet(
    HomeState state,
    AuthUser? authUser,
  ) {
    return showCreateThreadSheet(
      context: context,
      currentUser: _buildCurrentUser(state, authUser),
      onSubmit: (request) => context.read<HomeCubit>().createPost(
            request.primaryContent,
            mediaUrls: request.mediaUrls,
          ),
      onSubmissionAccepted: (submission) async {
        if (!mounted) {
          return;
        }

        final newPost = submission.thread;
        if (newPost != null) {
          context.read<HomeCubit>().insertCreatedPost(newPost);
        }

        final success = await context
            .read<HomeCubit>()
            .refreshFeed(isFromPostCreation: true);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã đăng bài'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  void _handleBottomTabTap(int index, HomeState state) {
    context.read<HomeCubit>().changeTab(index);
  }

  void _openCreateReelSheet() {
    showCreateReelSheet(context);
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          backgroundColor: SearchTokens.pageBackground(context),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            leading: const BackButton(),
          ),
          body: const SearchScreen(
            bottomPadding: 16,
          ),
        ),
      ),
    );
  }

  void _openThreadDetail(ThreadItemModel rootThread) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ThreadDetailScreen(rootThread: rootThread),
      ),
    );
  }

  void _openThreadBranch({
    required ThreadItemModel rootThread,
    required ThreadItemModel selectedThread,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ThreadReplyScreen(
          rootThread: rootThread,
          selectedThreadId: selectedThread.id,
        ),
      ),
    );
  }

  Future<void> _refreshHomeFeed() async {
    await context.read<HomeCubit>().refreshFeed();
    if (mounted && _headerStretchOffset != 0) {
      setState(() {
        _headerStretchOffset = 0;
      });
    }
  }

  Future<void> _bindFeedRealtime() async {
    final socketService = context.read<ChatSocketService>();
    await socketService.connect();
    await socketService.joinRoom('feed:global');
  }

  Future<void> _syncOnResume() async {
    final socketService = context.read<ChatSocketService>();
    final homeCubit = context.read<HomeCubit>();
    await socketService.syncEvents(rooms: const ['feed:global']);
    await homeCubit.syncIfStale(
      maxAge: const Duration(minutes: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.select(
      (AuthCubit cubit) => cubit.state.user,
    );

    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<HomeCubit>().clearError();
        }
      },
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final isMessageTab = state.selectedTabIndex == 1;
          final isReelsTab = state.selectedTabIndex == 2;
          final isActivityTab = state.selectedTabIndex == 3;
          final isProfileTab = state.selectedTabIndex == 4;

          final shouldShowBottomBar =
              isMessageTab ||
              isReelsTab ||
              isActivityTab ||
              isProfileTab ||
              _isBottomBarVisible;

          return Scaffold(
            body: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  if (isMessageTab)
                    ChatInboxScreen(
                      bottomPadding: _bottomSpace(context),
                    )
                  else if (isActivityTab)
                    ActivityScreen(
                      bottomPadding: _bottomSpace(context),
                    )
                  else if (isReelsTab)
                    ReelsPage(
                      bottomPadding: _bottomSpace(context),
                    )
                  else if (isProfileTab)
                    currentUser == null
                        ? const Center(
                            child: Text('Không thể tải hồ sơ.'),
                          )
                        : ProfileScreen(
                            userId: currentUser.id,
                            bottomPadding: _bottomSpace(context),
                          )
                  else
                    Column(
                      children: [
                        HomeHeader(
                          isCompact: _isHeaderCompact,
                          onSearchTap: _openSearch,
                          stretchOffset: _headerStretchOffset,
                        ),
                        Expanded(
                          child: NotificationListener<ScrollNotification>(
                            onNotification: _handleHomeScrollNotification,
                            child: RefreshIndicator(
                              onRefresh: _refreshHomeFeed,
                              child: state.isInitialLoading
                                  ? HomeFeedSkeletonList(
                                      itemCount: 5,
                                      includeComposerGap: true,
                                      bottomPadding: shouldShowBottomBar
                                          ? _bottomSpace(context)
                                          : 12,
                                    )
                                  : ListView.separated(
                                      controller: _scrollController,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(
                                        parent: BouncingScrollPhysics(),
                                      ),
                                      padding: EdgeInsets.only(
                                        bottom: shouldShowBottomBar
                                            ? _bottomSpace(context)
                                            : 12,
                                      ),
                                      itemCount: state.rootThreads.length +
                                          1 +
                                          (state.isLoadingMore ? 1 : 0),
                                      itemBuilder: (context, index) {
                                        if (index == 0) {
                                          return CreatePostCard(
                                            currentUser: _buildCurrentUser(
                                              state,
                                              currentUser,
                                            ),
                                            onTap: () => _openCreateThreadSheet(
                                              state,
                                              currentUser,
                                            ),
                                          );
                                        }

                                        if (state.isLoadingMore &&
                                            index ==
                                                state.rootThreads.length + 1) {
                                          return const HomeLoadMoreSkeleton();
                                        }

                                        final rootThread =
                                            state.rootThreads[index - 1];

                                        return Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            0,
                                            14,
                                            0,
                                            16,
                                          ),
                                          child: HomeThreadPreviewBlock(
                                            rootThread: rootThread,
                                            onRootTap: () =>
                                                _openThreadDetail(rootThread),
                                            onReplyTap: () =>
                                                _openThreadDetail(rootThread),
                                            onLikeTap: context
                                                .read<HomeCubit>()
                                                .togglePostLike,
                                            onPreviewReplyTap: (replyThread) =>
                                                _openThreadBranch(
                                              rootThread: rootThread,
                                              selectedThread: replyThread,
                                            ),
                                          ),
                                        );
                                      },
                                      separatorBuilder: (context, index) {
                                        if (state.isLoadingMore &&
                                            index == state.rootThreads.length) {
                                          return const SizedBox.shrink();
                                        }

                                        return const PostDivider();
                                      },
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeInOutCubic,
                      offset: shouldShowBottomBar
                          ? Offset.zero
                          : const Offset(0, 1.25),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        opacity: shouldShowBottomBar ? 1 : 0,
                        child: IgnorePointer(
                          ignoring: !shouldShowBottomBar,
                          child: HomeBottomTabBar(
                            selectedIndex: state.selectedTabIndex,
                            onTap: (index) =>
                                _handleBottomTabTap(index, state),
                            onReelsCreateTap: _openCreateReelSheet,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
