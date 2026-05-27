import 'package:flutter/material.dart';

class ReelActionButton extends StatefulWidget {
  const ReelActionButton({
    super.key,
    this.iconAssetPath,
    this.icon,
    required this.label,
    required this.onTap,
    this.activeIconAssetPath,
    this.enableLikeToggle = false,
    this.initiallyLiked = false,
  }) : assert(iconAssetPath != null || icon != null);

  final String? iconAssetPath;
  final IconData? icon;
  final String? activeIconAssetPath;
  final String label;
  final VoidCallback onTap;
  final bool enableLikeToggle;
  final bool initiallyLiked;

  @override
  State<ReelActionButton> createState() => _ReelActionButtonState();
}

class _ReelActionButtonState extends State<ReelActionButton>
    with SingleTickerProviderStateMixin {
  static const _digitHeight = 18.0;
  static const _digitWidth = 9.0;
  static const _directionUp = 1;
  static const _directionDown = -1;

  late final AnimationController _countController;
  late String _displayLabel;
  String? _previousLabel;
  late bool _isLiked;
  int _countDirection = _directionUp;

  TextStyle get _labelStyle =>
      const TextStyle(color: Colors.white, fontSize: 12, height: 1.2);

  @override
  void initState() {
    super.initState();
    _displayLabel = widget.label;
    _isLiked = widget.initiallyLiked;
    _countController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 260),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted) {
            setState(() {
              _previousLabel = null;
            });
          }
        });
  }

  @override
  void didUpdateWidget(covariant ReelActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.label != widget.label) {
      _displayLabel = widget.label;
      _previousLabel = null;
      _isLiked = widget.initiallyLiked;
      _countDirection = _directionUp;
    } else if (oldWidget.initiallyLiked != widget.initiallyLiked) {
      _isLiked = widget.initiallyLiked;
    }
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.enableLikeToggle) {
      final nextLiked = !_isLiked;
      final nextLabel = _stepCount(_displayLabel, increase: nextLiked);

      setState(() {
        _isLiked = nextLiked;
        if (nextLabel != _displayLabel) {
          _previousLabel = _displayLabel;
          _displayLabel = nextLabel;
          _countDirection = nextLiked ? _directionUp : _directionDown;
          _countController.forward(from: 0);
        }
      });
    }

    widget.onTap();
  }

  String _stepCount(String value, {required bool increase}) {
    final lastDigitIndex = value.lastIndexOf(RegExp(r'\d'));
    if (lastDigitIndex < 0) {
      return value;
    }

    var start = lastDigitIndex;
    while (start > 0 && _isDigit(value.codeUnitAt(start - 1))) {
      start--;
    }

    final segment = value.substring(start, lastDigitIndex + 1);
    final number = int.tryParse(segment);
    if (number == null) {
      return value;
    }

    final next = increase ? number + 1 : (number > 0 ? number - 1 : 0);
    return '${value.substring(0, start)}$next${value.substring(lastDigitIndex + 1)}';
  }

  bool _isDigit(int codeUnit) => codeUnit >= 48 && codeUnit <= 57;

  _ParsedCount _parseLastDigit(String value) {
    final digitIndex = value.lastIndexOf(RegExp(r'\d'));
    if (digitIndex < 0) {
      return _ParsedCount(prefix: value, suffix: '', digit: null);
    }

    return _ParsedCount(
      prefix: value.substring(0, digitIndex),
      suffix: value.substring(digitIndex + 1),
      digit: value[digitIndex],
    );
  }

  Widget _buildLabel() {
    if (_displayLabel.isEmpty) {
      return const SizedBox.shrink();
    }

    final previous = _previousLabel;
    if (previous == null || !_countController.isAnimating) {
      return Text(_displayLabel, style: _labelStyle);
    }

    final oldParsed = _parseLastDigit(previous);
    final newParsed = _parseLastDigit(_displayLabel);
    final canAnimateDigit =
        oldParsed.digit != null &&
        newParsed.digit != null &&
        oldParsed.prefix == newParsed.prefix &&
        oldParsed.suffix == newParsed.suffix;

    if (!canAnimateDigit) {
      return Text(_displayLabel, style: _labelStyle);
    }

    return AnimatedBuilder(
      animation: _countController,
      builder: (context, _) {
        final t = Curves.easeOutCubic.transform(_countController.value);
        final oldOffsetY = _countDirection == _directionUp
            ? -_digitHeight * t
            : _digitHeight * t;
        final newOffsetY = _countDirection == _directionUp
            ? _digitHeight * (1 - t)
            : -_digitHeight * (1 - t);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (newParsed.prefix.isNotEmpty)
              Text(newParsed.prefix, style: _labelStyle),
            ClipRect(
              child: SizedBox(
                width: _digitWidth,
                height: _digitHeight,
                child: Stack(
                  children: [
                    Transform.translate(
                      offset: Offset(0, oldOffsetY),
                      child: Opacity(
                        opacity: 1 - t,
                        child: Text(oldParsed.digit!, style: _labelStyle),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, newOffsetY),
                      child: Opacity(
                        opacity: t,
                        child: Text(newParsed.digit!, style: _labelStyle),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (newParsed.suffix.isNotEmpty)
              Text(newParsed.suffix, style: _labelStyle),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconPath = _isLiked && widget.activeIconAssetPath != null
        ? widget.activeIconAssetPath!
        : widget.iconAssetPath;
    final isAccentIcon =
        widget.iconAssetPath != null &&
        _isLiked &&
        widget.activeIconAssetPath != null;
    final iconKey = widget.iconAssetPath != null
        ? '$iconPath:$isAccentIcon'
        : 'icon:${widget.icon?.codePoint}:$isAccentIcon';

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) {
                final curve = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                );
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: curve, child: child),
                );
              },
              child: widget.iconAssetPath != null
                  ? _ReelActionIcon(
                      key: ValueKey(iconKey),
                      assetPath: iconPath!,
                      size: 31,
                      color: isAccentIcon ? null : Colors.white,
                    )
                  : Icon(
                      widget.icon,
                      key: ValueKey(iconKey),
                      color: Colors.white,
                      size: 31,
                    ),
            ),
            if (_displayLabel.isNotEmpty) ...[
              const SizedBox(height: 5),
              _buildLabel(),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReelActionIcon extends StatelessWidget {
  const _ReelActionIcon({
    super.key,
    required this.assetPath,
    required this.size,
    this.color,
  });

  final String assetPath;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (color == null) {
      return Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }

    return ImageIcon(AssetImage(assetPath), size: size, color: color);
  }
}

class _ParsedCount {
  const _ParsedCount({
    required this.prefix,
    required this.suffix,
    required this.digit,
  });

  final String prefix;
  final String suffix;
  final String? digit;
}
