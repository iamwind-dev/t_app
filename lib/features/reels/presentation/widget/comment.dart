import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/core/utils/time_formatter.dart';
import 'package:t_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_app/features/post_detail/data/models/user.dart';
import 'package:t_app/features/post_detail/presentation/widget/avatar_view.dart';
import 'package:t_app/features/reels/domain/entities/reel_comment.dart';
import 'package:t_app/features/reels/presentation/cubits/comments/comments_cubit.dart';
import 'package:t_app/features/reels/presentation/cubits/comments/comments_state.dart';

class CommentsSection extends StatefulWidget {
  const CommentsSection({super.key});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_controller.text.trim().isEmpty) {
      return;
    }

    await context.read<CommentsCubit>().addComment(_controller.text);
    if (!mounted) {
      return;
    }
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = context.select((AuthCubit cubit) => cubit.state.user);
    final currentUser = User(
      id: authUser?.id ?? 'current_user',
      name: authUser?.displayName ?? authUser?.username ?? 'You',
      username: authUser?.username ?? 'you',
      avatarUrl: authUser?.avatarUrl,
    );

    return BlocBuilder<CommentsCubit, CommentsState>(
      builder: (context, state) {
        final comments = state is CommentsLoaded ? state.comments : const <ReelComment>[];
        final isSubmitting = state is CommentsLoaded && state.isSubmitting;

        return Material(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
                child: Row(
                  children: [
                    Text(
                      'Comments',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '${
                        comments.length
                      }',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              Expanded(
                child: switch (state) {
                  CommentsLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  CommentsLoaded() when comments.isEmpty => Center(
                      child: Text(
                        'No replies yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ),
                  CommentsLoaded() => ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                      itemCount: comments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (_, index) {
                        return _CommentThreadTile(comment: comments[index]);
                      },
                    ),
                  CommentsError(:final message) => Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  _ => const SizedBox.shrink(),
                },
              ),
              _CommentComposer(
                controller: _controller,
                currentUser: currentUser,
                isSubmitting: isSubmitting,
                onSubmit: _submit,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CommentThreadTile extends StatelessWidget {
  const _CommentThreadTile({required this.comment});

  final ReelComment comment;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayName =
        comment.displayName.isNotEmpty ? comment.displayName : comment.username;
    final author = User(
      id: comment.id,
      name: displayName,
      username: comment.username,
      avatarUrl: comment.avatarUrl,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 44,
          child: Column(
            children: [
              AvatarView(user: author, radius: 18),
              Container(
                width: 1.5,
                height: 44,
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      displayName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    TimeFormatter.formatSocialTime(comment.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                comment.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.35,
                    ),
              ),
              if (comment.likeCount > 0) ...[
                const SizedBox(height: 8),
                Text(
                  '${comment.likeCount} likes',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          comment.isLikedByMe ? Icons.favorite : Icons.favorite_border,
          size: 18,
          color: comment.isLikedByMe
              ? Colors.redAccent
              : colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }
}

class _CommentComposer extends StatelessWidget {
  const _CommentComposer({
    required this.controller,
    required this.currentUser,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final User currentUser;
  final bool isSubmitting;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        14,
        10,
        14,
        10 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AvatarView(user: currentUser, radius: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.8),
                ),
              ),
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSubmit(),
                decoration: InputDecoration(
                  hintText: 'Write a reply...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: isSubmitting ? null : onSubmit,
            behavior: HitTestBehavior.opaque,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: isSubmitting ? 0.55 : 1,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: isSubmitting
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.onSurface,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.arrow_upward_rounded,
                        size: 18,
                        color: colorScheme.onSurface,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
