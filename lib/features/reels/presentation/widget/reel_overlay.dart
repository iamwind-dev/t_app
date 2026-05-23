import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/features/reels/presentation/cubits/comments/comments_cubit.dart';
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
                builder: (context) {
                  return SafeArea(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.65,
                      child: BlocProvider(
                        create: (_) => CommentsCubit()..loadComments(),
                        child: CommentsSection(),
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
            onTap: () {},
          ),
          ReelActionButton(
            icon: Icons.more_vert,
            label: '',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(reel.avatarUrl),
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
                backgroundImage: NetworkImage(reel.avatarUrl),
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