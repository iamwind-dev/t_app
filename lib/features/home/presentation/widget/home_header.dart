import 'package:flutter/material.dart';
import 'package:t_app/core/theme/app_icon_tokens.dart';
import 'package:t_app/generated/assets.gen.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    this.isCompact = false,
    this.onSearchTap,
    this.stretchOffset = 0,
  });

  static const _animationDuration = Duration(milliseconds: 240);

  final bool isCompact;
  final VoidCallback? onSearchTap;
  final double stretchOffset;

  @override
  Widget build(BuildContext context) {
    final stretchProgress = (stretchOffset / 90).clamp(0.0, 1.0);
    final topSpace = (isCompact ? 4.0 : 10.0) + (stretchOffset * 0.14);
    final logoWidth = (isCompact ? 24.0 : 36.0) + (stretchProgress * 6);
    final logoHeight = (isCompact ? 28.0 : 42.0) + (stretchProgress * 8);
    final actionSlotWidth = (isCompact ? 40.0 : 48.0) + (stretchProgress * 2);
    final searchIconSize = (isCompact ? 24.0 : 28.0) + (stretchProgress * 2);
    final bottomSpace = (isCompact ? 8.0 : 16.0) + (stretchOffset * 0.08);
    final contentScale = 1 + (stretchProgress * 0.04);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          AnimatedContainer(
            duration: _animationDuration,
            curve: Curves.easeInOutCubic,
            height: topSpace,
          ),
          Transform.scale(
            scale: contentScale,
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                AnimatedContainer(
                  duration: _animationDuration,
                  curve: Curves.easeInOutCubic,
                  width: actionSlotWidth,
                ),
                Expanded(
                  child: Center(
                    child: AnimatedContainer(
                      duration: _animationDuration,
                      curve: Curves.easeInOutCubic,
                      width: logoWidth,
                      height: logoHeight,
                      child: Assets.icons.logo.svg(
                        key: const Key('home_header_logo'),
                        width: logoWidth,
                        height: logoHeight,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                          AppIconTokens.logo(context),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: _animationDuration,
                  curve: Curves.easeInOutCubic,
                  width: actionSlotWidth,
                  child: IconButton(
                    icon: AnimatedSwitcher(
                      duration: _animationDuration,
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(
                        scale: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      ),
                      child: Icon(
                        Icons.search,
                        key: ValueKey(searchIconSize),
                        size: searchIconSize,
                      ),
                    ),
                    color: Theme.of(context).colorScheme.onSurface,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    onPressed: onSearchTap,
                  ),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: _animationDuration,
            curve: Curves.easeInOutCubic,
            height: bottomSpace,
          ),
          // Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor),
        ],
      ),
    );
  }
}
