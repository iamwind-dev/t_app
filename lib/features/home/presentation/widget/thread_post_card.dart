import 'package:flutter/material.dart';
import 'package:t_app/core/theme/app_icon_tokens.dart';
import 'package:t_app/features/home/presentation/cubits/home_state.dart';

import 'feed_avatar.dart';

class ThreadPostCard extends StatelessWidget {
  const ThreadPostCard({super.key, required this.post});

  final ThreadPost post;

  @override
  Widget build(BuildContext context) {
    return ThreadItemCard(data: ThreadItemData.fromThreadPost(post));
  }
}

class ThreadItemCard extends StatelessWidget {
  const ThreadItemCard({
    super.key,
    required this.data,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onRepost,
    this.onShare,
  });

  final ThreadItemData data;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onRepost;
  final VoidCallback? onShare;

  static const avatarSize = 44.0;
  static const authorAvatarSize = avatarSize;
  static const replyAvatarSize = avatarSize;
  static const _cardPadding = EdgeInsets.fromLTRB(16, 14, 16, 16);

  static TextStyle countStyle(BuildContext context) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 18 / 14,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
    );
  }

  static TextStyle usernameStyle(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 20 / 16,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle compactUsernameStyle(BuildContext context) {
    return TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      height: 20 / 15,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle timeStyle(BuildContext context) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 18 / 14,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  static TextStyle contentStyle(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 22 / 16,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle compactContentStyle(BuildContext context) {
    return TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 20 / 15,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.95),
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: _cardPadding,
      child: switch (data.type) {
        ThreadItemType.post => _ThreadPostLayout(
          data: data,
          onLike: onLike,
          onComment: onComment,
          onRepost: onRepost,
          onShare: onShare,
        ),
        ThreadItemType.reply => _ThreadReplyLayout(
          data: data,
          onLike: onLike,
          onComment: onComment,
          onRepost: onRepost,
          onShare: onShare,
        ),
      },
    );

    if (onTap == null) {
      return child;
    }

    return InkWell(onTap: onTap, child: child);
  }
}

class _ThreadPostLayout extends StatelessWidget {
  const _ThreadPostLayout({
    required this.data,
    this.onLike,
    this.onComment,
    this.onRepost,
    this.onShare,
  });

  final ThreadItemData data;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onRepost;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final replyPreview = data.replyPreview;

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth =
            constraints.maxWidth - ThreadItemCard.avatarSize - 12;
        final mainContentHeight = ThreadContent.measureHeight(
          context,
          data,
          contentWidth,
        );
        final connectorHeight = replyPreview == null || !data.showConnector
            ? 0.0
            : (mainContentHeight -
                      ThreadItemCard.avatarSize -
                      PostAvatarColumn.avatarGap)
                  .clamp(0.0, double.infinity);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PostAvatarColumn(
                  data: data,
                  connectorHeight: connectorHeight,
                  hasReplyPreview: replyPreview != null && data.showConnector,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ThreadContent(
                    data: data,
                    showOverflowMenu: true,
                    onLike: onLike,
                    onComment: onComment,
                    onRepost: onRepost,
                    onShare: onShare,
                  ),
                ),
              ],
            ),
            if (replyPreview != null) ...[
              const SizedBox(height: ReplyPreviewSection.topSpacing),
              ReplyPreviewSection(data: replyPreview),
            ],
          ],
        );
      },
    );
  }
}

class _ThreadReplyLayout extends StatelessWidget {
  const _ThreadReplyLayout({
    required this.data,
    this.onLike,
    this.onComment,
    this.onRepost,
    this.onShare,
  });

  final ThreadItemData data;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onRepost;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ThreadAvatar(data: data),
        const SizedBox(width: 12),
        Expanded(
          child: ThreadContent(
            data: data,
            compact: true,
            showOverflowMenu: false,
            headerTrailing: data.showLikeBadge ? const _ReplyLikeBadge() : null,
            onLike: onLike,
            onComment: onComment,
            onRepost: onRepost,
            onShare: onShare,
          ),
        ),
      ],
    );
  }
}

