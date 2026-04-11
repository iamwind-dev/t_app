import 'package:flutter/material.dart';
import 'package:t_app/core/theme/app_theme.dart';
import 'package:t_app/features/create_thread/data/models/thread_draft.dart';
import 'package:t_app/features/post_detail/data/models/user.dart';
import 'package:t_app/features/post_detail/presentation/widget/avatar_view.dart';

Future<void> showCreateThreadSheet({
  required BuildContext context,
  required User currentUser,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (context) {
      return CreateThreadSheet(currentUser: currentUser);
    },
  );
}

enum PostState { idle, aiChecking, postingSuccess }

class CreateThreadSheet extends StatefulWidget {
  const CreateThreadSheet({
    super.key,
    required this.currentUser,
  });

  final User currentUser;

  @override
  State<CreateThreadSheet> createState() => _CreateThreadSheetState();
}

class _CreateThreadSheetState extends State<CreateThreadSheet> {
  late ThreadDraft _draft;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  bool _replyControlsEnabled = true;
  PostState _postState = PostState.idle;
  String _statusText = '';

  @override
  void initState() {
    super.initState();
    _draft = const ThreadDraft(
      items: [ThreadDraftItem(id: 'draft_1')],
    );
    _controllers = [TextEditingController()];
    _focusNodes = [FocusNode()];
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _updateDraftItem(int index, String value) {
    final nextItems = [..._draft.items];
    nextItems[index] = nextItems[index].copyWith(content: value);
    setState(() {
      _draft = _draft.copyWith(items: nextItems);
    });
  }

  void _addDraftItem() {
    final newIndex = _draft.items.length + 1;
    setState(() {
      _draft = _draft.copyWith(
        items: [
          ..._draft.items,
          ThreadDraftItem(id: 'draft_$newIndex'),
        ],
      );
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _focusNodes.last.requestFocus();
    });
  }

  Future<void> _submit() async {
    if (_postState != PostState.idle) return;

    setState(() {
      _postState = PostState.aiChecking;
      _statusText = 'Đang kiểm tra nội dung...';
    });

    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _statusText = 'Đang phân tích ngữ cảnh...');

    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _statusText = 'Đang đánh giá mức độ phù hợp...');

    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _postState = PostState.postingSuccess;
      _statusText = 'Đăng thành công';
    });

    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.dark(),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

          return AnimatedPadding(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.only(bottom: bottomInset),
            child: FractionallySizedBox(
              heightFactor: 0.94,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.24),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 10),
                          CreateThreadHeader(onCancel: () => Navigator.of(context).pop()),
                          Divider(
                            height: 1,
                            color: theme.dividerColor,
                          ),
                          Expanded(
                            child: ThreadDraftComposer(
                              currentUser: widget.currentUser,
                              draft: _draft,
                              controllers: _controllers,
                              focusNodes: _focusNodes,
                              onChanged: _updateDraftItem,
                              onAddToThread: _addDraftItem,
                            ),
                          ),
                          CreateThreadFooter(
                            replyControlsEnabled: _replyControlsEnabled,
                            onToggleReplyControls: () {
                              setState(() {
                                _replyControlsEnabled = !_replyControlsEnabled;
                              });
                            },
                            onSubmit: _submit,
                            postState: _postState,
                          ),
                        ],
                      ),
                      if (_postState != PostState.idle)
                        PostingAiCheckOverlay(
                          statusText: _statusText,
                          postState: _postState,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CreateThreadHeader extends StatelessWidget {
  const CreateThreadHeader({super.key, required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: onCancel,
            behavior: HitTestBehavior.opaque,
            child: Text(
              'Hủy',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Thread mới',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.description_outlined,
                size: 22,
                color: colorScheme.onSurface,
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.more_horiz_rounded,
                size: 24,
                color: colorScheme.onSurface,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ThreadDraftComposer extends StatelessWidget {
  const ThreadDraftComposer({
    super.key,
    required this.currentUser,
    required this.draft,
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
    required this.onAddToThread,
  });

  final User currentUser;
  final ThreadDraft draft;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int index, String value) onChanged;
  final VoidCallback onAddToThread;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      itemCount: draft.items.length,
      itemBuilder: (context, index) {
        return ThreadDraftItemComposer(
          currentUser: currentUser,
          controller: controllers[index],
          focusNode: focusNodes[index],
          isLastItem: index == draft.items.length - 1,
          onChanged: (value) => onChanged(index, value),
          onAddToThread: onAddToThread,
        );
      },
    );
  }
}

class ThreadDraftItemComposer extends StatelessWidget {
  const ThreadDraftItemComposer({
    super.key,
    required this.currentUser,
    required this.controller,
    required this.focusNode,
    required this.isLastItem,
    required this.onChanged,
    required this.onAddToThread,
  });

  final User currentUser;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLastItem;
  final ValueChanged<String> onChanged;
  final VoidCallback onAddToThread;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const avatarRadius = 20.0;
    const smallAvatarRadius = 11.0;
    const leftColumnWidth = 48.0;

    return Padding(
      padding: EdgeInsets.only(bottom: isLastItem ? 0 : 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: leftColumnWidth,
            child: Column(
              children: [
                AvatarView(user: currentUser, radius: avatarRadius),
                Container(
                  width: 1.5,
                  height: 76,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                CircleAvatar(
                  radius: smallAvatarRadius,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  backgroundImage: currentUser.avatarAssetPath == null
                      ? null
                      : AssetImage(currentUser.avatarAssetPath!),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        currentUser.username,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '>',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Cộng đồng hoặc chủ đề',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: onChanged,
                  maxLines: null,
                  minLines: 4,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.35,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Có gì mới?',
                    hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  cursorColor: colorScheme.onSurface,
                ),
                const SizedBox(height: 12),
                const ComposerToolbar(),
                if (isLastItem) ...[
                  const SizedBox(height: 14),
                  AddToThreadRow(
                    currentUser: currentUser,
                    onTap: onAddToThread,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ComposerToolbar extends StatelessWidget {
  const ComposerToolbar({super.key});

  static const _icons = [
    Icons.image_outlined,
    Icons.gif_box_outlined,
    Icons.subject_rounded,
    Icons.format_quote_rounded,
    Icons.more_horiz_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: List.generate(_icons.length, (index) {
        return Padding(
          padding: EdgeInsets.only(right: index == _icons.length - 1 ? 0 : 18),
          child: Icon(
            _icons[index],
            size: 22,
            color: colorScheme.onSurfaceVariant,
          ),
        );
      }),
    );
  }
}

class AddToThreadRow extends StatelessWidget {
  const AddToThreadRow({
    super.key,
    required this.currentUser,
    required this.onTap,
  });

  final User currentUser;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: colorScheme.surfaceContainerHighest,
            backgroundImage: currentUser.avatarAssetPath == null
                ? null
                : AssetImage(currentUser.avatarAssetPath!),
          ),
          const SizedBox(width: 10),
          Text(
            'Thêm vào thread',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class CreateThreadFooter extends StatelessWidget {
  const CreateThreadFooter({
    super.key,
    required this.replyControlsEnabled,
    required this.onToggleReplyControls,
    required this.onSubmit,
    required this.postState,
  });

  final bool replyControlsEnabled;
  final VoidCallback onToggleReplyControls;
  final VoidCallback onSubmit;
  final PostState postState;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isChecking = postState == PostState.aiChecking;
    final isSuccess = postState == PostState.postingSuccess;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.public_outlined,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'Lựa chọn trả lời',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: isChecking || isSuccess ? null : onToggleReplyControls,
            behavior: HitTestBehavior.opaque,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isChecking || isSuccess ? 0.5 : 1.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 52,
                height: 30,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: replyControlsEnabled
                      ? colorScheme.onSurface
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Align(
                  alignment: replyControlsEnabled
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: replyControlsEnabled
                          ? colorScheme.surface
                          : colorScheme.onSurface,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: isChecking || isSuccess ? null : onSubmit,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 38,
              padding: EdgeInsets.symmetric(
                horizontal: isChecking || isSuccess ? 12 : 18,
              ),
              decoration: BoxDecoration(
                color: isSuccess
                    ? Colors.green.withValues(alpha: 0.2)
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(999),
                border: isSuccess
                    ? Border.all(color: Colors.green.withValues(alpha: 0.5))
                    : null,
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isChecking) ...[
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  if (isSuccess) ...[
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    isSuccess ? 'Thành công' : 'Đăng',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isSuccess ? Colors.green : colorScheme.onSurface,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PostingAiCheckOverlay extends StatefulWidget {
  const PostingAiCheckOverlay({
    super.key,
    required this.statusText,
    required this.postState,
  });

  final String statusText;
  final PostState postState;

  @override
  State<PostingAiCheckOverlay> createState() => _PostingAiCheckOverlayState();
}

class _PostingAiCheckOverlayState extends State<PostingAiCheckOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Pulse background
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.2),
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Container(
                      width: 120 * value,
                      height: 120 * value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.postState == PostState.postingSuccess
                                ? Colors.green.withValues(alpha: 0.15)
                                : colorScheme.primary.withValues(alpha: 0.15),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    );
                  },
                  onEnd: () {}, // Handled by repeating tween if needed, but simple pulse is fine
                ),
                // AI/Scan Container
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.postState == PostState.postingSuccess
                          ? Colors.green.withValues(alpha: 0.4)
                          : colorScheme.onSurface.withValues(alpha: 0.1),
                      width: 2,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: widget.postState == PostState.postingSuccess
                      ? const Center(
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.green,
                            size: 48,
                          ),
                        )
                      : Stack(
                          children: [
                            Center(
                              child: Icon(
                                Icons.auto_awesome,
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                                size: 36,
                              ),
                            ),
                            // Scanning line
                            AnimatedBuilder(
                              animation: _scanAnimation,
                              builder: (context, child) {
                                return Positioned(
                                  top: _scanAnimation.value * 100,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 2,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorScheme.primary
                                              .withValues(alpha: 0.8),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                      gradient: LinearGradient(
                                        colors: [
                                          colorScheme.primary
                                              .withValues(alpha: 0.0),
                                          colorScheme.primary
                                              .withValues(alpha: 1.0),
                                          colorScheme.primary
                                              .withValues(alpha: 0.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                widget.statusText,
                key: ValueKey(widget.statusText),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: widget.postState == PostState.postingSuccess
                          ? Colors.green
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
