import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:t_app/features/users/presentation/widgets/user_avatar_button.dart';
import 'package:t_app/features/users/presentation/widgets/user_name_button.dart';

import '../theme/search_tokens.dart';

@immutable
class SearchAccountItem {
  const SearchAccountItem({
    required this.userId,
    required this.handle,
    required this.subtitle,
    required this.followers,
    required this.isFollowing,
    this.avatarUrl,
    this.mutualFollowersAsset,
    this.topPadding = SearchTokens.tileVerticalPadding,
    this.bottomPadding = SearchTokens.tileVerticalPadding,
  });

  final String userId;
  final String handle;
  final String subtitle;
  final String followers;
  final bool isFollowing;
  final String? avatarUrl;
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
  const SearchAccountTile({super.key, required this.item, this.onFollowTap});

  final SearchAccountItem item;
  final VoidCallback? onFollowTap;

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
              child: UserAvatarButton(
                userId: item.userId,
                avatarUrl: item.avatarUrl,
                displayName: item.subtitle,
                username: item.handle,
                size: SearchTokens.avatarSize,
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
                  _FollowButton(item: item, onTap: onFollowTap),
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
              child: UserNameButton(
                userId: item.userId,
                label: item.handle,
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
  const _FollowButton({required this.item, required this.onTap});

  final SearchAccountItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: SearchTokens.followBorderRadius,
          border: Border.all(color: SearchTokens.borderFollow(context)),
          color: item.isFollowing
              ? Theme.of(context).colorScheme.surfaceContainerHigh
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SearchTokens.followHorizontalPadding,
            vertical: SearchTokens.followVerticalPadding,
          ),
          child: Text(
            item.isFollowing ? 'Following' : 'Follow',
            style: SearchTokens.follow(context),
          ),
        ),
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
