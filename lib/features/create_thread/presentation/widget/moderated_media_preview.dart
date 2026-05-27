import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:t_app/features/uploads/data/upload_moderation.dart';

class ModeratedMediaPreview extends StatefulWidget {
  const ModeratedMediaPreview({
    super.key,
    required this.child,
    required this.moderation,
    this.warningTextOverride,
  });

  final Widget child;
  final UploadModeration moderation;
  final String? warningTextOverride;

  @override
  State<ModeratedMediaPreview> createState() => _ModeratedMediaPreviewState();
}

class _ModeratedMediaPreviewState extends State<ModeratedMediaPreview> {
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    final moderation = widget.moderation;
    final action = moderation.action;
    final shouldBlur = moderation.shouldBlur &&
        action != UploadModerationAction.allow &&
        !(action == UploadModerationAction.blurAllowOpen && _isRevealed);
    final showOpenButton =
        action == UploadModerationAction.blurAllowOpen && !_isRevealed;
    final showWarning =
        action == UploadModerationAction.blurAllowOpen ||
        action == UploadModerationAction.blurNoOpen;
    final warningText = widget.warningTextOverride ??
        (action == UploadModerationAction.blurNoOpen
            ? 'Nội dung nhạy cảm cao.'
            : moderation.warningMessage());

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (shouldBlur)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.2)),
            ),
          ),
        if (showWarning)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3)),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        warningText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      if (showOpenButton) ...[
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => setState(() => _isRevealed = true),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                          ),
                          child: const Text('Xem nội dung'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

