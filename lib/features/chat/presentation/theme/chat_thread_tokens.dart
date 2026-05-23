import 'package:flutter/material.dart';

@immutable
final class ChatThreadTokens {
  const ChatThreadTokens._();

  static Color pageBackground(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color primaryText(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color secondaryText(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  static Color incomingBubble(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Color.alphaBlend(
      colorScheme.onSurface.withValues(alpha: 0.047),
      colorScheme.surface,
    );
  }

  static Color outgoingBubble(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color outgoingText(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static const double headerHeight = 65;
  static const double headerHorizontalPadding = 24;
  static const double headerAvatarSize = 30;
  static const double headerBackSize = 32;
  static const double headerActionSize = 48;
  static const double headerBackToAvatarGap = 23;
  static const double headerAvatarToTextGap = 14;
  static const double headerMoreDotSize = 5.7;
  static const double headerMoreDotGap = 4;
  static const double profileTopGap = 7;
  static const double profileAvatarSize = 100;
  static const double profileAvatarToNameGap = 17;
  static const double profileMetaGap = 2;
  static const double profileActionTopGap = 17;
  static const double profileActionIconSize = 42;
  static const double profileActionLabelGap = 10;
  static const double profileActionLineHeight = 24 / 16;
  static const double profileToFirstDateGap = 31;
  static const double dateToIncomingGap = 35;
  static const double incomingToDateGap = 38;
  static const double dateToSecondIncomingGap = 38;
  static const double incomingToOutgoingGap = 35;
  static const double bodyBottomGap = 24;
  static const double messageRowHorizontalPadding = 16;
  static const double messageAvatarSize = 32;
  static const double incomingBubbleGap = 8;
  static const double bubbleHeight = 40;
  static const double shortIncomingBubbleWidth = 44;
  static const double longIncomingBubbleWidth = 120;
  static const double outgoingBubbleWidth = 62;
  static const double incomingBubbleRadius = 28;
  static const double outgoingBubbleRadius = 30;
  static const double outgoingRightPadding = 23;
  static const double seenTopGap = 8;
  static const double seenRightPadding = 31;
  static const double seenLineHeight = 24 / 16;
  static const double composerHeight = 52;
  static const double composerHorizontalGap = 12;
  static const double composerLeftPadding = 14;
  static const double composerRightPadding = 20;
  static const double composerVerticalPadding = 6;
  static const double composerButtonSize = 40;
  static const double composerIconSize = 30;
  static const double composerInputHorizontalPadding = 24;
  static const double composerInputRadius = 30;

  static const BorderRadius incomingBubbleBorderRadius = BorderRadius.all(
    Radius.circular(incomingBubbleRadius),
  );

  static const BorderRadius outgoingBubbleBorderRadius = BorderRadius.all(
    Radius.circular(outgoingBubbleRadius),
  );

  static const BorderRadius composerBorderRadius = BorderRadius.all(
    Radius.circular(composerInputRadius),
  );

  static TextStyle headerUsername(BuildContext context) {
    final theme = Theme.of(context);
    return (theme.textTheme.titleMedium ?? const TextStyle()).copyWith(
      color: primaryText(context),
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 24.2 / 16,
    );
  }

  static TextStyle headerName(BuildContext context) {
    final theme = Theme.of(context);
    return (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
      color: secondaryText(context),
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 27 / 16,
    );
  }

  static TextStyle profileUsername(BuildContext context) {
    final theme = Theme.of(context);
    return (theme.textTheme.headlineMedium ?? const TextStyle()).copyWith(
      color: primaryText(context),
      fontSize: 30,
      fontWeight: FontWeight.w800,
      height: 54 / 30,
    );
  }

  static TextStyle profileMeta(BuildContext context) {
    final theme = Theme.of(context);
    return (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
      color: secondaryText(context),
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 30 / 16,
    );
  }

  static TextStyle dateLabel(BuildContext context) {
    final theme = Theme.of(context);
    return (theme.textTheme.titleMedium ?? const TextStyle()).copyWith(
      color: secondaryText(context),
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 25.5 / 16,
    );
  }

  static TextStyle message(BuildContext context) {
    final theme = Theme.of(context);
    return (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
      color: primaryText(context),
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 33 / 16,
    );
  }

  static TextStyle outgoingMessage(BuildContext context) {
    return message(context).copyWith(color: outgoingText(context));
  }

  static TextStyle composerPlaceholder(BuildContext context) {
    return message(context).copyWith(color: secondaryText(context));
  }
}
