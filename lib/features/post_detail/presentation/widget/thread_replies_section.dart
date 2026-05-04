import 'package:flutter/material.dart';
import 'package:t_app/features/home/presentation/widget/post_divider.dart';

import '../../data/models/thread_item_model.dart';
import 'thread_item_widget.dart';

class ThreadRepliesSection extends StatefulWidget {
  const ThreadRepliesSection({
    super.key,
    required this.rootThread,
    required this.expandedThreadIds,
    required this.onThreadTap,
    required this.onReplyTap,
    required this.onLikeTap,
    required this.onExpandReplies,
  });

  final ThreadItemModel rootThread;
  final Set<String> expandedThreadIds;
  final ValueChanged<ThreadItemModel> onThreadTap;
  final ValueChanged<ThreadItemModel> onReplyTap;
  final ValueChanged<ThreadItemModel> onLikeTap;
  final ValueChanged<ThreadItemModel> onExpandReplies;

  @override
  State<ThreadRepliesSection> createState() => _ThreadRepliesSectionState();
}

class _ThreadRepliesSectionState extends State<ThreadRepliesSection> {
  @override
  Widget build(BuildContext context) {
    final rootReplies = widget.rootThread.children;
    final colorScheme = Theme.of(context).colorScheme;

    if (rootReplies.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Chua co phan hoi nao cho thread nay.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < rootReplies.length; index++) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
            child: ThreadBranchBlock(
              rootReply: rootReplies[index],
              expandedThreadIds: widget.expandedThreadIds,
              onThreadTap: widget.onThreadTap,
              onReplyTap: widget.onReplyTap,
              onLikeTap: widget.onLikeTap,
              onExpandReplies: widget.onExpandReplies,
            ),
          ),
          if (index != rootReplies.length - 1) const PostDivider(),
        ],
      ],
    );
  }
}

class ThreadBranchBlock extends StatefulWidget {
  const ThreadBranchBlock({
    super.key,
    required this.rootReply,
    required this.expandedThreadIds,
    required this.onThreadTap,
    required this.onReplyTap,
    required this.onLikeTap,
    required this.onExpandReplies,
    this.highlightedThreadId,
  });

  final ThreadItemModel rootReply;
  final Set<String> expandedThreadIds;
  final ValueChanged<ThreadItemModel> onThreadTap;
  final ValueChanged<ThreadItemModel> onReplyTap;
  final ValueChanged<ThreadItemModel> onLikeTap;
  final ValueChanged<ThreadItemModel> onExpandReplies;
  final String? highlightedThreadId;

  @override
  State<ThreadBranchBlock> createState() => _ThreadBranchBlockState();
}

class _ThreadBranchBlockState extends State<ThreadBranchBlock> {
  final GlobalKey _stackKey = GlobalKey();
  final List<GlobalKey> _itemKeys = <GlobalKey>[];
  List<double> _avatarCenters = const <double>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateAvatarCenters());
  }

  @override
  void didUpdateWidget(covariant ThreadBranchBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateAvatarCenters());
  }

  @override
  Widget build(BuildContext context) {
    final visibleThreads = _buildVisibleThreads(widget.rootReply);

    while (_itemKeys.length < visibleThreads.length) {
      _itemKeys.add(GlobalKey());
    }
    while (_itemKeys.length > visibleThreads.length) {
      _itemKeys.removeLast();
    }

    return Stack(
      key: _stackKey,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ThreadConnectorPainter(
                avatarCenters: _avatarCenters,
                color: Theme.of(context).dividerColor.withValues(alpha: 0.95),
                lineWidth: 1.5,
                x: ThreadItemWidget.timelineWidth / 2,
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(visibleThreads.length, (index) {
            final thread = visibleThreads[index];
            final isExpanded = widget.expandedThreadIds.contains(thread.id);

            return Padding(
              key: _itemKeys[index],
              padding: EdgeInsets.only(
                bottom: index == visibleThreads.length - 1 ? 0 : 12,
              ),
              child: ThreadItemWidget(
                thread: thread,
                onTap: () => widget.onThreadTap(thread),
                onReplyTap: () => widget.onReplyTap(thread),
                onLikeTap: () => widget.onLikeTap(thread),
                onShowRepliesTap: thread.hasReplies
                    ? () => widget.onExpandReplies(thread)
                    : null,
                showTimelineConnectors: false,
                showReplyHint: thread.hasReplies,
                isRepliesExpanded: isExpanded,
                highlighted: widget.highlightedThreadId == thread.id,
              ),
            );
          }),
        ),
      ],
    );
  }

  List<ThreadItemModel> _buildVisibleThreads(ThreadItemModel thread) {
    final threads = <ThreadItemModel>[thread];
    final isExpanded = widget.expandedThreadIds.contains(thread.id);

    if (!isExpanded) {
      return threads;
    }

    for (final child in thread.children) {
      threads.addAll(_buildVisibleThreads(child));
    }

    return threads;
  }

  void _updateAvatarCenters() {
    final stackContext = _stackKey.currentContext;
    if (stackContext == null) {
      return;
    }

    final stackBox = stackContext.findRenderObject() as RenderBox?;
    if (stackBox == null || !stackBox.hasSize) {
      return;
    }

    final centers = <double>[];
    for (final key in _itemKeys) {
      final itemContext = key.currentContext;
      if (itemContext == null) {
        return;
      }

      final itemBox = itemContext.findRenderObject() as RenderBox?;
      if (itemBox == null || !itemBox.hasSize) {
        return;
      }

      final offset = itemBox.localToGlobal(Offset.zero, ancestor: stackBox);
      centers.add(offset.dy + ThreadItemWidget.avatarRadius);
    }

    if (!_sameCenters(_avatarCenters, centers)) {
      setState(() {
        _avatarCenters = centers;
      });
    }
  }

  bool _sameCenters(List<double> previous, List<double> next) {
    if (previous.length != next.length) {
      return false;
    }

    for (var index = 0; index < previous.length; index++) {
      if ((previous[index] - next[index]).abs() > 0.5) {
        return false;
      }
    }

    return true;
  }
}

class _ThreadConnectorPainter extends CustomPainter {
  const _ThreadConnectorPainter({
    required this.avatarCenters,
    required this.color,
    required this.lineWidth,
    required this.x,
  });

  final List<double> avatarCenters;
  final Color color;
  final double lineWidth;
  final double x;

  @override
  void paint(Canvas canvas, Size size) {
    if (avatarCenters.length < 2) {
      return;
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(x, avatarCenters.first),
      Offset(x, avatarCenters.last),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ThreadConnectorPainter oldDelegate) {
    return oldDelegate.avatarCenters != avatarCenters ||
        oldDelegate.color != color ||
        oldDelegate.lineWidth != lineWidth ||
        oldDelegate.x != x;
  }
}
