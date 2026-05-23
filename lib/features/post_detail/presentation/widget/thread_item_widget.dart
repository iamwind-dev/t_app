import 'package:flutter/material.dart';
import 'package:t_app/core/theme/app_icon_tokens.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/users/presentation/widgets/user_avatar_button.dart';
import 'package:t_app/features/users/presentation/widgets/user_name_button.dart';

import 'thread_media_section.dart';
import 'thread_moderation_ui.dart';

class ThreadItemWidget extends StatelessWidget {
  const ThreadItemWidget({
    super.key,
    required this.thread,
    this.onTap,
    this.onReplyTap,
    this.onLikeTap,
    this.onRepostTap,
    this.onShareTap,
    this.onShowRepliesTap,
    this.showTopConnector = false,
    this.showBottomConnector = false,
    this.showTimelineConnectors = true,
    this.showReplyHint = true,
    this.isRepliesExpanded = false,
    this.highlighted = false,
    this.enableContentBlurDemo = false,
  });

  final ThreadItemModel thread;
  final VoidCallback? onTap;
  final VoidCallback? onReplyTap;
  final VoidCallback? onLikeTap;
  final VoidCallback? onRepostTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onShowRepliesTap;
  final bool showTopConnector;
  final bool showBottomConnector;
  final bool showTimelineConnectors;
  final bool showReplyHint;
  final bool isRepliesExpanded;
  final bool highlighted;
  final bool enableContentBlurDemo;

  static const double timelineWidth = 56;
  static const double avatarRadius = 18;
  static const double timelineGap = 12;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final content = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: timelineWidth,
            child: _ThreadTimelineColumn(
              thread: thread,
              showTopConnector: showTopConnector,
              showBottomConnector: showBottomConnector,
              showTimelineConnectors: showTimelineConnectors,
            ),
          ),
          const SizedBox(width: timelineGap),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: highlighted ? const EdgeInsets.all(12) : EdgeInsets.zero,
              decoration: highlighted
                  ? BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(18),
                    )
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ThreadHeader(thread: thread),
                  const SizedBox(height: 6),
                  ThreadContentSection(
                    thread: thread,
                    enableContentBlurDemo: enableContentBlurDemo,
                  ),
                  if (thread.imageUrls.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ThreadMediaSectionWrapper(thread: thread),
                  ],
                  const SizedBox(height: 12),
                  ThreadActionsRow(
                    thread: thread,
                    onReplyTap: onReplyTap,
                    onLikeTap: onLikeTap,
                    onRepostTap: onRepostTap,
                    onShareTap: onShareTap,
                  ),
                  if (showReplyHint &&
                      thread.hasReplies &&
                      !isRepliesExpanded) ...[
                    const SizedBox(height: 12),
                    ReplyToggleButton(
                      onTap: onShowRepliesTap,
                      child: Text(
                        'Hiển thị phản hồi',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.9,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      child: content,
    );
  }
}

class ThreadHeader extends StatelessWidget {
  const ThreadHeader({super.key, required this.thread});

