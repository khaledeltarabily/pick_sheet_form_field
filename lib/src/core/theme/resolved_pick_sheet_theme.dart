import 'package:flutter/material.dart';

import 'pick_sheet_theme.dart';

/// A [PickSheetTheme] with every `null` filled in from the app's theme.
///
/// A value set in [PickSheetTheme] wins. Otherwise it comes from the app's
/// matching component theme, if it has one, and then from the [ColorScheme].
/// Nothing is written back to the app's theme.
@immutable
class ResolvedPickSheetTheme {
  /// Creates a resolved theme.
  const ResolvedPickSheetTheme({
    required this.accent,
    required this.onAccent,
    required this.surface,
    required this.title,
    required this.subtitle,
    required this.label,
    required this.floatingLabel,
    required this.labelStyle,
    required this.disabled,
    required this.border,
    required this.disabledBorder,
    required this.error,
    required this.statusIcon,
    required this.dragHandle,
    required this.enableHaptics,
  });

  /// Resolves the [PickSheetTheme] of [theme], or the defaults if it has none.
  factory ResolvedPickSheetTheme.from(ThemeData theme) {
    final ext = theme.extension<PickSheetTheme>() ?? const PickSheetTheme();
    final scheme = theme.colorScheme;
    final input = theme.inputDecorationTheme;
    final sheet = theme.bottomSheetTheme;
    final label =
        ext.labelColor ?? input.labelStyle?.color ?? scheme.onSurfaceVariant;
    return ResolvedPickSheetTheme(
      accent: ext.accentColor ?? scheme.primary,
      onAccent: ext.onAccentColor ?? scheme.onPrimary,
      surface:
          ext.surfaceColor ??
          sheet.modalBackgroundColor ??
          sheet.backgroundColor ??
          scheme.surface,
      title: ext.titleColor ?? scheme.onSurface,
      subtitle: ext.subtitleColor ?? scheme.onSurfaceVariant,
      label: label,
      floatingLabel:
          ext.floatingLabelColor ??
          ext.labelColor ??
          input.floatingLabelStyle?.color ??
          label,
      labelStyle: ext.labelStyle ?? const TextStyle(),
      disabled: ext.disabledColor ?? scheme.onSurface.withValues(alpha: 0.38),
      border: ext.borderColor ?? scheme.outline,
      disabledBorder:
          ext.disabledBorderColor ?? scheme.onSurface.withValues(alpha: 0.12),
      error: ext.errorColor ?? input.errorStyle?.color ?? scheme.error,
      statusIcon: ext.statusIconColor ?? scheme.onSurfaceVariant,
      dragHandle:
          ext.dragHandleColor ??
          sheet.dragHandleColor ??
          scheme.onSurfaceVariant.withValues(alpha: 0.4),
      enableHaptics: ext.enableHaptics ?? true,
    );
  }

  /// See [PickSheetTheme.accentColor].
  final Color accent;

  /// See [PickSheetTheme.onAccentColor].
  final Color onAccent;

  /// See [PickSheetTheme.surfaceColor].
  final Color surface;

  /// See [PickSheetTheme.titleColor].
  final Color title;

  /// See [PickSheetTheme.subtitleColor].
  final Color subtitle;

  /// See [PickSheetTheme.labelColor].
  final Color label;

  /// See [PickSheetTheme.floatingLabelColor].
  final Color floatingLabel;

  /// See [PickSheetTheme.labelStyle].
  final TextStyle labelStyle;

  /// See [PickSheetTheme.disabledColor].
  final Color disabled;

  /// See [PickSheetTheme.borderColor].
  final Color border;

  /// See [PickSheetTheme.disabledBorderColor].
  final Color disabledBorder;

  /// See [PickSheetTheme.errorColor].
  final Color error;

  /// See [PickSheetTheme.statusIconColor].
  final Color statusIcon;

  /// See [PickSheetTheme.dragHandleColor].
  final Color dragHandle;

  /// See [PickSheetTheme.enableHaptics].
  final bool enableHaptics;
}
