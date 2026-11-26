import 'package:flutter/material.dart';

import '../../../../core/config/pick_sheet_config.dart';
import '../../../../core/l10n/pick_sheet_strings.dart';
import '../controllers/pick_sheet_controller.dart';
import '../../domain/entities/pick_sheet_status.dart';
import '../../data/models/pick_sheet_item.dart';
import 'pick_sheet_field_view.dart';
import 'pick_sheet_form_field_state.dart';

/// A multi-select form field, used like [DropdownButtonFormField].
///
/// The selected values show as removable chips inside an outlined field.
/// Tapping the field opens a bottom sheet to change them.
///
/// ```dart
/// PickSheetFormField<City>(
///   items: PickSheetItem.listOf(cities, label: (city) => city.name),
///   labelText: 'Cities',
///   initialValue: selectedCities,
///   onChanged: (cities) => ...,
///   validator: (cities) => cities!.isEmpty ? 'Required' : null,
/// )
/// ```
///
/// * Items are compared with `==`, so `T` must override it (for example by
///   extending `Equatable`).
/// * The value always follows the [items] order.
/// * [initialValue] can change later (for example once the items load). Like
///   [DropdownButtonFormField], that doesn't call [onChanged].
/// * While [initialValue] has values that aren't in [items] yet, and
///   [status] is loading or [items] is empty, the field shows its loading
///   placeholder instead of empty chips. Once the items arrive, values with no
///   matching item are dropped without calling [onChanged]. Pass [status]
///   whenever the items load asynchronously.
/// * `Form.validate()`, `save()` and `reset()` work as with Flutter's fields.
class PickSheetFormField<T> extends FormField<List<T>> {
  /// Creates a multi-select form field.
  ///
  /// Pass either [controller] or [initialValue], not both.
  PickSheetFormField({
    super.key,
    required this.items,
    required this.labelText,
    this.controller,
    List<T>? initialValue,
    this.onChanged,
    super.onSaved,
    super.validator,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.enabled,
    this.status = PickSheetStatus.ready,
    this.searchEnabled = false,
    this.maxSelections,
    this.sheetTitle,
    this.sheetDescription,
    this.sheetIcon = Icons.checklist_rounded,
    this.decoration,
    this.config,
  }) : assert(
         controller == null || initialValue == null,
         'Pass either a controller or an initialValue, not both.',
       ),
       assert(
         maxSelections == null || maxSelections > 0,
         'maxSelections must be greater than 0.',
       ),
       super(
         initialValue: controller?.value ?? initialValue ?? <T>[],
         builder: (field) =>
             PickSheetFieldView<T>(state: field as PickSheetFormFieldState<T>),
       );

  /// The options. Recreating the list on every build is fine.
  final List<PickSheetItem<T>> items;

  /// The field's label.
  final String labelText;

  /// Controls the selection from outside the field. Optional.
  final PickSheetController<T>? controller;

  /// Called when the user changes the selection, not when code does.
  final ValueChanged<List<T>>? onChanged;

  /// Loading state of [items]. The field can be opened only when ready.
  final PickSheetStatus status;

  /// Shows a search box at the top of the sheet.
  final bool searchEnabled;

  /// The most values the user can pick in the sheet, or `null` for no limit.
  ///
  /// Once the limit is reached, the other items are disabled and
  /// "Select all" is disabled when it would go over the limit. With `1`,
  /// picking an item replaces the previous one, so the field works as a
  /// single-select. Values set from code (initialValue, controller) are not
  /// trimmed.
  final int? maxSelections;

  /// The sheet's title. Defaults to [labelText].
  final String? sheetTitle;

  /// The sheet's description. Defaults to [PickSheetStrings.sheetDescription].
  final String? sheetDescription;

  /// The icon in the sheet's header.
  final IconData sheetIcon;

  /// Overrides parts of the field's look. Borders left `null` come from
  /// `PickSheetTheme`, then from the app's `InputDecorationTheme`, then from
  /// the `ColorScheme`.
  final InputDecoration? decoration;

  /// Texts and builders for this field and its sheet. Anything left `null`
  /// uses the built-in default. To share one config across the app, wrap
  /// this field in your own widget that passes it.
  final PickSheetConfig? config;

  @override
  PickSheetFormFieldState<T> createState() => PickSheetFormFieldState<T>();
}
