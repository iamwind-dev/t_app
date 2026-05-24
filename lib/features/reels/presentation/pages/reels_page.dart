import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/features/reels/presentation/cubits/reels_cubit.dart';
import 'package:t_app/features/reels/presentation/cubits/reels_state.dart';
import 'package:t_app/features/reels/presentation/widget/reel_overlay.dart';
import 'package:t_app/features/reels/presentation/widget/reel_video_player.dart';

class ReelsPage extends StatefulWidget {
  const ReelsPage({super.key, required this.bottomPadding});

  final double bottomPadding;

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  late final PageController _pageController;
  bool _isRefreshingFromTop = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _refreshFromTop() async {
    if (_isRefreshingFromTop) {
      return;
    }

    _isRefreshingFromTop = true;
    try {
      await context.read<ReelsCubit>().refreshReels();
      if (_pageController.hasClients) {
        await _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
    } finally {
      _isRefreshingFromTop = false;
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }

    final isAtTop = !_pageController.hasClients ||
        (_pageController.page?.round() ?? _pageController.initialPage) == 0;
    if (isAtTop &&
        notification is OverscrollNotification &&
        notification.overscroll < 0) {
      _refreshFromTop();
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final overlayBottomInset =
        (widget.bottomPadding - 12).clamp(0.0, double.infinity);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BlocBuilder<ReelsCubit, ReelsState>(
            builder: (context, state) {
              if (state is ReelsLoading || state is ReelsInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (state is ReelsError) {
                return Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }

              if (state is ReelsLoaded) {
                if (state.reels.isEmpty) {
                  return const Center(
                    child: Text(
                      'No reels yet',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: _handleScrollNotification,
                  child: PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    itemCount: state.reels.length,
                    onPageChanged: (index) {
                      if (index == state.reels.length - 1) {
                        context.read<ReelsCubit>().loadMoreReels();
                      }
                    },
                    itemBuilder: (context, index) {
                      final reel = state.reels[index];

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          ReelVideoPlayer(videoUrl: reel.videoUrl),
                          ReelOverlay(
                            reel: reel,
                            bottomInset: overlayBottomInset,
                            onLike: () {
                              context.read<ReelsCubit>().toggleLike(reel.id);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
