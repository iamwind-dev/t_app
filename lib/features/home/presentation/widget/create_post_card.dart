import 'package:flutter/material.dart';
import 'package:t_app/core/keys/home/home_widget_keys.dart';
import 'package:t_app/features/post_detail/data/models/user.dart';
import 'package:t_app/features/post_detail/presentation/widget/avatar_view.dart';
import 'package:t_app/features/post_detail/presentation/widget/thread_item_widget.dart';

class CreatePostCard extends StatelessWidget {
  const CreatePostCard({super.key, required this.currentUser, this.onTap});

  final User currentUser;
  final VoidCallback? onTap;

  String get _username {
    final trimmedUsername = currentUser.username.trim();
    if (trimmedUsername.isNotEmpty) {
      return trimmedUsername;
    }

    return 'user';
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: ThreadItemWidget.timelineWidth,
            child: Align(
              alignment: Alignment.topCenter,
              child: _ComposerAvatar(user: currentUser),
            ),
          ),
          const SizedBox(width: ThreadItemWidget.timelineGap),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _username,
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
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        child: content,
      ),
    );
  }
}

class _ComposerAvatar extends StatelessWidget {
  const _ComposerAvatar({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Use username for initials fallback text in AvatarView by providing an empty name,
    // so it skips displayName and falls back to username's first letter.
    final avatarUser = User(
      id: user.id,
      name: '',
      username: user.username.isNotEmpty ? user.username : 'user',
      avatarUrl: user.avatarUrl,
      avatarAssetPath: user.avatarAssetPath,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AvatarView(user: avatarUser, radius: ThreadItemWidget.avatarRadius),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.surface, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.onSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                size: 11,
                color: colorScheme.surface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
