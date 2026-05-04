import 'package:flutter/material.dart';

@immutable
final class ChatInboxTokens {
  const ChatInboxTokens._();

  static Color pageBackground(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color primaryText(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color secondaryText(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  static Color mutedIcon(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  static Color searchFieldBackground(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Color.alphaBlend(
      colorScheme.onSurface.withValues(alpha: 0.047),
      colorScheme.surface,
    );
  }

  static Color chipBackground(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Color.alphaBlend(
      colorScheme.onSurface.withValues(alpha: 0.035),
      colorScheme.surface,
    );
  }

  static Color chipBorder(BuildContext context) {
    return Theme.of(context).colorScheme.outline.withValues(alpha: 0.62);
  }

  static const double horizontalPadding = 24;
  static const double headerTopPadding = 16;
  static const double headerHeight = 48;
  static const double titleToSearchGap = 17;
  static const double searchHeight = 45;
  static const double searchRadius = 11;
  static const double searchIconSize = 20;
  static const double searchIconGap = 12;
  static const double searchHorizontalPadding = 18;
  static const double searchToFiltersGap = 11;
  static const double filterHeight = 35;
  static const double filterGap = 6;
  static const double filtersToListGap = 31;
  static const double avatarSize = 66;
  static const double previewTextGap = 16;

  static const BorderRadius searchBorderRadius = BorderRadius.all(
    Radius.circular(searchRadius),
  );

  static const BorderRadius chipBorderRadius = BorderRadius.all(
    Radius.circular(24),
  );

  static TextStyle title(BuildContext context) {
    final theme = Theme.of(context);
    return (theme.textTheme.headlineLarge ?? const TextStyle()).copyWith(
      color: primaryText(context),
      fontSize: 32,
      fontWeight: FontWeight.w900,
      height: 46.2 / 32,
      letterSpacing: -0.5,
    );
  }

  static TextStyle searchHint(BuildContext context) {
    final theme = Theme.of(context);
    return (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
      color: secondaryText(context),
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 33 / 16,
    );
  }

  static TextStyle chipLabel(BuildContext context) {
    final theme = Theme.of(context);
    return (theme.textTheme.labelLarge ?? const TextStyle()).copyWith(
      color: primaryText(context),
      fontSize: 13,
      fontWeight: FontWeight.w700,
      height: 28.5 / 13,
    );
  }

  static TextStyle username(BuildContext context) {
    final theme = Theme.of(context);
    return (theme.textTheme.labelLarge ?? const TextStyle()).copyWith(
      color: primaryText(context),
      fontSize: 13,
      fontWeight: FontWeight.w700,
      height: 1.25,
    );
  }

  static TextStyle metadata(BuildContext context) {
    final theme = Theme.of(context);
    return (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
      color: secondaryText(context),
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.35,
    );
  }
}
