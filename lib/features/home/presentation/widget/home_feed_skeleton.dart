import 'package:flutter/material.dart';

class HomeFeedSkeletonList extends StatelessWidget {
  const HomeFeedSkeletonList({
    super.key,
    this.itemCount = 5,
    this.includeComposerGap = false,
    this.bottomPadding = 0,
  });

  final int itemCount;
  final bool includeComposerGap;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      itemCount: itemCount + (includeComposerGap ? 1 : 0),
      itemBuilder: (context, index) {
        if (includeComposerGap && index == 0) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: _ComposerSkeletonCard(),
          );
        }

        return const Padding(
          padding: EdgeInsets.fromLTRB(0, 14, 0, 16),
          child: PostSkeletonCard(),
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 1),
    );
  }
}

class PostSkeletonCard extends StatelessWidget {
  const PostSkeletonCard({super.key, this.showMedia = true});

  final bool showMedia;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final baseColor = scheme.surfaceContainerHighest.withValues(alpha: 0.75);
    final highlightColor = scheme.surface.withValues(alpha: 0.92);

    return _SkeletonShimmer(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: 56,
              child: Column(
                children: [
                  SizedBox(height: 2),
                  _SkeletonBox(width: 36, height: 36, radius: 999),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      _SkeletonBox(width: 110, height: 14, radius: 8),
                      SizedBox(width: 8),
                      _SkeletonBox(width: 44, height: 10, radius: 8),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const _SkeletonBox(width: double.infinity, height: 12, radius: 8),
                  const SizedBox(height: 6),
                  const _SkeletonBox(width: 220, height: 12, radius: 8),
                  if (showMedia) ...[
                    const SizedBox(height: 12),
                    const _SkeletonBox(
                      width: double.infinity,
                      height: 188,
                      radius: 18,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      _SkeletonBox(width: 24, height: 24, radius: 999),
                      SizedBox(width: 24),
                      _SkeletonBox(width: 24, height: 24, radius: 999),
                      SizedBox(width: 24),
                      _SkeletonBox(width: 24, height: 24, radius: 999),
                      SizedBox(width: 24),
                      _SkeletonBox(width: 24, height: 24, radius: 999),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeLoadMoreSkeleton extends StatelessWidget {
  const HomeLoadMoreSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: Column(
        children: [
          PostSkeletonCard(showMedia: false),
          SizedBox(height: 12),
          PostSkeletonCard(showMedia: false),
        ],
      ),
    );
  }
}

class _ComposerSkeletonCard extends StatelessWidget {
  const _ComposerSkeletonCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _SkeletonShimmer(
      baseColor: scheme.surfaceContainerHighest.withValues(alpha: 0.72),
      highlightColor: scheme.surface.withValues(alpha: 0.94),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: const Row(
          children: [
            _SkeletonBox(width: 38, height: 38, radius: 999),
            SizedBox(width: 12),
            Expanded(
              child: _SkeletonBox(width: double.infinity, height: 14, radius: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonShimmer extends StatefulWidget {
  const _SkeletonShimmer({
    required this.child,
    required this.baseColor,
    required this.highlightColor,
  });

  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  @override
  State<_SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<_SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final slide = (_controller.value * 2) - 1;
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.8 + slide, -0.2),
              end: Alignment(1.8 + slide, 0.2),
              colors: [
                widget.baseColor,
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
                widget.baseColor,
              ],
              stops: const [0, 0.35, 0.5, 0.65, 1],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
