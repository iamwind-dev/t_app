import 'package:flutter/material.dart';

@immutable
final class AppIconTokens {
  const AppIconTokens._();

  static Color logo(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color navigationSelected(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color navigationUnselected(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  static Color utility(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color utilityMuted(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }
}
