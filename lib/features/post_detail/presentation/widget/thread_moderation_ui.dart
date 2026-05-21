import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/posts/data/moderation_result.dart';

/// Maps backend moderation labels to short Vietnamese UI text.
String moderationLabelText(String label) => switch (label) {
  'clean' => 'An toan',
  'offensive' => 'Ngon tu xuc pham',
  'hate' => 'Thu ghet',
  'discrimination' => 'Phan biet vung mien',
  'supportive' => 'Ung ho',
  'other' => 'Khac',
  _ => 'Khong xac dinh',
};

/// Chooses a semantic accent color from the current theme.
Color moderationColor(
  BuildContext context, {
  required String action,
  required String label,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return switch (action) {
    'BLOCK_OR_REVIEW' => colorScheme.error,
    'WARN_USER' => colorScheme.tertiary,
    'ALLOW' => label == 'clean'
        ? colorScheme.primary
        : colorScheme.secondary,
    _ => colorScheme.onSurfaceVariant,
  };
}

/// Chooses the leading icon for moderation states.
IconData moderationIcon(String action) => switch (action) {
  'BLOCK_OR_REVIEW' => Icons.report_gmailerrorred_rounded,
  'WARN_USER' => Icons.warning_amber_rounded,
  'ALLOW' => Icons.check_circle_outline_rounded,
  _ => Icons.info_outline_rounded,
};

/// Returns the placeholder text used when the backend restricts visibility.
String moderationPlaceholderText(ThreadItemModel thread) {
  if (thread.visibilityLevel == 'hidden') {
    return 'Noi dung bi han che hien thi';
  }

  return 'Noi dung nay dang duoc xem xet';
}

Future<bool> showModerationWarningDialog(
  BuildContext context,
  ModerationResult moderation,
) async {
  final shouldContinue = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final colorScheme = Theme.of(dialogContext).colorScheme;
      final accent = moderationColor(
        dialogContext,
        action: moderation.action,
        label: moderation.finalLabel,
      );
      final isBlockOrReview = moderation.action == 'BLOCK_OR_REVIEW';

      return AlertDialog(
        icon: Icon(
          moderationIcon(moderation.action),
          color: accent,
        ),
        title: Text(
          isBlockOrReview
              ? 'Noi dung co the bi han che'
              : 'Canh bao noi dung',
        ),
        content: Text(
          isBlockOrReview
              ? 'Noi dung nay co dau hieu vi pham nghiem trong. Neu van tiep tuc dang, noi dung se bi lam mo va co the cho kiem duyet.'
              : 'Noi dung cua ban co the chua ngon tu khong phu hop. Neu ban van tiep tuc dang, noi dung nay co the bi lam mo hoac han che hien thi.',
          style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Chinh sua'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Van dang'),
          ),
        ],
      );
    },
  );

  return shouldContinue ?? false;
}

Widget buildModeratedContent({
  required BuildContext context,
  required Widget child,
  required bool shouldBlur,
  required String? moderationLabel,
  required String? moderationAction,
}) {
  if (!shouldBlur) {
    return child;
  }

  final colorScheme = Theme.of(context).colorScheme;

  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Stack(
      children: [
        Opacity(
          opacity: 0.22,
          child: IgnorePointer(child: child),
        ),
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Opacity(
              opacity: 0.9,
              child: IgnorePointer(child: child),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.18),
            ),
          ),
        ),
      ],
    ),
  );
}

TextSpan buildModeratedTextSpan({
  required BuildContext context,
  required String content,
  required TextStyle? style,
  required bool shouldBlur,
  required String moderationAction,
  required String moderationLabel,
}) {
  final effectiveStyle = style ?? DefaultTextStyle.of(context).style;
  final baseColor =
      effectiveStyle.color ?? Theme.of(context).colorScheme.onSurface;
  final blurredStyle = shouldBlur
      ? effectiveStyle.copyWith(
          foreground: Paint()
            ..color = baseColor.withValues(alpha: 0.52)
            ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6),
          shadows: [
            Shadow(
              color: baseColor.withValues(alpha: 0.24),
              blurRadius: 14,
            ),
          ],
        )
      : effectiveStyle;

  return TextSpan(
    style: blurredStyle,
    children: [
      TextSpan(text: content),
      if (shouldBlur)
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: buildModerationTrailingIcon(
            context,
            moderationAction: moderationAction,
            moderationLabel: moderationLabel,
          ),
        ),
    ],
  );
}

Widget buildModerationTrailingIcon(
  BuildContext context, {
  required String moderationAction,
  required String moderationLabel,
}) {
  final accent = moderationColor(
    context,
    action: moderationAction,
    label: moderationLabel,
  );

  return Padding(
    padding: const EdgeInsetsDirectional.only(start: 2),
    child: Icon(
      moderationIcon(moderationAction),
      size: 16,
      color: accent,
    ),
  );
}

Widget buildModeratedTextWithTrailingIcon({
  required BuildContext context,
  required String content,
  required TextStyle? textStyle,
  required bool shouldBlur,
  required String moderationAction,
  required String moderationLabel,
}) {
  return Text.rich(
    buildModeratedTextSpan(
      context: context,
      content: content,
      style: textStyle,
      shouldBlur: shouldBlur,
      moderationAction: moderationAction,
      moderationLabel: moderationLabel,
    ),
  );
}

/// Renders the shared moderation chip used in feed, detail, and reply items.
class ThreadModerationChip extends StatelessWidget {
  const ThreadModerationChip({super.key, required this.thread});

  final ThreadItemModel thread;

  @override
  Widget build(BuildContext context) {
    final accent = moderationColor(
      context,
      action: thread.moderationAction,
      label: thread.moderationLabel,
    );
    final colorScheme = Theme.of(context).colorScheme;
    final label = thread.moderationAction == 'WARN_USER'
        ? 'Canh bao'
        : moderationLabelText(thread.moderationLabel);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accent.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            moderationIcon(thread.moderationAction),
            size: 14,
            color: accent,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (thread.moderationAction == 'BLOCK_OR_REVIEW') ...[
            const SizedBox(width: 6),
            Text(
              'Dang review',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