class ThreadAvatar extends StatelessWidget {
  const ThreadAvatar({super.key, required this.data, this.size});

  final ThreadItemData data;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return FeedAvatar(
      label: data.username,
      assetPath: data.userAvatarUrl,
      size: size ?? ThreadItemCard.avatarSize,
    );
  }
}

class ThreadConnector extends StatelessWidget {
  const ThreadConnector({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.4,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class PostAvatarColumn extends StatelessWidget {
  const PostAvatarColumn({
    super.key,
    required this.data,
    required this.connectorHeight,
    required this.hasReplyPreview,
  });

  final ThreadItemData data;
  final double connectorHeight;
  final bool hasReplyPreview;

  static const avatarGap = 8.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ThreadItemCard.avatarSize,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ThreadAvatar(data: data),
          if (hasReplyPreview) ...[
            const SizedBox(height: avatarGap),
            if (connectorHeight > 0)
              Align(
                alignment: Alignment.topCenter,
                child: ThreadConnector(height: connectorHeight),
              ),
          ],
        ],
      ),
    );
  }
}

class ThreadHeader extends StatelessWidget {
  const ThreadHeader({
    super.key,
    required this.data,
    this.compact = false,
    this.showOverflowMenu = false,
    this.trailing,
  });

  final ThreadItemData data;
  final bool compact;
  final bool showOverflowMenu;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final usernameStyle = compact
        ? ThreadItemCard.compactUsernameStyle(context)
        : ThreadItemCard.usernameStyle(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  data.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: usernameStyle,
                ),
              ),
              if (data.isVerified) ...[
                const SizedBox(width: 4),
                Image.asset(
                  'assets/images/home_verified_badge.png',
                  width: 12,
                  height: 12,
                  fit: BoxFit.contain,
                ),
              ],
              const SizedBox(width: 6),
              Text(
                data.createdAtLabel,
                style: ThreadItemCard.timeStyle(context),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
        if (trailing == null && showOverflowMenu)
          Icon(
            Icons.more_horiz_rounded,
            size: 20,
            color: AppIconTokens.utility(context),
          ),
      ],
    );
  }
}

class ThreadContent extends StatelessWidget {
  const ThreadContent({
    super.key,
    required this.data,
    this.compact = false,
    this.maxContentLines,
    this.showOverflowMenu = false,
    this.headerTrailing,
    this.onLike,
    this.onComment,
    this.onRepost,
    this.onShare,
  });

  final ThreadItemData data;
  final bool compact;
  final int? maxContentLines;
  final bool showOverflowMenu;
  final Widget? headerTrailing;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onRepost;
  final VoidCallback? onShare;

  static double measureHeight(
    BuildContext context,
    ThreadItemData data,
    double maxWidth,
  ) {
    final contentHeight = _measureTextHeight(
      text: data.content,
      style: ThreadItemCard.contentStyle(context),
      maxWidth: maxWidth,
      textDirection: Directionality.of(context),
    );
    final attachmentsHeight = data.attachments.fold<double>(
      0,
      (height, attachment) => height + 12 + (attachment.height ?? 220),
    );
    final actionsHeight = data.showActions ? 10 + 27 : 0;

    return 20 + 4 + contentHeight + attachmentsHeight + actionsHeight;
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = compact
        ? ThreadItemCard.compactContentStyle(context)
        : ThreadItemCard.contentStyle(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ThreadHeader(
          data: data,
          compact: compact,
          showOverflowMenu: showOverflowMenu,
          trailing: headerTrailing,
        ),
        const SizedBox(height: 4),
        Text(
          data.content,
          maxLines: maxContentLines,
          overflow: maxContentLines == null
              ? TextOverflow.visible
              : TextOverflow.ellipsis,
          style: textStyle,
        ),
        if (data.attachments.isNotEmpty)
          ...data.attachments.map(
            (attachment) => Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: double.infinity,
                  height: attachment.height ?? 220,
                  child: _ThreadAttachmentImage(path: attachment.url),
                ),
              ),
            ),
          ),
        if (data.showActions) ...[
          const SizedBox(height: 10),
          ThreadActions(
            data: data,
            onLike: onLike,
            onComment: onComment,
            onRepost: onRepost,
            onShare: onShare,
          ),
        ],
      ],
    );
  }
}

