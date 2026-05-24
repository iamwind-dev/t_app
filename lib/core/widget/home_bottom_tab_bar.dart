import 'package:flutter/material.dart';

import 'package:t_app/core/theme/app_icon_tokens.dart';

class BottomTabIconAssets {
  const BottomTabIconAssets({
    required this.selectedAsset,
    required this.deselectedAsset,
  });

  final String selectedAsset;
  final String deselectedAsset;
}

class HomeBottomTabBar extends StatelessWidget {
  const HomeBottomTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.onReelsCreateTap,
    this.backgroundColor,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onReelsCreateTap;
  final Color? backgroundColor;

  static const double baseHeight = 60;

  static const icons = [
    BottomTabIconAssets(
      selectedAsset: 'assets/icons/bottom/Light=Home_Select.png',
      deselectedAsset: 'assets/icons/bottom/Light=Home_Deselect.png',
    ),
    BottomTabIconAssets(
      selectedAsset: 'assets/icons/bottom/send_deselect.png',
      deselectedAsset: 'assets/icons/bottom/send.png',
    ),
    BottomTabIconAssets(
      selectedAsset: 'assets/icons/bottom/Light=Reel_Select.png',
      deselectedAsset: 'assets/icons/bottom/Light=Reel_Deselect.png',
    ),
    BottomTabIconAssets(
      selectedAsset: 'assets/icons/bottom/Light=Activity_Select.png',
      deselectedAsset: 'assets/icons/bottom/Light=Activity_Deselect.png',
    ),
    BottomTabIconAssets(
      selectedAsset: 'assets/icons/bottom/Light=Profile_Select.png',
      deselectedAsset: 'assets/icons/bottom/Light=Profile_Deselect.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: baseHeight + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        // border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: List.generate(icons.length, (index) {
          final icon = icons[index];
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
              onTap: isReelsCreateAction ? onReelsCreateTap : () => onTap(index),
              child: Center(
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 170),
                  scale: isSelected ? 1.0 : 0.92,
                  child: isReelsCreateAction
                      ? Icon(
                          Icons.add_rounded,
                          size: 32,
                          color: iconColor,
                        )
                      : ImageIcon(
                          AssetImage(iconAsset),
                          size: 30,
                          color: iconColor,
                        ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