  final ThreadItemModel thread;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Flexible(
          child: UserNameButton(
            userId: thread.author.id,
            label: thread.author.username,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          thread.createdAt,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class ThreadContentSection extends StatelessWidget {
  const ThreadContentSection({
    super.key,
    required this.thread,
    this.enableContentBlurDemo = false,
  });

  final ThreadItemModel thread;
  final bool enableContentBlurDemo;

  static const Map<String, Set<int>> _blurredParagraphIndexesByThreadId = {
    'thread_101': {0},
    'thread_102': {0},
  };

  @override
  Widget build(BuildContext context) {
    final shouldBlur = thread.shouldBlurVisibleContent;
    final textStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(height: 1.5);
    final blurIndexes = enableContentBlurDemo
        ? (_blurredParagraphIndexesByThreadId[thread.id] ?? const <int>{})
        : const <int>{};
    if (blurIndexes.isEmpty) {
      return buildModeratedTextWithTrailingIcon(
        context: context,
        content: thread.content,
        textStyle: textStyle,
        shouldBlur: shouldBlur,
        moderationAction: thread.moderationAction,
        moderationLabel: thread.moderationLabel,
      );
    }

    final paragraphs = thread.content.split('\n\n');
    if (paragraphs.length == 1 && blurIndexes.contains(0)) {
      return buildModeratedTextWithTrailingIcon(
        context: context,
        content: thread.content,
        textStyle: textStyle,
        shouldBlur: shouldBlur,
        moderationAction: thread.moderationAction,
        moderationLabel: thread.moderationLabel,
      );
    }

    return Text.rich(
      buildModeratedTextSpan(
        context: context,
        content: paragraphs.join('\n\n'),
        style: textStyle,
        shouldBlur: shouldBlur,
        moderationLabel: thread.moderationLabel,
        moderationAction: thread.moderationAction,
      ),
    );
  }
}

class ThreadMediaSectionWrapper extends StatelessWidget {
  const ThreadMediaSectionWrapper({super.key, required this.thread});

  final ThreadItemModel thread;

  @override
  Widget build(BuildContext context) {
    return buildModeratedContent(
      context: context,
      shouldBlur: thread.shouldBlurVisibleContent,
      moderationLabel: thread.moderationLabel,
      moderationAction: thread.moderationAction,
      child: ThreadMediaSection(imageUrls: thread.imageUrls),
    );
  }
}

class _ThreadTimelineColumn extends StatelessWidget {
  const _ThreadTimelineColumn({
    required this.thread,
    required this.showTopConnector,
    required this.showBottomConnector,
    required this.showTimelineConnectors,
  });

  final ThreadItemModel thread;
  final bool showTopConnector;
  final bool showBottomConnector;
  final bool showTimelineConnectors;

  static const double _spacing = 8;

  @override
  Widget build(BuildContext context) {
    if (!showTimelineConnectors) {
      return Column(children: [_ThreadAvatar(thread: thread)]);
    }

    return Column(
      children: [
        if (showTopConnector)
          const Expanded(
            child: _TimelineLine(alignment: Alignment.bottomCenter),
          ),
        _ThreadAvatar(thread: thread),
        if (showBottomConnector) ...[
          const SizedBox(height: _spacing),
          const Expanded(child: _TimelineLine(alignment: Alignment.topCenter)),
        ],
      ],
    );
  }
}

class _TimelineLine extends StatelessWidget {
  const _TimelineLine({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 1.5,
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _ThreadAvatar extends StatelessWidget {
  const _ThreadAvatar({required this.thread});

  final ThreadItemModel thread;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        UserAvatarButton(
          userId: thread.author.id,
          avatarUrl: thread.author.avatarUrl,
          avatarAssetPath: thread.author.avatarAssetPath,
          displayName: thread.author.name,
          username: thread.author.username,
          size: ThreadItemWidget.avatarRadius * 2,
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.surface, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.onSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                size: 11,
                color: colorScheme.surface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ReplyToggleButton extends StatelessWidget {
  const ReplyToggleButton({super.key, this.onTap, required this.child});

  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) {
      return child;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: child,
      ),
    );
  }
}

class ThreadActionsRow extends StatelessWidget {
  const ThreadActionsRow({
    super.key,
    required this.thread,
    this.onReplyTap,
    this.onLikeTap,
    this.onRepostTap,
    this.onShareTap,
  });

  final ThreadItemModel thread;
  final VoidCallback? onReplyTap;
  final VoidCallback? onLikeTap;
  final VoidCallback? onRepostTap;
  final VoidCallback? onShareTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ThreadActionWithCount(
          iconAssetPath: 'assets/icons/heart.png',
          activeIconAssetPath: 'assets/icons/heartred.png',
          count: '${thread.likesCount}',
          alwaysShowCount: true,
          enableLikeToggle: true,
          initiallyLiked: thread.isLikedByMe,
          onTap: onLikeTap,
        ),
        const SizedBox(width: 18),
        _ThreadActionWithCount(
          iconAssetPath: 'assets/icons/message.png',
          count: '${thread.replyCount}',
          onTap: onReplyTap,
        ),
        const SizedBox(width: 18),
        _ThreadActionWithCount(
          iconAssetPath: 'assets/icons/repost.png',
          count: '${thread.repostCount}',
          onTap: onRepostTap,
        ),
        const SizedBox(width: 18),
        _ThreadActionWithCount(
          iconAssetPath: 'assets/icons/send.png',
          count: '${thread.shareCount}',
          onTap: onShareTap,
        ),
      ],
    );
  }
}

class _ThreadActionIcon extends StatelessWidget {
  const _ThreadActionIcon({
    super.key,
    required this.assetPath,
    required this.size,
    this.color,
  });

  final String assetPath;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (color == null) {
      return Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }

    return ImageIcon(AssetImage(assetPath), size: size, color: color);
  }
}

class _ThreadActionWithCount extends StatefulWidget {
  const _ThreadActionWithCount({
    required this.iconAssetPath,
    required this.count,
    this.alwaysShowCount = false,
    this.enableLikeToggle = false,
    this.initiallyLiked = false,
    this.activeIconAssetPath,
    this.onTap,
  });

  final String iconAssetPath;
  final String? activeIconAssetPath;
  final String count;
  final bool alwaysShowCount;
  final bool enableLikeToggle;
  final bool initiallyLiked;
  final VoidCallback? onTap;

