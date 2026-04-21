import 'package:flutter/material.dart';
import 'package:t_app/features/create_thread/presentation/sheet/create_thread_sheet.dart';
import 'package:t_app/features/home/presentation/widget/post_divider.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/post_detail/data/models/user.dart';
import 'package:t_app/features/post_detail/presentation/widget/thread_item_widget.dart';
import 'package:t_app/features/post_detail/presentation/widget/thread_replies_section.dart';

import 'thread_reply_screen.dart';

class ThreadDetailScreen extends StatefulWidget {
  const ThreadDetailScreen({super.key, required this.rootThread});

  final ThreadItemModel rootThread;

  @override
  State<ThreadDetailScreen> createState() => _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends State<ThreadDetailScreen> {
  late ThreadItemModel _rootThread;

  User get _currentUser => const User(
    id: 'current_user',
    name: '__win.d',
    username: '__win.d',
    avatarAssetPath: 'assets/images/home_avatar_payal.png',
  );

  @override
  void initState() {
    super.initState();
    _rootThread = widget.rootThread;
  }

  void _openThreadBranch(ThreadItemModel thread) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ThreadReplyScreen(
          rootThread: _rootThread,
          selectedThreadId: thread.id,
        ),
      ),
    );
  }

  /// Reuses the shared thread composer sheet in reply mode.
  Future<void> _openReplyComposer(ThreadItemModel targetThread) {
    return showThreadComposerSheet(
      context: context,
      currentUser: _currentUser,
      mode: ComposerMode.reply,
      replyContext: ThreadComposerReplyContext.fromThread(targetThread),
      onSubmit: (request) async {
        if (request.primaryContent.isEmpty) {
          return;
        }

        final newReply = ThreadItemModel(
          id: 'reply_${DateTime.now().microsecondsSinceEpoch}',
          parentId: targetThread.id,
          rootThreadId: _rootThread.rootThreadId,
          author: _currentUser,
          createdAt: 'Vua xong',
          content: request.primaryContent,
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _rootThread = _insertReply(
            current: _rootThread,
            targetId: targetThread.id,
            newReply: newReply,
          );
        });
      },
    );
  }

  /// Inserts a reply into the selected parent and updates that direct count.
  ThreadItemModel _insertReply({
    required ThreadItemModel current,
    required String targetId,
    required ThreadItemModel newReply,
  }) {
    if (current.id == targetId) {
      return current.copyWith(
        children: [newReply, ...current.children],
        replyCount: current.replyCount + 1,
      );
    }

    if (current.children.isEmpty) {
      return current;
    }

    return current.copyWith(
      children: current.children
          .map(
            (child) => _insertReply(
              current: child,
              targetId: targetId,
              newReply: newReply,
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Thread'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 14, 0, 16),
                    child: ThreadItemWidget(
                      thread: _rootThread,
                      onReplyTap: () => _openReplyComposer(_rootThread),
                      showReplyHint: false,
                    ),
                  ),
                  const PostDivider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                    child: Text(
                      'Phan hoi (${_rootThread.replyCount})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const PostDivider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                    child: ThreadRepliesSection(
                      rootThread: _rootThread,
                      onThreadTap: _openThreadBranch,
                      onReplyTap: _openReplyComposer,
                    ),
                  ),
                ],
              ),
            ),
            _ThreadComposer(
              selectedThread: _rootThread,
              onTap: () => _openReplyComposer(_rootThread),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreadComposer extends StatelessWidget {
  const _ThreadComposer({required this.selectedThread, required this.onTap});

  final ThreadItemModel selectedThread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final username = selectedThread.author.username;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      'Tra loi $username',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    size: 20,
                    color: colorScheme.surface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
