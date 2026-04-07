import 'package:flutter/material.dart';
import 'package:t_app/features/home/presentation/widget/post_divider.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/post_detail/presentation/widget/thread_replies_section.dart';

class ThreadReplyScreen extends StatefulWidget {
  const ThreadReplyScreen({
    super.key,
    required this.rootThread,
    required this.selectedThreadId,
  });

  final ThreadItemModel rootThread;
  final String selectedThreadId;

  @override
  State<ThreadReplyScreen> createState() => _ThreadReplyScreenState();
}

class _ThreadReplyScreenState extends State<ThreadReplyScreen> {
  late final Set<String> _expandedThreadIds;

  @override
  void initState() {
    super.initState();
    final branchPath = widget.rootThread.buildAncestorPath(widget.selectedThreadId);
    final selectedThread = widget.rootThread.findById(widget.selectedThreadId);
    _expandedThreadIds = _buildInitialExpandedThreadIds(
      branchPath: branchPath,
      selectedThread: selectedThread,
    );
  }

  void _expandReplies(String threadId) {
    if (_expandedThreadIds.contains(threadId)) {
      return;
    }

    setState(() {
      _expandedThreadIds.add(threadId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final branchPath = widget.rootThread.buildAncestorPath(widget.selectedThreadId);
    final branchRoot = _buildBranchRoot(branchPath);
    final selectedThread = widget.rootThread.findById(widget.selectedThreadId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Reply'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  //   child: Text(
                  //     'Ngữ cảnh nhánh thread',
                  //     style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  //       fontWeight: FontWeight.w700,
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 12),
                  // const PostDivider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: ThreadBranchBlock(
                      rootReply: branchRoot,
                      expandedThreadIds: _expandedThreadIds,
                      highlightedThreadId: widget.selectedThreadId,
                      onThreadTap: (thread) {
                        if (thread.id == widget.selectedThreadId) {
                          return;
                        }

                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ThreadReplyScreen(
                              rootThread: widget.rootThread,
                              selectedThreadId: thread.id,
                            ),
                          ),
                        );
                      },
                      onExpandReplies: _expandReplies,
                    ),
                  ),
                ],
              ),
            ),
            if (selectedThread != null)
              _ThreadBranchComposer(selectedThread: selectedThread),
          ],
        ),
      ),
    );
  }

  ThreadItemModel _buildBranchRoot(List<ThreadItemModel> path) {
    if (path.isEmpty) {
      return widget.rootThread;
    }

    return _rebuildPath(path, 0);
  }

  Set<String> _buildInitialExpandedThreadIds({
    required List<ThreadItemModel> branchPath,
    required ThreadItemModel? selectedThread,
  }) {
    final expandedThreadIds = <String>{
      for (var index = 0; index < branchPath.length - 1; index++)
        branchPath[index].id,
    };

    if (selectedThread != null) {
      expandedThreadIds.add(selectedThread.id);
    }

    return expandedThreadIds;
  }

  ThreadItemModel _rebuildPath(List<ThreadItemModel> path, int index) {
    final current = path[index];
    if (index == path.length - 1) {
      return current.copyWith(children: current.children);
    }

    return current.copyWith(children: [_rebuildPath(path, index + 1)]);
  }
}

class _ThreadBranchComposer extends StatelessWidget {
  const _ThreadBranchComposer({required this.selectedThread});

  final ThreadItemModel selectedThread;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                    'Trả lời ${selectedThread.author.username}',
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
