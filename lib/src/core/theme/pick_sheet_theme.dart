import 'package:flutter/material.dart';

import 'resolved_pick_sheet_theme.dart';

/// Colors and options of pick sheet fields and sheets, added to
/// [ThemeData.extensions].
///
/// Only pick sheet widgets read these values; the rest of the app is not
/// affected.
///
/// Every value is optional. Anything left `null` comes from the app's theme:
/// its input decoration, bottom sheet and button themes where they apply, then
/// its [ColorScheme].
///
/// ```dart
/// ThemeData(
///   extensions: const [PickSheetTheme(accentColor: Colors.indigo)],
/// )
/// ```
@immutable
class PickSheetTheme extends ThemeExtension<PickSheetTheme> {
  /// Creates a pick sheet theme. Each field documents its default.
  const PickSheetTheme({
    this.accentColor,
    this.onAccentColor,
    this.surfaceColor,
    this.titleColor,
    this.subtitleColor,
    this.labelColor,
    this.floatingLabelColor,
    this.labelStyle,
    this.disabledColor,
    this.borderColor,
    this.disabledBorderColor,
    this.errorColor,
    this.statusIconColor,
    this.dragHandleColor,
    this.enableHaptics,
  });

  /// Selected items, chips, buttons and the focused field.
  /// Defaults to [ColorScheme.primary].
  final Color? accentColor;

  /// Text and icons drawn on [accentColor]. Defaults to [ColorScheme.onPrimary].
  final Color? onAccentColor;

  /// Background of the sheet and its search box.
  /// Defaults to [ColorScheme.surface].
  final Color? surfaceColor;

  /// Sheet title and item labels. Defaults to [ColorScheme.onSurface].
  final Color? titleColor;

  /// Sheet description, item subtitles and the search hint.
  /// Defaults to [ColorScheme.onSurfaceVariant].
  final Color? subtitleColor;

  /// The field's label while it sits inside the empty field.
  /// Defaults to [ColorScheme.onSurfaceVariant] (gray), like a Material text
  /// field.
  final Color? labelColor;

  /// The field's label once it floats above the selection.
  /// Defaults to [labelColor]. A focused field uses [accentColor] instead.
  final Color? floatingLabelColor;

  /// Base style of the field's label. Its color comes from the colors above.
  final TextStyle? labelStyle;

  /// Text, chips and icons of a disabled field.
  /// Defaults to [ColorScheme.onSurface] at 38% opacity.
  final Color? disabledColor;

  /// Outline of the field. Defaults to [ColorScheme.outline].
  final Color? borderColor;

  /// Outline of a disabled field.
  /// Defaults to [ColorScheme.onSurface] at 12% opacity.
  final Color? disabledBorderColor;

  /// Error outline and text. Defaults to [ColorScheme.error].
  final Color? errorColor;

  /// The offline and failure icons and the dropdown arrow.
  /// Defaults to [ColorScheme.onSurfaceVariant].
  final Color? statusIconColor;

  /// The sheet's drag handle.
  /// Defaults to [ColorScheme.onSurfaceVariant] at 40% opacity.
  final Color? dragHandleColor;

  /// Whether taps give haptic feedback. Defaults to `true`.
  final bool? enableHaptics;

  /// The theme for [context], with every default filled in.
  static ResolvedPickSheetTheme of(BuildContext context) =>
      ResolvedPickSheetTheme.from(Theme.of(context));

  @override
  PickSheetTheme copyWith({
    Color? accentColor,
    Color? onAccentColor,
    Color? surfaceColor,
    Color? titleColor,
    Color? subtitleColor,
    Color? labelColor,
    Color? floatingLabelColor,
    TextStyle? labelStyle,
    Color? disabledColor,
    Color? borderColor,
    Color? disabledBorderColor,
    Color? errorColor,
    Color? statusIconColor,
    Color? dragHandleColor,
    bool? enableHaptics,
  }) {
    return PickSheetTheme(
      accentColor: accentColor ?? this.accentColor,
      onAccentColor: onAccentColor ?? this.onAccentColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      titleColor: titleColor ?? this.titleColor,
      subtitleColor: subtitleColor ?? this.subtitleColor,
      labelColor: labelColor ?? this.labelColor,
      floatingLabelColor: floatingLabelColor ?? this.floatingLabelColor,
      labelStyle: labelStyle ?? this.labelStyle,
      disabledColor: disabledColor ?? this.disabledColor,
      borderColor: borderColor ?? this.borderColor,
      disabledBorderColor: disabledBorderColor ?? this.disabledBorderColor,
      errorColor: errorColor ?? this.errorColor,
      statusIconColor: statusIconColor ?? this.statusIconColor,
      dragHandleColor: dragHandleColor ?? this.dragHandleColor,
      enableHaptics: enableHaptics ?? this.enableHaptics,
    );
  }

  @override
  PickSheetTheme lerp(
    covariant ThemeExtension<PickSheetTheme>? other,
    double t,
  ) {
    if (other is! PickSheetTheme) return this;
    return PickSheetTheme(
      accentColor: Color.lerp(accentColor, other.accentColor, t),
      onAccentColor: Color.lerp(onAccentColor, other.onAccentColor, t),
      surfaceColor: Color.lerp(surfaceColor, other.surfaceColor, t),
      titleColor: Color.lerp(titleColor, other.titleColor, t),
      subtitleColor: Color.lerp(subtitleColor, other.subtitleColor, t),
      labelColor: Color.lerp(labelColor, other.labelColor, t),
      floatingLabelColor: Color.lerp(
        floatingLabelColor,
        other.floatingLabelColor,
        t,
      ),
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t),
      disabledColor: Color.lerp(disabledColor, other.disabledColor, t),
      borderColor: Color.lerp(borderColor, other.borderColor, t),
      disabledBorderColor: Color.lerp(
        disabledBorderColor,
        other.disabledBorderColor,
        t,
      ),
      errorColor: Color.lerp(errorColor, other.errorColor, t),
      statusIconColor: Color.lerp(statusIconColor, other.statusIconColor, t),
      dragHandleColor: Color.lerp(dragHandleColor, other.dragHandleColor, t),
      enableHaptics: t < 0.5 ? enableHaptics : other.enableHaptics,
    );
  }
}
