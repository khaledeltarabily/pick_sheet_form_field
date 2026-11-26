import 'package:flutter/material.dart';

import '../../../../core/theme/pick_sheet_theme.dart';
import '../../../../core/l10n/resolved_pick_sheet_strings.dart';
import '../../../../core/utils/haptics.dart';
import 'default_loading_field.dart';
import 'field_decoration.dart';
import 'field_trailing.dart';
import 'pick_sheet_form_field.dart';
import 'pick_sheet_form_field_state.dart';
import 'selected_chips_row.dart';

/// What a [PickSheetFormField] draws: the loading placeholder, or the
/// outlined field with its chips.
class PickSheetFieldView<T> extends StatelessWidget {
  /// Creates the view of [state].
  const PickSheetFieldView({super.key, required this.state});

  /// The field's state.
  final PickSheetFormFieldState<T> state;

  @override
  Widget build(BuildContext context) {
    final field = state.widget as PickSheetFormField<T>;
    final strings = ResolvedPickSheetStrings.from(field.config?.strings);

    if (state.isWaiting) {
      return field.config?.loadingBuilder?.call(context) ??
          DefaultLoadingField(semanticLabel: strings.loading);
    }

    final theme = PickSheetTheme.of(context);
    final interactive = state.isInteractive;
    final selection = state.shownSelection;

    return Semantics(
      button: true,
      enabled: interactive,
      label: field.labelText,
      value: selection.isEmpty
          ? null
          : strings.selectedWithCount(selection.length),
      child: InkWell(
        focusNode: state.focusNode,
        canRequestFocus: interactive,
        onFocusChange: state.handleFocusChange,
        onTap: interactive
            ? () {
                Haptics.impact(enabled: theme.enableHaptics);
                state.openSheet();
              }
            : null,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        child: InputDecorator(
          isEmpty: selection.isEmpty,
          isFocused: state.hasFocus,
          decoration: buildFieldDecoration(
            context: context,
            theme: theme,
            base: field.decoration,
            labelText: field.labelText,
            errorText: state.errorText,
            enabled: interactive,
            focused: state.hasFocus,
          ),
          child: SizedBox(
            height: 30,
            child: Row(
              children: [
                Expanded(
                  child: SelectedChipsRow<T>(
                    values: selection,
                    labelOf: state.labelOf,
                    enabled: interactive,
                    removeLabel: strings.removeItem,
                    onRemove: interactive ? state.removeValue : null,
                  ),
                ),
                FieldTrailing(
                  count: selection.length,
                  status: field.status,
                  enabled: interactive,
                  clearAllLabel: strings.clearAll,
                  onClearAll: interactive && selection.length > 1
                      ? state.clearAll
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
