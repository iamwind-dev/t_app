import 'package:flutter/material.dart';
import 'package:t_app/core/keys/home/home_widget_keys.dart';
import 'package:t_app/features/home/presentation/cubits/home_state.dart';

import 'feed_avatar.dart';

class CreatePostCard extends StatelessWidget {
  const CreatePostCard({super.key, required this.currentUser, this.onTap});

  final FeedUser currentUser;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FeedAvatar(
            label: currentUser.username,
            assetPath: currentUser.avatarAsset,
            size: 48,
            fontSize: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentUser.username,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 20 / 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Có gì mới?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 20 / 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: HomeWidgetKeys.createPostCardAction,
        onTap: onTap,
        child: content,
      ),
    );
  }
}
