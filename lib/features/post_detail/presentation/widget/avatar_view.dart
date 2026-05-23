import 'package:flutter/material.dart';

import '../../data/models/user.dart';

class AvatarView extends StatelessWidget {
  const AvatarView({super.key, required this.user, this.radius = 15});

  final User user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).colorScheme.surfaceContainerHigh;
    final fontSize = radius * 0.9;
    final fallbackChild = Text(
      _initials,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: fontSize,
            height: 1.0,
          ),
    );

    if (user.avatarAssetPath != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        foregroundImage: AssetImage(user.avatarAssetPath!),
        child: fallbackChild,
      );
    }

    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        foregroundImage: NetworkImage(user.avatarUrl!),
        child: fallbackChild,
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: fallbackChild,
    );
  }

  String get _initials {
    final trimmedUsername = user.username.trim();
    if (trimmedUsername.isNotEmpty) {
      return trimmedUsername.characters.first.toUpperCase();
    }

    final trimmedName = user.name.trim();
    if (trimmedName.isNotEmpty) {
      return trimmedName.characters.first.toUpperCase();
    }

    return '?';
  }
}
