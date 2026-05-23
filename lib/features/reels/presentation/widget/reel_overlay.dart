import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_app/features/reels/domain/repositories/reels_repository.dart';
import 'package:t_app/features/reels/presentation/cubits/comments/comments_cubit.dart';
import 'package:t_app/features/reels/presentation/cubits/reels_cubit.dart';
import 'package:t_app/features/reels/presentation/sheet/share_reel_sheet.dart';
import 'package:t_app/features/reels/presentation/widget/comment.dart';

import '../../domain/entities/reel.dart';
import 'reel_action_button.dart';

class ReelOverlay extends StatelessWidget {
  final Reel reel;
  final double bottomInset;
  final VoidCallback onLike;

  const ReelOverlay({
    super.key,
    required this.reel,
    required this.bottomInset,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Stack(
      children: [
        _topTitle(topInset),
        _rightActions(context),
        _bottomInfo(),
      ],
    );
  }

  Widget _topTitle(double topInset) {
    return Positioned(
      top: topInset + 32,
      left: 18,
      child: Text(
        'Reels',
        style: TextStyle(
          color: Colors.white,
          fontSize: 27,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _rightActions(BuildContext context) {
    return Positioned(
      right: 14,
      bottom: 80 + bottomInset,
      child: Column(
        children: [
          ReelActionButton(
            icon: reel.isLiked ? Icons.favorite : Icons.favorite_border,
            label: _formatNumber(reel.likes),
            color: reel.isLiked ? Colors.red : Colors.white,
            onTap: onLike,
          ),
          ReelActionButton(
            icon: Icons.mode_comment_outlined,
            label: _formatNumber(reel.comments),
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                builder: (context) {
                  return SafeArea(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.65,
                      child: BlocProvider(
                        create: (_) => CommentsCubit(
                          repository: context.read<ReelsRepository>(),
                          reelId: reel.id,
                          onCommentCreated: () {
                            context
                                .read<ReelsCubit>()
                                .incrementCommentCount(reel.id);
                          },
                        )..loadComments(),
                        child: const CommentsSection(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          ReelActionButton(
            icon: Icons.send_outlined,
            label: 'Share',
            onTap: () => showShareReelSheet(context, reel: reel),
          ),
          ReelActionButton(
            icon: Icons.more_vert,
            label: '',
            onTap: () => _showReelActions(context),
          ),
          const SizedBox(height: 10),
          CircleAvatar(
            radius: 18,
            backgroundImage:
                reel.avatarUrl != null ? NetworkImage(reel.avatarUrl!) : null,
            child: reel.avatarUrl == null
                ? const Icon(Icons.person, size: 18)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _bottomInfo() {
    return Positioned(
      left: 16,
      right: 80,
      bottom: 16 + bottomInset,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: reel.avatarUrl != null
                    ? NetworkImage(reel.avatarUrl!)
                    : null,
                child: reel.avatarUrl == null
                    ? const Icon(Icons.person, size: 18)
                    : null,
              ),
              const SizedBox(width: 10),
              Text(
                reel.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Follow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            reel.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.music_note,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  reel.music,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showReelActions(BuildContext context) async {
    final currentUserId = context.read<AuthCubit>().state.user?.id;
    if (currentUserId == null || currentUserId != reel.authorId) {
      return;
    }

    final shouldDelete = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colorScheme = theme.colorScheme;

        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => Navigator.of(dialogContext).pop(true),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: colorScheme.error,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Delete reel',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    try {
      await context.read<ReelsCubit>().deleteReel(reel.id);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reel deleted.')),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete reel right now.')),
      );
    }
  }

  String _formatNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toString();
  }
}
