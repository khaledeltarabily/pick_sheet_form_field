import 'package:flutter/material.dart';

import '../../../../core/theme/pick_sheet_theme.dart';
import '../../../../core/theme/resolved_pick_sheet_theme.dart';

/// The field's [InputDecoration].
///
/// Values in [base] always win.
///
/// Each border then comes from a color set in [PickSheetTheme], then from the
/// same border in the app's `InputDecorationTheme`, then from [theme]'s
/// default. A recolored or default border keeps the app's border shape.
///
/// Label and error styles start from the app's `InputDecorationTheme`, with
/// [PickSheetTheme] values on top. Padding and error lines come from the app
/// theme when it sets them. The field is always dense unless [base] says
/// otherwise. Label colors follow Material: the color at rest, the accent
/// color while focused, the error color with an error.
InputDecoration buildFieldDecoration({
  required BuildContext context,
  required ResolvedPickSheetTheme theme,
  required InputDecoration? base,
  required String labelText,
  required String? errorText,
  required bool enabled,
  required bool focused,
}) {
  final decoration = base ?? const InputDecoration();
  final hasError = errorText != null;

  final appTheme = Theme.of(context).inputDecorationTheme;
  final chosen = Theme.of(context).extension<PickSheetTheme>();

  TextStyle label(TextStyle? fromApp, Color atRest) {
    final color = !enabled
        ? theme.disabled
        : hasError
        ? theme.error
        : focused
        ? theme.accent
        : atRest;
    return (fromApp ?? const TextStyle())
        .merge(chosen?.labelStyle)
        .copyWith(color: color);
  }

  InputBorder border(
    InputBorder? fromField,
    InputBorder? fromApp,
    Color? chosenColor,
    Color defaultColor, [
    double width = 1,
  ]) {
    if (fromField != null) return fromField;
    if (chosenColor == null && fromApp != null) return fromApp;
    final shape = fromApp ?? appTheme.border ?? const OutlineInputBorder();
    return shape.copyWith(
      borderSide: BorderSide(color: chosenColor ?? defaultColor, width: width),
    );
  }

  return decoration
      .copyWith(
        labelText: decoration.labelText ?? labelText,
        labelStyle:
            decoration.labelStyle ?? label(appTheme.labelStyle, theme.label),
        floatingLabelStyle:
            decoration.floatingLabelStyle ??
            label(
              appTheme.floatingLabelStyle ?? appTheme.labelStyle,
              theme.floatingLabel,
            ),
        isDense: decoration.isDense ?? true,
        contentPadding:
            decoration.contentPadding ??
            appTheme.contentPadding ??
            const EdgeInsetsDirectional.fromSTEB(10, 8, 4, 8),
        errorText: errorText,
        errorMaxLines: decoration.errorMaxLines ?? appTheme.errorMaxLines ?? 2,
        errorStyle:
            decoration.errorStyle ??
            const TextStyle(
              fontSize: 12,
            ).merge(appTheme.errorStyle).copyWith(color: theme.error),
        border: border(
          decoration.border,
          appTheme.border,
          chosen?.borderColor,
          theme.border,
        ),
        enabledBorder: border(
          decoration.enabledBorder,
          appTheme.enabledBorder,
          chosen?.borderColor,
          theme.border,
        ),
        disabledBorder: border(
          decoration.disabledBorder,
          appTheme.disabledBorder,
          chosen?.disabledBorderColor,
          theme.disabledBorder,
        ),
        focusedBorder: border(
          decoration.focusedBorder,
          appTheme.focusedBorder,
          chosen?.accentColor,
          theme.accent,
          2,
        ),
        errorBorder: border(
          decoration.errorBorder,
          appTheme.errorBorder,
          chosen?.errorColor,
          theme.error,
        ),
        focusedErrorBorder: border(
          decoration.focusedErrorBorder,
          appTheme.focusedErrorBorder,
          chosen?.errorColor,
          theme.error,
          2,
        ),
        enabled: enabled,
      )
      .applyDefaults(appTheme);
}