  @override
  State<_ThreadActionWithCount> createState() => _ThreadActionWithCountState();
}

class _ThreadActionWithCountState extends State<_ThreadActionWithCount>
    with SingleTickerProviderStateMixin {
  static const _digitHeight = 18.0;
  static const _digitWidth = 9.0;
  static const _directionUp = 1;
  static const _directionDown = -1;

  late final AnimationController _countController;
  late String _displayCount;
  String? _previousCount;
  late bool _isLiked;
  int _countDirection = _directionUp;

  TextStyle _countStyle(BuildContext context) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 18 / 14,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
    );
  }

  @override
  void initState() {
    super.initState();
    _displayCount = widget.count;
    _isLiked = widget.initiallyLiked;
    _countController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 260),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted) {
            setState(() {
              _previousCount = null;
            });
          }
        });
  }

  @override
  void didUpdateWidget(covariant _ThreadActionWithCount oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) {
      _displayCount = widget.count;
      _previousCount = null;
      _isLiked = widget.initiallyLiked;
      _countDirection = _directionUp;
    } else if (oldWidget.initiallyLiked != widget.initiallyLiked) {
      _isLiked = widget.initiallyLiked;
    }
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.enableLikeToggle) {
      final nextLiked = !_isLiked;
      final nextCount = _stepCount(_displayCount, increase: nextLiked);

      setState(() {
        _isLiked = nextLiked;
        if (nextCount != _displayCount) {
          _previousCount = _displayCount;
          _displayCount = nextCount;
          _countDirection = nextLiked ? _directionUp : _directionDown;
          _countController.forward(from: 0);
        }
      });
    }

    widget.onTap?.call();
  }

  String _stepCount(String value, {required bool increase}) {
    final lastDigitIndex = value.lastIndexOf(RegExp(r'\d'));
    if (lastDigitIndex < 0) {
      return value;
    }

    var start = lastDigitIndex;
    while (start > 0 && _isDigit(value.codeUnitAt(start - 1))) {
      start--;
    }

    final segment = value.substring(start, lastDigitIndex + 1);
    final number = int.tryParse(segment);
    if (number == null) {
      return value;
    }

    final next = increase ? number + 1 : (number > 0 ? number - 1 : 0);
    return '${value.substring(0, start)}$next${value.substring(lastDigitIndex + 1)}';
  }

  bool _isDigit(int codeUnit) => codeUnit >= 48 && codeUnit <= 57;

  _ParsedCount _parseLastDigit(String value) {
    final digitIndex = value.lastIndexOf(RegExp(r'\d'));
    if (digitIndex < 0) {
      return _ParsedCount(prefix: value, suffix: '', digit: null);
    }

    return _ParsedCount(
      prefix: value.substring(0, digitIndex),
      suffix: value.substring(digitIndex + 1),
      digit: value[digitIndex],
    );
  }

  Widget _buildCountText() {
    final hasCount = widget.alwaysShowCount || _displayCount != '0';
    if (!hasCount) {
      return const SizedBox.shrink();
    }

    final currentStyle = _countStyle(context);
    final previous = _previousCount;
    if (previous == null || !_countController.isAnimating) {
      return Text(_displayCount, style: currentStyle);
    }

    final oldParsed = _parseLastDigit(previous);
    final newParsed = _parseLastDigit(_displayCount);
    final canAnimateDigit =
        oldParsed.digit != null &&
        newParsed.digit != null &&
        oldParsed.prefix == newParsed.prefix &&
        oldParsed.suffix == newParsed.suffix;

    if (!canAnimateDigit) {
      return Text(_displayCount, style: currentStyle);
    }

    return AnimatedBuilder(
      animation: _countController,
      builder: (context, _) {
        final t = Curves.easeOutCubic.transform(_countController.value);
        final oldOffsetY = _countDirection == _directionUp
            ? -_digitHeight * t
            : _digitHeight * t;
        final newOffsetY = _countDirection == _directionUp
            ? _digitHeight * (1 - t)
            : -_digitHeight * (1 - t);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (newParsed.prefix.isNotEmpty)
              Text(newParsed.prefix, style: currentStyle),
            ClipRect(
              child: SizedBox(
                width: _digitWidth,
                height: _digitHeight,
                child: Stack(
                  children: [
                    Transform.translate(
                      offset: Offset(0, oldOffsetY),
                      child: Opacity(
                        opacity: 1 - t,
                        child: Text(oldParsed.digit!, style: currentStyle),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, newOffsetY),
                      child: Opacity(
                        opacity: t,
                        child: Text(newParsed.digit!, style: currentStyle),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (newParsed.suffix.isNotEmpty)
              Text(newParsed.suffix, style: currentStyle),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconPath = _isLiked && widget.activeIconAssetPath != null
        ? widget.activeIconAssetPath!
        : widget.iconAssetPath;
    final isAccentIcon = _isLiked && widget.activeIconAssetPath != null;

    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleTap,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) {
              final curve = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              );
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: curve, child: child),
              );
            },
            child: _ThreadActionIcon(
              key: ValueKey('$iconPath:$isAccentIcon'),
              assetPath: iconPath,
              size: 27,
              color: isAccentIcon ? null : AppIconTokens.utility(context),
            ),
          ),
        ),
        if (widget.alwaysShowCount || _displayCount != '0') ...[
          const SizedBox(width: 4),
          _buildCountText(),
        ],
      ],
    );
  }
}

class _ParsedCount {
  const _ParsedCount({
    required this.prefix,
    required this.suffix,
    required this.digit,
  });

  final String prefix;
  final String suffix;
  final String? digit;
}
