import 'package:flutter/material.dart';

@immutable
final class SearchTokens {
  const SearchTokens._();

  static Color pageBackground(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color primaryText(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color borderDivider(BuildContext context) {
    return Theme.of(context).dividerColor;
  }

  static Color borderFollow(BuildContext context) {
    return Theme.of(context).colorScheme.outline;
  }

  static Color secondaryText(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  static Color hintText(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  static Color avatarLetterBackground(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);
  }

  static Color avatarLetterForeground(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color searchFieldBackground(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);
  }

  static Color avatarRing(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color mutualFollowersLeft(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.18);
  }

  static Color mutualFollowersRight(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24);
  }

  static const double horizontalPadding = 16;
  static const double sectionVerticalPadding = 16;
  static const double titleToSearchGap = 16;
  static const double listTopGap = 8;

  static const double statusIconsWidth = 78.33;
  static const double statusIconsHeight = 13;

  static const double searchFieldHorizontalPadding = 10;
  static const double searchFieldVerticalPadding = 8;
  static const double searchFieldRadius = 10;
  static const double searchIconSize = 24;
  static const double searchIconGap = 10;

  static const double rowGap = 16;
  static const double avatarSize = 48;
  static const double avatarSlotHeight = 72;
  static const double verifiedSize = 16;
  static const double handleVerifiedGap = 4;
  static const double subtitleGap = 2;
  static const double followersGap = 8;

  static const double mutualFollowersWidth = 28;
  static const double mutualFollowersHeight = 18.67;
  static const double mutualFollowersGap = 8;

  static const double followHorizontalPadding = 32;
  static const double followVerticalPadding = 8;
  static const double followRadius = 10;

  static const double firstTileTopPadding = 0;
  static const double tileVerticalPadding = 16;

  static const BorderRadius searchBorderRadius = BorderRadius.all(
    Radius.circular(searchFieldRadius),
  );

  static const BorderRadius followBorderRadius = BorderRadius.all(
    Radius.circular(followRadius),
  );

  static TextStyle statusTime(BuildContext context) {
    return const TextStyle(
      fontFamily: 'SF Pro',
      fontWeight: FontWeight.w600,
      fontSize: 17,
      height: 22 / 17,
    ).copyWith(color: primaryText(context));
  }

  static TextStyle title(BuildContext context) {
    return const TextStyle(
      fontFamily: 'SF Pro',
      fontWeight: FontWeight.w400,
      fontSize: 32,
      height: 22 / 32,
    ).copyWith(color: primaryText(context));
  }

  static TextStyle searchHint(BuildContext context) {
    return const TextStyle(
      fontFamily: 'SF Pro',
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 22 / 16,
    ).copyWith(color: hintText(context));
  }

  static TextStyle handle(BuildContext context) {
    return const TextStyle(
      fontFamily: 'SF Pro',
      fontWeight: FontWeight.w500,
      fontSize: 16,
      height: 22 / 16,
    ).copyWith(color: primaryText(context));
  }

  static TextStyle subtitle(BuildContext context) {
    return const TextStyle(
      fontFamily: 'SF Pro',
      fontWeight: FontWeight.w400,
      fontSize: 13,
      height: 22 / 13,
    ).copyWith(color: secondaryText(context));
  }

  static TextStyle followers(BuildContext context) {
    return const TextStyle(
      fontFamily: 'SF Pro Rounded',
      fontWeight: FontWeight.w300,
      fontSize: 16,
      height: 19.09375 / 16,
    ).copyWith(color: primaryText(context));
  }

  static TextStyle follow(BuildContext context) {
    return const TextStyle(
      fontFamily: 'SF Pro',
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 19.09375 / 16,
    ).copyWith(color: primaryText(context));
  }

  static TextStyle avatarLetter(BuildContext context) {
    return const TextStyle(
      fontFamily: 'SF Pro',
      fontWeight: FontWeight.w600,
      fontSize: 20,
      height: 24 / 20,
    ).copyWith(color: avatarLetterForeground(context));
  }
}
