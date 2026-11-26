import 'package:flutter/material.dart';

import '../../../../core/l10n/pick_sheet_strings.dart';
import '../../../../core/theme/pick_sheet_theme.dart';
import '../../../../core/l10n/resolved_pick_sheet_strings.dart';
import '../controllers/pick_sheet_list_controller.dart';
import '../../data/models/pick_sheet_item.dart';
import 'confirm_button.dart';
import 'pick_sheet_list.dart';
import 'selection_toolbar.dart';
import 'sheet_header.dart';
import 'sheet_search_field.dart';

/// The content of the multi-select bottom sheet. Open it with
/// `showPickSheet`.
class PickSheetView<T> extends StatefulWidget {
  /// Creates the sheet content.
  const PickSheetView({
    super.key,
    required this.items,
    required this.title,
    required this.icon,
    this.description,
    this.initialSelected = const [],
    this.searchEnabled = false,
    this.maxSelections,
    this.strings,
  });

  /// The options.
  final List<PickSheetItem<T>> items;

  /// The header title.
  final String title;

  /// The header icon.
  final IconData icon;

  /// The header description. Defaults to [PickSheetStrings.sheetDescription].
  final String? description;

  /// Values selected when the sheet opens.
  final List<T> initialSelected;

  /// Whether to show the search box.
  final bool searchEnabled;

  /// The most values that can be selected, or `null` for no limit.
  final int? maxSelections;

  /// Texts for this sheet only.
  final PickSheetStrings? strings;

  @override
  State<PickSheetView<T>> createState() => _PickSheetViewState<T>();
}

class _PickSheetViewState<T> extends State<PickSheetView<T>> {
  late final PickSheetListController<T> _controller = PickSheetListController(
    items: widget.items,
    initialSelected: widget.initialSelected,
    maxSelections: widget.maxSelections,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() => Navigator.pop(context, _controller.selectedValues);

  @override
  Widget build(BuildContext context) {
    final theme = PickSheetTheme.of(context);
    final strings = ResolvedPickSheetStrings.of(context, widget.strings);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: theme.surface,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.85,
          child: Column(
            children: [
              SheetHeader(
                title: widget.title,
                description: widget.description ?? strings.sheetDescription,
                icon: widget.icon,
              ),
              if (widget.searchEnabled)
                SheetSearchField(
                  hintText: strings.search,
                  onSearch: _controller.search,
                ),
              SelectionToolbar<T>(controller: _controller, strings: strings),
              const SizedBox(height: 12),
              Expanded(
                child: PickSheetList<T>(
                  controller: _controller,
                  emptyText: strings.noResults,
                ),
              ),
              SafeArea(
                top: false,
                child: ValueListenableBuilder<Set<T>>(
                  valueListenable: _controller.selection,
                  builder: (context, selected, _) => ConfirmButton(
                    label: selected.isEmpty
                        ? strings.confirm
                        : strings.confirmWithCount(selected.length),
                    onPressed: _confirm,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
