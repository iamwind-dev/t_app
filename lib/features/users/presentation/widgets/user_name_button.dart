import 'package:flutter/material.dart';
import 'package:t_app/features/profile/presentation/screen/profile_screen.dart';

class UserNameButton extends StatelessWidget {
  const UserNameButton({
    super.key,
    required this.userId,
    required this.label,
    required this.style,
    this.maxLines = 1,
  });

  final String userId;
  final String label;
  final TextStyle? style;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: style,
    );

    if (userId.isEmpty) {
      return text;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => _openProfile(context),
      child: text,
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
