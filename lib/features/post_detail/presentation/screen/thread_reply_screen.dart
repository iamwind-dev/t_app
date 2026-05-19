import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/core/config/app_config.dart';
import 'package:t_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_app/features/create_thread/presentation/sheet/create_thread_sheet.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/post_detail/data/models/user.dart';
import 'package:t_app/features/post_detail/data/thread_tree_updater.dart';
import 'package:t_app/features/post_detail/presentation/widget/thread_replies_section.dart';
import 'package:t_app/features/posts/domain/posts_feed_repository.dart';

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
  late ThreadItemModel _rootThread;
  late final Set<String> _expandedThreadIds;
  late final PostsFeedRepository _postsRepository;

  User get _currentUser {
    final authUser = context.read<AuthCubit>().state.user;
    return User(
      id: authUser?.id ?? 'current_user',
      name: authUser?.displayName ?? '__win.d',
      username: authUser?.username ?? '__win.d',
      avatarUrl: authUser?.avatarUrl,
    );
  }

  @override
  void initState() {
    super.initState();
    _rootThread = widget.rootThread;
    _postsRepository = context.read<PostsFeedRepository>();
    final branchPath = _rootThread.buildAncestorPath(widget.selectedThreadId);
    final selectedThread = _rootThread.findById(widget.selectedThreadId);
    _expandedThreadIds = _buildInitialExpandedThreadIds(
      branchPath: branchPath,
      selectedThread: selectedThread,
    );
  }

  /// Expands one reply node so the next level in the branch becomes visible.
  Future<void> _expandReplies(ThreadItemModel thread) async {
    if (_expandedThreadIds.contains(thread.id)) {
      return;
    }

    if (AppConfig.uiPreviewMode) {
      setState(() {
        _expandedThreadIds.add(thread.id);
      });
      return;
    }

    if (thread.children.isNotEmpty || thread.replyCount == 0) {
      setState(() {
        _expandedThreadIds.add(thread.id);
      });
      return;
    }

    try {
      final children = await _postsRepository.getReplyChildren(thread.id);
      if (!mounted) {
        return;
      }

      setState(() {
        _rootThread = ThreadTreeUpdater.attachChildren(
          root: _rootThread,
          parentId: thread.id,
          children: children.items,
        );
        _expandedThreadIds.add(thread.id);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không thể tải phản hồi.')));
    }
  }

  /// Opens another branch screen focused on the tapped related reply.
  void _openThreadBranch(ThreadItemModel thread) {
    if (thread.id == widget.selectedThreadId) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ThreadReplyScreen(
          rootThread: _rootThread,
          selectedThreadId: thread.id,
        ),
      ),
    );
  }

  /// Reuses the shared composer sheet in reply mode for branch replies.
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

        if (AppConfig.uiPreviewMode) {
          final replyId =
              'preview_reply_${DateTime.now().microsecondsSinceEpoch}';
          final newReply = ThreadItemModel(
            id: replyId,
            parentId: targetThread.id,
            rootThreadId: _rootThread.id,
            author: _currentUser,
            createdAt: 'vừa xong',
            content: request.primaryContent,
            imageUrls: request.mediaUrls,
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
            _expandedThreadIds.add(targetThread.id);
          });
          return;
        }

        final newReply = targetThread.id == _rootThread.id
            ? await _postsRepository.createPostReply(
                postId: _rootThread.id,
                content: request.primaryContent,
                mediaUrls: request.mediaUrls,
              )
            : await _postsRepository.createChildReply(
                replyId: targetThread.id,
                content: request.primaryContent,
                mediaUrls: request.mediaUrls,
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
          _expandedThreadIds.add(targetThread.id);
        });
      },
    );
  }

  Future<void> _toggleLike(ThreadItemModel thread) async {
    if (AppConfig.uiPreviewMode) {
      setState(() {
        _rootThread = _replaceThread(
          current: _rootThread,
          targetId: thread.id,
          update: (target) => target.copyWith(
            likesCount: target.isLikedByMe
                ? (target.likesCount > 0 ? target.likesCount - 1 : 0)
                : target.likesCount + 1,
            isLikedByMe: !target.isLikedByMe,
          ),
        );
      });
      return;
    }

    final isRootPost = thread.id == _rootThread.id;
    final result = isRootPost
        ? (thread.isLikedByMe
              ? await _postsRepository.unlikePost(thread.id)
              : await _postsRepository.likePost(thread.id))
        : (thread.isLikedByMe
              ? await _postsRepository.unlikeReply(thread.id)
              : await _postsRepository.likeReply(thread.id));

    if (!mounted) {
      return;
    }

    setState(() {
      _rootThread = _replaceThread(
        current: _rootThread,
        targetId: result.targetId,
        update: (target) => target.copyWith(
          likesCount: result.likeCount,
          isLikedByMe: result.isLiked,
        ),
      );
    });
  }

  /// Inserts a direct child reply and updates only the target node count.
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

  ThreadItemModel _replaceThread({
    required ThreadItemModel current,
    required String targetId,
    required ThreadItemModel Function(ThreadItemModel target) update,
  }) {
    if (current.id == targetId) {
      return update(current);
    }

    return current.copyWith(
      children: current.children
          .map(
            (child) => _replaceThread(
              current: child,
              targetId: targetId,
              update: update,
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final branchPath = _rootThread.buildAncestorPath(widget.selectedThreadId);
    final branchRoot = _buildBranchRoot(branchPath);
    final selectedThread = _rootThread.findById(widget.selectedThreadId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Trả lời'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                    child: ThreadBranchBlock(
                      rootReply: branchRoot,
                      expandedThreadIds: _expandedThreadIds,
                      highlightedThreadId: widget.selectedThreadId,
                      onThreadTap: _openThreadBranch,
                      onReplyTap: _openReplyComposer,
                      onLikeTap: _toggleLike,
                      onExpandReplies: _expandReplies,
                    ),
                  ),
                ],
              ),
            ),
            if (selectedThread != null)
              _ThreadBranchComposer(
                selectedThread: selectedThread,
                onTap: () => _openReplyComposer(selectedThread),
              ),
          ],
        ),
      ),
    );
  }

  /// Rebuilds the focused branch so only the current conversation path is shown.
  ThreadItemModel _buildBranchRoot(List<ThreadItemModel> path) {
    if (path.isEmpty) {
      return _rootThread;
    }

    return _rebuildPath(path, 0);
  }

  /// Expands the ancestor path to the selected reply on first paint.
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

  /// Recreates a single path from root to the selected reply node.
  ThreadItemModel _rebuildPath(List<ThreadItemModel> path, int index) {
    final current = path[index];
    if (index == path.length - 1) {
      return current.copyWith(children: current.children);
    }

    return current.copyWith(children: [_rebuildPath(path, index + 1)]);
  }
}

class _ThreadBranchComposer extends StatelessWidget {
  const _ThreadBranchComposer({
    required this.selectedThread,
    required this.onTap,
  });

  final ThreadItemModel selectedThread;
  final VoidCallback onTap;

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
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
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
      ),
    );
  }
}
