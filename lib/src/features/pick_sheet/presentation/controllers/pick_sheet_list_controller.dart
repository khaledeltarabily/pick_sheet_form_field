import 'package:flutter/foundation.dart';

import '../../data/models/pick_sheet_item.dart';
import '../../domain/services/selection_rules.dart';
import '../../domain/usecases/filter_options.dart';
import '../../domain/value_objects/search_index.dart';

/// State of an open pick sheet: the selection, the search query and the
/// "selected only" filter.
///
/// Each part is its own [ValueListenable], so a widget rebuilds only for the
/// part it shows. [visibleItems] keeps the same list instance until the
/// filter result changes: toggling an item doesn't rebuild the list, only the
/// rows whose selected state changed.
class PickSheetListController<T> {
  /// Creates a controller for [items] with [initialSelected] selected.
  PickSheetListController({
    required List<PickSheetItem<T>> items,
    Iterable<T> initialSelected = const [],
    int? maxSelections,
  }) : this._(List<PickSheetItem<T>>.unmodifiable(items), {
         ...initialSelected,
       }, maxSelections);

  PickSheetListController._(this.items, Set<T> selected, this.maxSelections)
    : assert(maxSelections == null || maxSelections > 0),
      _searchIndex = SearchIndex(items.map((item) => item.searchText)),
      _selection = ValueNotifier(selected),
      _visibleItems = ValueNotifier(items),
      _allVisibleSelected = ValueNotifier(
        SelectionRules.containsAll(selected, items.map((item) => item.value)),
      );

  /// Every item of the sheet, in display order.
  final List<PickSheetItem<T>> items;

  /// The most values that can be selected, or `null` for no limit. With 1,
  /// selecting a value replaces the previous one.
  final int? maxSelections;

  static const _filterOptions = FilterOptions();

  final SearchIndex _searchIndex;
  final ValueNotifier<Set<T>> _selection;
  final ValueNotifier<List<PickSheetItem<T>>> _visibleItems;
  final ValueNotifier<bool> _showSelectedOnly = ValueNotifier(false);
  final ValueNotifier<bool> _allVisibleSelected;
  String _query = '';

  /// The selected values. A new set on every change.
  ValueListenable<Set<T>> get selection => _selection;

  /// The items matching the search and the "selected only" filter.
  ValueListenable<List<PickSheetItem<T>>> get visibleItems => _visibleItems;

  /// Whether only the selected items are shown.
  ValueListenable<bool> get showSelectedOnly => _showSelectedOnly;

  /// Whether every visible item is selected, so the toolbar offers
  /// "Clear all" instead of "Select all".
  ValueListenable<bool> get allVisibleSelected => _allVisibleSelected;

  /// Whether [value] is selected.
  bool isSelected(T value) => _selection.value.contains(value);

  /// Whether tapping [value] can change the selection, given
  /// [maxSelections]. Rows that can't are shown disabled.
  bool canSelect(T value) =>
      SelectionRules.canSelect(_selection.value, value, max: maxSelections);

  /// Whether "Select all" can add every visible item within [maxSelections].
  bool get canSelectAllVisible => SelectionRules.canSelectAll(
    _selection.value,
    _visibleItems.value.map((item) => item.value),
    max: maxSelections,
  );

  /// The selected values in the items order.
  List<T> get selectedValues =>
      SelectionRules.ordered(items.map((item) => item.value), _selection.value);

  /// Selects [value], or deselects it if it was selected. Within
  /// [maxSelections]; with a limit of 1, [value] replaces the selection.
  void toggle(T value) => _apply(
    selection: SelectionRules.toggle(
      _selection.value,
      value,
      max: maxSelections,
    ),
  );

  /// Selects every visible item, or deselects them all if they're all
  /// selected. Does nothing when selecting them would exceed
  /// [maxSelections].
  void toggleVisible() {
    final allSelected = _allVisibleSelected.value;
    if (!allSelected && !canSelectAllVisible) return;
    _apply(
      selection: SelectionRules.toggleAll(
        _selection.value,
        _visibleItems.value.map((item) => item.value),
        allSelected: allSelected,
      ),
    );
  }

  /// Filters the items by [query], matching labels and subtitles.
  void search(String query) => _apply(query: SearchIndex.normalize(query));

  /// Shows only the selected items, or every item.
  void setShowSelectedOnly(bool value) => _apply(showSelectedOnly: value);

  /// Releases the listenables.
  void dispose() {
    _selection.dispose();
    _visibleItems.dispose();
    _showSelectedOnly.dispose();
    _allVisibleSelected.dispose();
  }

  /// Filters again only when the result can change; otherwise keeps the same
  /// [visibleItems] instance so the list doesn't rebuild.
  void _apply({Set<T>? selection, String? query, bool? showSelectedOnly}) {
    final nextSelection = selection ?? _selection.value;
    final nextQuery = query ?? _query;
    final selectedOnly = showSelectedOnly ?? _showSelectedOnly.value;

    final mustFilter =
        nextQuery != _query ||
        selectedOnly != _showSelectedOnly.value ||
        (selectedOnly && selection != null);
    final nextVisible = mustFilter
        ? _filterOptions<T, PickSheetItem<T>>(
            options: items,
            index: _searchIndex,
            selected: nextSelection,
            query: nextQuery,
            selectedOnly: selectedOnly,
          )
        : _visibleItems.value;

    _query = nextQuery;
    _selection.value = nextSelection;
    _showSelectedOnly.value = selectedOnly;
    _visibleItems.value = nextVisible;
    _allVisibleSelected.value = SelectionRules.containsAll(
      nextSelection,
      nextVisible.map((item) => item.value),
    );
  }
}
