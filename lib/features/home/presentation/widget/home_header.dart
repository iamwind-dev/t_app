import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, this.isCompact = false});

  static const _animationDuration = Duration(milliseconds: 240);

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final topSpace = isCompact ? 4.0 : 10.0;
    final logoWidth = isCompact ? 24.0 : 36.0;
    final logoHeight = isCompact ? 28.0 : 42.0;
    final bottomSpace = isCompact ? 8.0 : 16.0;

    return Column(
      children: [
        AnimatedContainer(
          duration: _animationDuration,
          curve: Curves.easeInOutCubic,
          height: topSpace,
        ),
        AnimatedContainer(
          duration: _animationDuration,
          curve: Curves.easeInOutCubic,
          width: logoWidth,
          height: logoHeight,
          child: Image.asset(
            'assets/images/home_threads_logo.png',
            fit: BoxFit.contain,
          ),
        ),
        AnimatedContainer(
          duration: _animationDuration,
          curve: Curves.easeInOutCubic,
          height: bottomSpace,
        ),
        Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor),
      ],
    );
  }
}