class ThreadActions extends StatelessWidget {
  const ThreadActions({
    super.key,
    required this.data,
    this.onLike,
    this.onComment,
    this.onRepost,
    this.onShare,
  });

  final ThreadItemData data;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onRepost;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionWithCount(
          iconAssetPath: 'assets/icons/heart.png',
          activeIconAssetPath: 'assets/icons/heartred.png',
          count: data.likeCount,
          initialLiked: data.isLiked,
          alwaysShowCount: true,
          enableLikeToggle: true,
          onTap: onLike,
        ),
        const SizedBox(width: 18),
        _ActionWithCount(
          iconAssetPath: 'assets/icons/message.png',
          count: data.commentCount,
          onTap: onComment,
        ),
        const SizedBox(width: 18),
        _ActionWithCount(
          iconAssetPath: 'assets/icons/repost.png',
          count: data.repostCount,
          onTap: onRepost,
        ),
        const SizedBox(width: 18),
        _ActionWithCount(
          iconAssetPath: 'assets/icons/send.png',
          count: data.shareCount,
          onTap: onShare,
        ),
      ],
    );
  }
}

class ReplyPreviewSection extends StatelessWidget {
  const ReplyPreviewSection({super.key, required this.data});

  final ThreadItemData data;

  static const topSpacing = 14.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ThreadAvatar(data: data),
        const SizedBox(width: 12),
        Expanded(
          child: ThreadContent(
            data: data,
            compact: true,
            maxContentLines: 2,
            showOverflowMenu: false,
            headerTrailing: data.showLikeBadge ? const _ReplyLikeBadge() : null,
          ),
        ),
      ],
    );
  }
}

class _ReplyLikeBadge extends StatelessWidget {
  const _ReplyLikeBadge();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Image.asset(
        'assets/icons/heartred.png',
        width: 16,
        height: 16,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _ThreadAttachmentImage extends StatelessWidget {
  const _ThreadAttachmentImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    if (_isRemotePath(path)) {
      return Image.network(path, fit: BoxFit.cover);
    }

    return Image.asset(path, fit: BoxFit.cover);
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
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

class _ActionWithCount extends StatefulWidget {
  const _ActionWithCount({
    required this.iconAssetPath,
    required this.count,
    this.alwaysShowCount = false,
    this.enableLikeToggle = false,
    this.activeIconAssetPath,
    this.initialLiked = false,
    this.onTap,
  });

  final String iconAssetPath;
  final String? activeIconAssetPath;
  final String count;
  final bool alwaysShowCount;
  final bool enableLikeToggle;
  final bool initialLiked;
  final VoidCallback? onTap;

  @override
  State<_ActionWithCount> createState() => _ActionWithCountState();
}

class _ActionWithCountState extends State<_ActionWithCount>
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

  @override
  void initState() {
    super.initState();
    _displayCount = widget.count;
    _isLiked = widget.initialLiked;
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
  void didUpdateWidget(covariant _ActionWithCount oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count ||
        oldWidget.initialLiked != widget.initialLiked) {
      _displayCount = widget.count;
      _previousCount = null;
      _isLiked = widget.initialLiked;
      _countDirection = _directionUp;
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

    final currentStyle = ThreadItemCard.countStyle(context);
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
            child: _ActionIcon(
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

double _measureTextHeight({
  required String text,
  required TextStyle style,
  required double maxWidth,
  required TextDirection textDirection,
  int? maxLines,
}) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: textDirection,
    maxLines: maxLines,
  )..layout(maxWidth: maxWidth);

  return painter.size.height;
}

bool _isRemotePath(String value) {
  return value.startsWith('http://') || value.startsWith('https://');
}
