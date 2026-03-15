import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/search_tokens.dart';

@immutable
class SearchAccountItem {
  const SearchAccountItem({
    required this.handle,
    required this.subtitle,
    required this.followers,
    this.mutualFollowersAsset,
    this.topPadding = SearchTokens.tileVerticalPadding,
    this.bottomPadding = SearchTokens.tileVerticalPadding,
  });

  final String handle;
  final String subtitle;
  final String followers;
  final String? mutualFollowersAsset;
  final double topPadding;
  final double bottomPadding;

  String get avatarLetter {
    if (handle.isEmpty) {
      return '?';
    }
    return handle[0].toUpperCase();
  }
}

class SearchAccountTile extends StatelessWidget {
  const SearchAccountTile({super.key, required this.item});

  final SearchAccountItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SearchTokens.horizontalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: SearchTokens.avatarSize,
            height: SearchTokens.avatarSlotHeight,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: SearchTokens.avatarSize,
                height: SearchTokens.avatarSize,
                decoration: BoxDecoration(
                  color: SearchTokens.avatarLetterBackground(context),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  item.avatarLetter,
                  style: SearchTokens.avatarLetter(context),
                ),
              ),
            ),
          ),
          const SizedBox(width: SearchTokens.rowGap),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(
                top: item.topPadding,
                bottom: item.bottomPadding,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: SearchTokens.borderDivider(context),
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _AccountMeta(item: item)),
                  const SizedBox(width: SearchTokens.rowGap),
                  const _FollowButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountMeta extends StatelessWidget {
  const _AccountMeta({required this.item});

  final SearchAccountItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                item.handle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SearchTokens.handle(context),
              ),
            ),
            const SizedBox(width: SearchTokens.handleVerifiedGap),
            SvgPicture.asset(
              'assets/icons/search/search_verified.svg',
              width: SearchTokens.verifiedSize,
              height: SearchTokens.verifiedSize,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  width: SearchTokens.verifiedSize,
                  height: SearchTokens.verifiedSize,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: SearchTokens.subtitleGap),
        Text(item.subtitle, style: SearchTokens.subtitle(context)),
        const SizedBox(height: SearchTokens.followersGap),
        Row(
          children: [
            if (item.mutualFollowersAsset != null) ...[
              SvgPicture.asset(
                item.mutualFollowersAsset!,
                width: SearchTokens.mutualFollowersWidth,
                height: SearchTokens.mutualFollowersHeight,
                errorBuilder: (context, error, stackTrace) {
                  return const _MutualFollowersFallback();
                },
              ),
              const SizedBox(width: SearchTokens.mutualFollowersGap),
            ],
            Text(item.followers, style: SearchTokens.followers(context)),
          ],
        ),
      ],
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: SearchTokens.followBorderRadius,
        border: Border.all(color: SearchTokens.borderFollow(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SearchTokens.followHorizontalPadding,
          vertical: SearchTokens.followVerticalPadding,
        ),
        child: Text('Follow', style: SearchTokens.follow(context)),
      ),
    );
  }
}

class _MutualFollowersFallback extends StatelessWidget {
  const _MutualFollowersFallback();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: SearchTokens.mutualFollowersWidth,
      height: SearchTokens.mutualFollowersHeight,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: _FallbackCircleAvatar(
              color: SearchTokens.mutualFollowersLeft(context),
            ),
          ),
          Positioned(
            right: 0,
            child: _FallbackCircleAvatar(
              color: SearchTokens.mutualFollowersRight(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _FallbackCircleAvatar extends StatelessWidget {
  const _FallbackCircleAvatar({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SearchTokens.mutualFollowersHeight,
      height: SearchTokens.mutualFollowersHeight,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: SearchTokens.avatarRing(context),
          width: 1.17,
        ),
      ),
    );
  }
}
