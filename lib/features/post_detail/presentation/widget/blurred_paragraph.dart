import 'dart:ui';

import 'package:flutter/material.dart';

class BlurredParagraph extends StatelessWidget {
  const BlurredParagraph({
    super.key,
    required this.text,
    required this.textStyle,
  });

  final String text;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final defaultColor = Theme.of(context).colorScheme.onSurface;
    final blurredStyle = textStyle.copyWith(
      color: (textStyle.color ?? defaultColor).withValues(alpha: 0.86),
    );

    return Stack(
      children: [
        Text(
          text,
          style: textStyle.copyWith(
            color: Colors.transparent,
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 5.8, sigmaY: 5.8),
              child: Text(text, style: blurredStyle),
            ),
          ),
        ),
      ],
    );
  }
}
