import 'package:flutter/material.dart';
import 'package:t_app/core/theme/app_icon_tokens.dart';
import 'package:t_app/generated/assets.gen.dart';

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
