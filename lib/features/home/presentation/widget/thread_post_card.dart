import 'package:flutter/material.dart';

import '../cubits/home_state.dart';

class ThreadPostCard extends StatelessWidget {
  const ThreadPostCard({super.key, required this.post});

  final ThreadPost post;

  static Color avatarBackground(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);
  }

  static TextStyle countStyle(BuildContext context) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 18 / 14,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
    );
  }

  static TextStyle handleStyle(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 19 / 16,
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
      height: 20 / 16,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle commentAuthorStyle(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 20 / 16,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasComments = post.comments.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ThreadLeadingRail(post: post, hasComments: hasComments),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ThreadPostHeader(
                  author: post.author,
                  timeAgo: post.timeAgo,
                  isVerified: post.isVerified,
                ),
                const SizedBox(height: 4),
                Text(post.content, style: contentStyle(context)),
                if (post.postImageAsset != null) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: post.postImageHeight ?? 220,
                      child: Image.asset(
                        post.postImageAsset!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    _ActionWithCount(
                      iconAssetPath: 'assets/icons/heart.png',
                      activeIconAssetPath: 'assets/icons/heartred.png',
                      count: post.likeCount,
                      alwaysShowCount: true,
                      enableLikeToggle: true,
                    ),
                    const SizedBox(width: 18),
                    _ActionWithCount(
                      iconAssetPath: 'assets/icons/message.png',
                      count: post.replyCount,
                    ),
                    const SizedBox(width: 18),
                    _ActionWithCount(
                      iconAssetPath: 'assets/icons/repost.png',
                      count: post.repostCount,
                    ),
                    const SizedBox(width: 18),
                    _ActionWithCount(
                      iconAssetPath: 'assets/icons/send.png',
                      count: post.sendCount,
                    ),
                  ],
                ),
                if (hasComments) ...[
                  const SizedBox(height: 12),
                  _PostComments(comments: post.comments),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreadLeadingRail extends StatelessWidget {
  const _ThreadLeadingRail({required this.post, required this.hasComments});

  final ThreadPost post;
  final bool hasComments;

  static const _railWidth = 41.0;
  static const _avatarOnlySize = 41.0;
  static const _connectorGap = 6.0;
  static const _commentAvatarGap = 12.0;

  @override
  Widget build(BuildContext context) {
    if (hasComments) {
      final lineHeight = (post.threadStackHeight - 36 - _connectorGap - 36)
          .clamp(28.0, 220.0);

      return SizedBox(
        width: _railWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AvatarFallback(author: post.author),
            const SizedBox(height: _connectorGap),
            Container(
              width: 1.4,
              height: lineHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).dividerColor,
                    Theme.of(context).dividerColor.withValues(alpha: 0.35),
                  ],
                ),
              ),
            ),
            const SizedBox(height: _connectorGap),
            ...List.generate(post.comments.length, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == post.comments.length - 1
                      ? 0
                      : _commentAvatarGap,
                ),
                child: _AvatarFallback(author: post.comments[index].author),
              );
            }),
          ],
        ),
      );
    }

    return SizedBox(
      width: _avatarOnlySize,
      height: _avatarOnlySize,
      child: _AvatarFallback(author: post.author),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.author});

  final String author;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: ThreadPostCard.avatarBackground(context),
      child: Text(
        _initial(author),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _initial(String value) {
    final cleaned = value.trim();
    if (cleaned.isEmpty) {
      return '?';
    }
    return cleaned.substring(0, 1).toUpperCase();
  }
}

class _PostComments extends StatelessWidget {
  const _PostComments({required this.comments});

  final List<ThreadComment> comments;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(comments.length, (index) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == comments.length - 1 ? 0 : 12,
          ),
          child: _PostCommentTile(comment: comments[index]),
        );
      }),
    );
  }
}

class _PostCommentTile extends StatelessWidget {
  const _PostCommentTile({required this.comment});

  final ThreadComment comment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      comment.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ThreadPostCard.commentAuthorStyle(context),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    comment.timeAgo,
                    style: ThreadPostCard.timeStyle(context),
                  ),
                ],
              ),
            ),
            if (comment.showLikeBadge) ...[
              Image.asset(
                'assets/icons/heartred.png',
                width: 16,
                height: 16,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 6),
            ],
            Icon(
              Icons.more_horiz_rounded,
              size: 18,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(comment.content, style: ThreadPostCard.contentStyle(context)),
        const SizedBox(height: 8),
        Row(
          children: [
            _ActionWithCount(
              iconAssetPath: 'assets/icons/heart.png',
              activeIconAssetPath: 'assets/icons/heartred.png',
              count: comment.likeCount,
              alwaysShowCount: true,
              enableLikeToggle: true,
            ),
            const SizedBox(width: 18),
            _ActionWithCount(
              iconAssetPath: 'assets/icons/message.png',
              count: comment.replyCount,
            ),
            const SizedBox(width: 18),
            _ActionWithCount(
              iconAssetPath: 'assets/icons/repost.png',
              count: comment.repostCount,
            ),
            const SizedBox(width: 18),
            _ActionWithCount(
              iconAssetPath: 'assets/icons/send.png',
              count: comment.sendCount,
            ),
          ],
        ),
      ],
    );
  }
}

class _ThreadPostHeader extends StatelessWidget {
  const _ThreadPostHeader({
    required this.author,
    required this.timeAgo,
    required this.isVerified,
  });

  final String author;
  final String timeAgo;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ThreadPostCard.handleStyle(context),
                ),
              ),
              if (isVerified) ...[
                const SizedBox(width: 4),
                Image.asset(
                  'assets/images/home_verified_badge.png',
                  width: 12,
                  height: 12,
                  fit: BoxFit.contain,
                ),
              ],
              const SizedBox(width: 6),
              Text(timeAgo, style: ThreadPostCard.timeStyle(context)),
            ],
          ),
        ),
        Icon(
          Icons.more_horiz_rounded,
          size: 20,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ],
    );
  }
}

class _ActionWithCount extends StatefulWidget {
  const _ActionWithCount({
    required this.iconAssetPath,
    required this.count,
    this.alwaysShowCount = false,
    this.enableLikeToggle = false,
    this.activeIconAssetPath,
  });

  final String iconAssetPath;
  final String? activeIconAssetPath;
  final String count;
  final bool alwaysShowCount;
  final bool enableLikeToggle;

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
  bool _isLiked = false;
  int _countDirection = _directionUp;

  @override
  void initState() {
    super.initState();
    _displayCount = widget.count;
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
    if (oldWidget.count != widget.count) {
      _displayCount = widget.count;
      _previousCount = null;
      _isLiked = false;
      _countDirection = _directionUp;
    }
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enableLikeToggle) {
      return;
    }

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

    final currentStyle = ThreadPostCard.countStyle(context);

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
            child: Image.asset(
              iconPath,
              key: ValueKey(iconPath),
              width: 27,
              height: 27,
              fit: BoxFit.contain,
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
