import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/core/widget/home_bottom_tab_bar.dart';
import 'package:t_app/core/theme/theme_mode_cubit.dart';
import 'package:t_app/features/search/presentation/screen/search_screen.dart';

import '../cubits/home_cubit.dart';
import '../cubits/home_state.dart';
import '../widget/create_post_card.dart';
import '../widget/home_header.dart';
import '../widget/post_divider.dart';
import '../widget/thread_post_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final selectedThemeMode = context.select(
      (ThemeModeCubit cubit) => cubit.state,
    );

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final isSearchTab = state.selectedTabIndex == 1;
        final shouldShowBottomBar = isSearchTab || _isBottomBarVisible;

        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                if (isSearchTab)
                  SearchScreen(bottomPadding: _bottomSpace(context))
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
                          itemCount: state.feedItems.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return CreatePostCard(
                                currentUser: state.currentUser,
                                onTap: () {},
                              );
                            }

                            return ThreadItemCard(
                              data: state.feedItems[index - 1],
                            );
                          },
                          separatorBuilder: (_, __) {
                            return const PostDivider();
                          },
                        ),
                      ),
                    ],
                  ),
                Positioned(
                  top: 8,
                  right: 10,
                  child: _ThemeModeMenuButton(
                    selectedThemeMode: selectedThemeMode,
                    onSelected: context.read<ThemeModeCubit>().setThemeMode,
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
                          onTap: context.read<HomeCubit>().changeTab,
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
        tooltip: 'Theme mode',
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
            label: 'System',
            selectedThemeMode: selectedThemeMode,
          ),
          _buildThemeModeItem(
            context,
            value: ThemeMode.light,
            label: 'Light',
            selectedThemeMode: selectedThemeMode,
          ),
          _buildThemeModeItem(
            context,
            value: ThemeMode.dark,
            label: 'Dark',
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
