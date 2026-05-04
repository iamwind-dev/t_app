import 'package:flutter/material.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/post_detail/presentation/widget/thread_item_widget.dart';

class HomeThreadPreviewBlock extends StatefulWidget {
  const HomeThreadPreviewBlock({
    super.key,
    required this.rootThread,
    required this.onRootTap,
    required this.onReplyTap,
    required this.onPreviewReplyTap,
    required this.onLikeTap,
  });

  final ThreadItemModel rootThread;
  final VoidCallback onRootTap;
  final VoidCallback onReplyTap;
  final ValueChanged<ThreadItemModel> onPreviewReplyTap;
  final ValueChanged<ThreadItemModel> onLikeTap;

  @override
  State<HomeThreadPreviewBlock> createState() => _HomeThreadPreviewBlockState();
}

class _HomeThreadPreviewBlockState extends State<HomeThreadPreviewBlock> {
  final GlobalKey _stackKey = GlobalKey();
  final List<GlobalKey> _itemKeys = <GlobalKey>[];
  List<double> _avatarCenters = const <double>[];

  ThreadItemModel? get _previewReply => widget.rootThread.previewReply;

  List<ThreadItemModel> get _threads => [
    widget.rootThread,
    if (_previewReply != null) _previewReply!,
  ];

  bool get _hasPreviewReplies => _previewReply != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateAvatarCenters());
  }

  @override
  void didUpdateWidget(covariant HomeThreadPreviewBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateAvatarCenters());
  }

  @override
  Widget build(BuildContext context) {
    while (_itemKeys.length < _threads.length) {
      _itemKeys.add(GlobalKey());
    }
    while (_itemKeys.length > _threads.length) {
      _itemKeys.removeLast();
    }

    if (!_hasPreviewReplies) {
      return ThreadItemWidget(
        thread: widget.rootThread,
        onTap: widget.onRootTap,
        onReplyTap: widget.onReplyTap,
        onLikeTap: () => widget.onLikeTap(widget.rootThread),
        showReplyHint: false,
      );
    }

    return Stack(
      key: _stackKey,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _HomeThreadPreviewConnectorPainter(
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
          children: List.generate(_threads.length, (index) {
            final thread = _threads[index];
            final isRootThread = index == 0;

            return Padding(
              key: _itemKeys[index],
              padding: EdgeInsets.only(
                bottom: index == _threads.length - 1 ? 0 : 12,
              ),
              child: ThreadItemWidget(
                thread: thread,
                onTap: isRootThread
                    ? widget.onRootTap
                    : () => widget.onPreviewReplyTap(thread),
                onReplyTap: isRootThread
                    ? widget.onReplyTap
                    : () => widget.onPreviewReplyTap(thread),
                onLikeTap: () => widget.onLikeTap(thread),
                showTimelineConnectors: false,
                showReplyHint: false,
              ),
            );
          }),
        ),
      ],
    );
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

    if (_sameCenters(_avatarCenters, centers)) {
      return;
    }

    setState(() {
      _avatarCenters = centers;
    });
  }

  bool _sameCenters(List<double> previous, List<double> next) {
    if (previous.length != next.length) {
      return false;
    }

    for (var i = 0; i < previous.length; i++) {
      if ((previous[i] - next[i]).abs() > 0.5) {
        return false;
      }
    }

    return true;
  }
}

class _HomeThreadPreviewConnectorPainter extends CustomPainter {
  const _HomeThreadPreviewConnectorPainter({
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
  bool shouldRepaint(covariant _HomeThreadPreviewConnectorPainter oldDelegate) {
    return oldDelegate.avatarCenters != avatarCenters ||
        oldDelegate.color != color ||
        oldDelegate.lineWidth != lineWidth ||
        oldDelegate.x != x;
  }
}
