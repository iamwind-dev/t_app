import 'package:flutter/material.dart';

class PostDivider extends StatelessWidget {
  const PostDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).dividerColor,
    );
  }
}
