import 'package:flutter/material.dart';
import 'package:t_app/features/home/presentation/widget/post_divider.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/post_detail/presentation/widget/thread_item_widget.dart';
import 'package:t_app/features/post_detail/presentation/widget/thread_replies_section.dart';

import 'thread_reply_screen.dart';

class ThreadDetailScreen extends StatelessWidget {
  const ThreadDetailScreen({super.key, required this.rootThread});

  final ThreadItemModel rootThread;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    void openThreadBranch(ThreadItemModel thread) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ThreadReplyScreen(
            rootThread: rootThread,
            selectedThreadId: thread.id,
          ),
        ),
      );
    }

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
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: ThreadItemWidget(
                      thread: rootThread,
                      onTap: () => openThreadBranch(rootThread),
                      onReplyTap: () => openThreadBranch(rootThread),
                      showReplyHint: false,
                    ),
                  ),
                  const PostDivider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Text(
                      'Phản hồi (${rootThread.replyCount})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: ThreadRepliesSection(
                      rootThread: rootThread,
                      onThreadTap: openThreadBranch,
                    ),
                  ),
                ],
              ),
            ),
            _ThreadComposer(selectedThread: rootThread),
          ],
        ),
      ),
    );
  }
}

class _ThreadComposer extends StatelessWidget {
  const _ThreadComposer({required this.selectedThread});

  final ThreadItemModel selectedThread;

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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                    'Trả lời $username',
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
    );
  }
}
