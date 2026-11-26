import 'package:flutter/material.dart';

import '../../../../core/l10n/pick_sheet_strings.dart';
import '../../data/models/pick_sheet_item.dart';
import 'pick_sheet_view.dart';

/// Opens the multi-select bottom sheet on its own, without a field.
///
/// Returns the selected values in the [items] order when the user confirms,
/// or `null` when the sheet is dismissed.
///
/// [maxSelections] limits how many values can be picked; once reached, the
/// other items are disabled. With `1`, picking an item replaces the previous
/// one (single-select).
///
/// Items are compared with `==`, so `T` must override it.
Future<List<T>?> showPickSheet<T>({
  required BuildContext context,
  required List<PickSheetItem<T>> items,
  required String title,
  String? description,
  IconData icon = Icons.checklist_rounded,
  List<T> initialSelected = const [],
  bool searchEnabled = false,
  int? maxSelections,
  PickSheetStrings? strings,
}) {
  assert(
    maxSelections == null || maxSelections > 0,
    'maxSelections must be greater than 0.',
  );
  // Built once: the route calls `builder` again on every MediaQuery change
  // (each keyboard animation frame). Returning the same instance lets the
  // framework skip rebuilding the whole sheet.
  final sheet = PickSheetView<T>(
    items: items,
    title: title,
    description: description,
    icon: icon,
    initialSelected: initialSelected,
    searchEnabled: searchEnabled,
    maxSelections: maxSelections,
    strings: strings,
  );
  return showModalBottomSheet<List<T>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => sheet,
  );
}
