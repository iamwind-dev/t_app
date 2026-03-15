import 'package:flutter/material.dart';

class _BottomTabIcon {
  const _BottomTabIcon({
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
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const _icons = [
    _BottomTabIcon(
      selectedAsset: 'assets/icons/bottom/Light=Home_Select.png',
      deselectedAsset: 'assets/icons/bottom/Light=Home_Deselect.png',
    ),
    _BottomTabIcon(
      selectedAsset: 'assets/icons/bottom/Light=Search_Select.png',
      deselectedAsset: 'assets/icons/bottom/Light=Search_Deselect.png',
    ),
    _BottomTabIcon(
      selectedAsset: 'assets/icons/bottom/Light=Write_Select.png',
      deselectedAsset: 'assets/icons/bottom/Light=Write_Deselect.png',
    ),
    _BottomTabIcon(
      selectedAsset: 'assets/icons/bottom/Light=Activity_Select.png',
      deselectedAsset: 'assets/icons/bottom/Light=Activity_Deselect.png',
    ),
    _BottomTabIcon(
      selectedAsset: 'assets/icons/bottom/Light=Profile_Select.png',
      deselectedAsset: 'assets/icons/bottom/Light=Profile_Deselect.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 78 + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: List.generate(_icons.length, (index) {
          final icon = _icons[index];
          final iconAsset = selectedIndex == index
              ? icon.selectedAsset
              : icon.deselectedAsset;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(index),
              child: Center(
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 170),
                  scale: selectedIndex == index ? 1.0 : 0.92,
                  child: Image.asset(
                    iconAsset,
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
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
