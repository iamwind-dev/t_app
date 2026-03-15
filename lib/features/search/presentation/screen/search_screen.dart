import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/search_tokens.dart';
import '../widget/search_account_tile.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key, required this.bottomPadding});

  final double bottomPadding;

  static const List<SearchAccountItem> _accounts = [
    SearchAccountItem(
      handle: 'threadsapp',
      subtitle: 'Threads',
      followers: '35 followers',
      topPadding: SearchTokens.firstTileTopPadding,
      bottomPadding: SearchTokens.tileVerticalPadding,
    ),
    SearchAccountItem(
      handle: 'ankurwarikoo',
      subtitle: 'Ankur Warikoo',
      followers: '916k followers',
      mutualFollowersAsset: 'assets/icons/search/search_mutuals.svg',
    ),
    SearchAccountItem(
      handle: 'Facebook',
      subtitle: 'Facebook',
      followers: '242k followers',
    ),
    SearchAccountItem(
      handle: 'nba',
      subtitle: 'nbaclub',
      followers: '3.2M followers',
    ),
    SearchAccountItem(
      handle: 'shakira',
      subtitle: 'shakira',
      followers: '3.2M followers',
    ),
    SearchAccountItem(
      handle: 'Instagram',
      subtitle: 'instagram',
      followers: '3.2M followers',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: SearchTokens.pageBackground(context),
      child: ListView(
        padding: EdgeInsets.only(bottom: bottomPadding),
        children: [
          const _HeaderSection(),
          const SizedBox(height: SearchTokens.listTopGap),
          for (final account in _accounts) SearchAccountTile(item: account),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SearchTokens.horizontalPadding,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: SearchTokens.sectionVerticalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Search', style: SearchTokens.title(context)),
            const SizedBox(height: SearchTokens.titleToSearchGap),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SearchTokens.searchFieldHorizontalPadding,
                vertical: SearchTokens.searchFieldVerticalPadding,
              ),
              decoration: BoxDecoration(
                color: SearchTokens.searchFieldBackground(context),
                borderRadius: SearchTokens.searchBorderRadius,
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/search/search_magnifier.svg',
                    width: SearchTokens.searchIconSize,
                    height: SearchTokens.searchIconSize,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        width: SearchTokens.searchIconSize,
                        height: SearchTokens.searchIconSize,
                      );
                    },
                  ),
                  const SizedBox(width: SearchTokens.searchIconGap),
                  Expanded(
                    child: Text(
                      'Search',
                      style: SearchTokens.searchHint(context),
                    ),
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
