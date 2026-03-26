import 'package:flutter/material.dart';

class FeedAvatar extends StatelessWidget {
  const FeedAvatar({
    super.key,
    required this.label,
    this.assetPath,
    this.size = 40,
    this.fontSize = 16,
  });

  final String label;
  final String? assetPath;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final child = assetPath == null
        ? Center(
            child: Text(
              _initial(label),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
              ),
            ),
          )
        : ClipOval(child: _buildImage(assetPath!));

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.08),
        ),
        child: child,
      ),
    );
  }

  String _initial(String value) {
    final cleaned = value.trim();
    if (cleaned.isEmpty) {
      return '?';
    }

    return cleaned.substring(0, 1).toUpperCase();
  }

  Widget _buildImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, width: size, height: size, fit: BoxFit.cover);
    }

    return Image.asset(path, width: size, height: size, fit: BoxFit.cover);
  }
}
