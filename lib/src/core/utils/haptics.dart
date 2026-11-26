import 'package:flutter/services.dart';

/// The package's haptic feedback, in one place so it can be turned off with
/// `PickSheetTheme.enableHaptics`.
abstract final class Haptics {
  /// A light tick, for toggling an item or a tab.
  static void selection({required bool enabled}) {
    if (enabled) HapticFeedback.selectionClick();
  }

  /// A firmer tap, for opening the sheet or clearing the field.
  static void impact({required bool enabled}) {
    if (enabled) HapticFeedback.mediumImpact();
  }
}
