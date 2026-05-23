import 'package:flutter/material.dart';
import 'package:native_liquid_glass/native_liquid_glass.dart';
import 'package:t_app/core/theme/app_icon_tokens.dart';
import 'package:t_app/core/widget/home_bottom_tab_bar.dart';

class AdaptiveBottomNavBar extends StatelessWidget {
  const AdaptiveBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.useNativeLiquidGlass,
    this.onReelsCreateTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool useNativeLiquidGlass;
  final VoidCallback? onReelsCreateTap;

  static const double iosGlassHeight = 68;
  static const double iosGlassHorizontalMargin = 16;
  static const double iosGlassBottomMargin = 8;

  @override
  Widget build(BuildContext context) {
    if (!useNativeLiquidGlass) {
      return HomeBottomTabBar(
        selectedIndex: selectedIndex,
        onTap: onTap,
        onReelsCreateTap: onReelsCreateTap,
      );
    }

    return _IOSNativeLiquidGlassBottomNavBar(
      selectedIndex: selectedIndex,
      onTap: onTap,
      onReelsCreateTap: onReelsCreateTap,
    );
  }
}

class _IOSNativeLiquidGlassBottomNavBar extends StatelessWidget {
  const _IOSNativeLiquidGlassBottomNavBar({
    required this.selectedIndex,
    required this.onTap,
    this.onReelsCreateTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onReelsCreateTap;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AdaptiveBottomNavBar.iosGlassHorizontalMargin,
          0,
          AdaptiveBottomNavBar.iosGlassHorizontalMargin,
          AdaptiveBottomNavBar.iosGlassBottomMargin,
        ),
        child: LiquidGlassContainer(
          height: AdaptiveBottomNavBar.iosGlassHeight + bottomInset,
          config: LiquidGlassConfig(
            shape: LiquidGlassEffectShape.capsule,
            effect: LiquidGlassEffect.regular,
            interactive: false,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, 6, 8, 6 + bottomInset),
            child: Row(
              children: List.generate(HomeBottomTabBar.icons.length, (index) {
                final icon = HomeBottomTabBar.icons[index];
                final isSelected = selectedIndex == index;
                final isReelsCreateAction =
                    index == 2 && isSelected && onReelsCreateTap != null;
                final iconAsset = isSelected
                    ? icon.selectedAsset
                    : icon.deselectedAsset;
                final iconColor = isSelected
                    ? AppIconTokens.navigationSelected(context)
                    : AppIconTokens.navigationUnselected(context);

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: isReelsCreateAction
                        ? onReelsCreateTap
                        : () => onTap(index),
                    child: Center(
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 170),
                        curve: Curves.easeOut,
                        scale: isSelected ? 1.0 : 0.92,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          width: isSelected ? 46 : 40,
                          height: isSelected ? 46 : 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.12)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isReelsCreateAction
                                ? Icon(
                                    Icons.add_rounded,
                                    size: 30,
                                    color: iconColor,
                                  )
                                : ImageIcon(
                                    AssetImage(iconAsset),
                                    size: 28,
                                    color: iconColor,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
