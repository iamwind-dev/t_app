import 'package:flutter/material.dart';

class AiScanningText extends StatelessWidget {
  const AiScanningText({
    super.key,
    required this.text,
    required this.progress,
    required this.isSuccess,
  });

  final String text;
  final double progress;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final words = text.split(' ');
    // Handle empty text
    if (text.isEmpty) {
      return RichText(
        text: TextSpan(
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 0),
                child: _InlineIndicator(isSuccess: isSuccess),
              ),
            ),
          ],
        ),
      );
    }

    final activeWordIndex = (words.length * progress).floor();

    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
          height: 1.35,
        ),
        children: [
          ...List.generate(words.length, (index) {
            final isScanned = index < activeWordIndex;
            final isActive = index == activeWordIndex;

            return TextSpan(
              text: '${words[index]}${index == words.length - 1 ? '' : ' '}',
              style: TextStyle(
                color: isActive
                    ? colorScheme.primary
                    : (isScanned
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: 0.4)),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _InlineIndicator(isSuccess: isSuccess),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineIndicator extends StatefulWidget {
  const _InlineIndicator({required this.isSuccess});
  final bool isSuccess;

  @override
  State<_InlineIndicator> createState() => _InlineIndicatorState();
}

class _InlineIndicatorState extends State<_InlineIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.isSuccess) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, size: 16, color: Colors.green),
          const SizedBox(width: 4),
          const Text(
            'Đã kiểm tra',
            style: TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    return FadeTransition(
      opacity: _controller.drive(CurveTween(curve: Curves.easeInOut)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 14, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            'AI detection...',
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
