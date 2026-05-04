import 'package:flutter/material.dart';

import '../../data/models/user.dart';

class AvatarView extends StatelessWidget {
  const AvatarView({super.key, required this.user, this.radius = 15});

  final User user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).colorScheme.surfaceContainerHigh;

    if (user.avatarAssetPath != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        backgroundImage: AssetImage(user.avatarAssetPath!),
      );
    }

    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        backgroundImage: NetworkImage(user.avatarUrl!),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        user.name.isEmpty ? '?' : user.name.characters.first.toUpperCase(),
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
