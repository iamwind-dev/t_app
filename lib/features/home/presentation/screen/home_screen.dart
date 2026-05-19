import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/features/activity/presentation/screen/activity_screen.dart';
import 'package:t_app/core/theme/theme_mode_cubit.dart';
import 'package:t_app/core/widget/home_bottom_tab_bar.dart';
import 'package:t_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_app/features/chat/presentation/screen/chat_inbox_screen.dart';
import 'package:t_app/features/create_thread/presentation/sheet/create_thread_sheet.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/post_detail/data/models/user.dart';
import 'package:t_app/features/post_detail/presentation/screen/thread_detail_screen.dart';
import 'package:t_app/features/post_detail/presentation/screen/thread_reply_screen.dart';
import 'package:t_app/features/profile/presentation/screen/profile_screen.dart';
import 'package:t_app/features/reels/presentation/pages/reels_page.dart';
import 'package:t_app/features/search/presentation/screen/search_screen.dart';

import '../cubits/home_cubit.dart';
import '../cubits/home_state.dart';
import '../widget/create_post_card.dart';
import '../widget/home_thread_preview_block.dart';
import '../widget/home_header.dart';
import '../widget/post_divider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _toggleThreshold = 8.0;
  static const _barHeight = 78.0;

  late final ScrollController _scrollController;
  bool _isBottomBarVisible = true;
  bool _isHeaderCompact = false;
  double _lastOffset = 0;
  bool _isChatOpen = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
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
  }

  double _bottomSpace(BuildContext context) {
    return _barHeight + MediaQuery.paddingOf(context).bottom + 12;
  }

  User _buildCurrentUser(HomeState state) {
    final authUser = context.read<AuthCubit>().state.user;
    return User(
      id: authUser?.id ?? 'current_user',
      name: authUser?.displayName ?? state.currentUser.username,
      username: authUser?.username ?? state.currentUser.username,
      avatarUrl: authUser?.avatarUrl,
      avatarAssetPath: authUser?.avatarUrl == null
          ? state.currentUser.avatarAsset
          : null,
    );
  }

  Future<void> _openCreateThreadSheet(HomeState state) {
    return showCreateThreadSheet(
      context: context,
      currentUser: _buildCurrentUser(state),
      onSubmit: (request) => context.read<HomeCubit>().createPost(
        request.primaryContent,
        mediaUrls: request.mediaUrls,
      ),
    );
  }

  void _handleBottomTabTap(int index, HomeState state) {
    if (_isChatOpen) {
      setState(() => _isChatOpen = false);
    }

    // if (index == 2) {
    //   _openCreateThreadSheet(state);
    //   return;
    // }

    context.read<HomeCubit>().changeTab(index);
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

  @override
  Widget build(BuildContext context) {
    final selectedThemeMode = context.select(
      (ThemeModeCubit cubit) => cubit.state,
    );
    final currentUser = context.select((AuthCubit cubit) => cubit.state.user);

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final isSearchTab = state.selectedTabIndex == 1;
        final isReelsTab = state.selectedTabIndex == 2;
        final isActivityTab = state.selectedTabIndex == 3;
        final isProfileTab = state.selectedTabIndex == 4;
        final shouldShowBottomBar =
            _isChatOpen ||
            isSearchTab ||
          isReelsTab ||
            isActivityTab ||
            isProfileTab ||
            _isBottomBarVisible;

        return PopScope(
          canPop: !_isChatOpen,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && _isChatOpen) {
              setState(() => _isChatOpen = false);
            }
          },
          child: Scaffold(
            body: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  if (_isChatOpen)
                    ChatInboxScreen(bottomPadding: _bottomSpace(context))
                  else if (isSearchTab)
                    SearchScreen(bottomPadding: _bottomSpace(context))
                  else if (isActivityTab)
                    ActivityScreen(bottomPadding: _bottomSpace(context))
                  else if (isReelsTab)
                    ReelsPage(bottomPadding: _bottomSpace(context))
                  else if (isProfileTab)
                    currentUser == null
                        ? const Center(child: Text('Không thể tải hồ sơ.'))
                        : ProfileScreen(
                            userId: currentUser.id,
                            bottomPadding: _bottomSpace(context),
                          )
                  else
                    Column(
                      children: [
                        HomeHeader(isCompact: _isHeaderCompact),
                        Expanded(
                          child: ListView.separated(
                            controller: _scrollController,
                            padding: EdgeInsets.only(
                              bottom: shouldShowBottomBar
                                  ? _bottomSpace(context)
                                  : 12,
                            ),
                            itemCount: state.rootThreads.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return CreatePostCard(
                                  currentUser: state.currentUser,
                                  onTap: () => _openCreateThreadSheet(state),
                                );
                              }

                              final rootThread = state.rootThreads[index - 1];
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
                            separatorBuilder: (_, __) => const PostDivider(),
                          ),
                        ),
                      ],
                    ),
                  if (!_isChatOpen &&
                      !isSearchTab &&
                      !isReelsTab &&
                      !isActivityTab &&
                      !isProfileTab)
                    Positioned(
                      top: 8,
                      right: 10,
                      child: Row(
                        children: [
                          _ChatButton(
                            onTap: () => setState(() => _isChatOpen = true),
                          ),
                          const SizedBox(width: 8),
                          _ThemeModeMenuButton(
                            selectedThemeMode: selectedThemeMode,
                            onSelected: context
                                .read<ThemeModeCubit>()
                                .setThemeMode,
                          ),
                        ],
                      ),
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
                            onTap: (index) => _handleBottomTabTap(index, state),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChatButton extends StatelessWidget {
  const _ChatButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: IconButton(
        tooltip: 'Tin nhắn',
        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
        color: colorScheme.onSurface,
        onPressed: onTap,
      ),
    );
  }
}

class _ThemeModeMenuButton extends StatelessWidget {
  const _ThemeModeMenuButton({
    required this.selectedThemeMode,
    required this.onSelected,
  });

  final ThemeMode selectedThemeMode;
  final ValueChanged<ThemeMode> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: PopupMenuButton<ThemeMode>(
        key: const Key('theme_mode_menu_button'),
        tooltip: 'Chế độ giao diện',
        initialValue: selectedThemeMode,
        onSelected: onSelected,
        icon: Icon(
          _iconForThemeMode(selectedThemeMode),
          size: 20,
          color: colorScheme.onSurface,
        ),
        itemBuilder: (context) => [
          _buildThemeModeItem(
            context,
            value: ThemeMode.system,
            label: 'Theo hệ thống',
            selectedThemeMode: selectedThemeMode,
          ),
          _buildThemeModeItem(
            context,
            value: ThemeMode.light,
            label: 'Sáng',
            selectedThemeMode: selectedThemeMode,
          ),
          _buildThemeModeItem(
            context,
            value: ThemeMode.dark,
            label: 'Tối',
            selectedThemeMode: selectedThemeMode,
          ),
        ],
      ),
    );
  }

  static PopupMenuItem<ThemeMode> _buildThemeModeItem(
    BuildContext context, {
    required ThemeMode value,
    required String label,
    required ThemeMode selectedThemeMode,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuItem<ThemeMode>(
      value: value,
      child: Row(
        children: [
          Expanded(child: Text(label)),
          if (selectedThemeMode == value)
            Icon(Icons.check, size: 18, color: colorScheme.primary),
        ],
      ),
    );
  }

  static IconData _iconForThemeMode(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
    }
  }
}
