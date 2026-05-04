import 'package:flutter/material.dart';
import 'package:t_app/features/post_detail/data/models/user.dart';
import 'package:t_app/features/post_detail/presentation/widget/avatar_view.dart';
import 'package:t_app/features/profile/presentation/screen/profile_screen.dart';

class UserAvatarButton extends StatelessWidget {
  const UserAvatarButton({
    super.key,
    required this.userId,
    required this.avatarUrl,
    required this.size,
    this.avatarAssetPath,
    this.displayName,
    this.username,
  });

  final String userId;
  final String? avatarUrl;
  final String? avatarAssetPath;
  final String? displayName;
  final String? username;
  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = size / 2;
    final avatar = AvatarView(
      user: User(
        id: userId,
        name: displayName ?? username ?? '',
        username: username ?? '',
        avatarUrl: avatarUrl,
        avatarAssetPath: avatarAssetPath,
      ),
      radius: radius,
    );

    if (userId.isEmpty) {
      return avatar;
    }

    return InkResponse(
      radius: radius + 8,
      onTap: () => _openProfile(context),
      child: avatar,
    );
  }

  void _openProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfilePage(userId: userId),
      ),
    );
  }
}
