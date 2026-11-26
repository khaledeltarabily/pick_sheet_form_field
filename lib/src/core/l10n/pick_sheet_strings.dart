import 'package:flutter/foundation.dart';

/// Builds a text that includes a count, such as "Selected (3)".
typedef PickSheetCountText = String Function(int count);

/// Builds a text about one item, such as "Remove Cairo".
typedef PickSheetItemText = String Function(String label);

/// The texts shown by pick sheet fields and sheets.
///
/// The package doesn't translate anything: pass texts that are already
/// translated, through `PickSheetConfig.strings`. A text left `null` falls
/// back to [PickSheetStrings.english].
///
/// Texts with a count are functions, so each language decides where the
/// number goes and which plural form to use.
@immutable
class PickSheetStrings {
  /// Creates a set of texts. Only the ones you pass override the fallbacks.
  const PickSheetStrings({
    this.confirm,
    this.confirmWithCount,
    this.sheetDescription,
    this.search,
    this.noResults,
    this.allWithCount,
    this.selectedWithCount,
    this.selectAll,
    this.clearAll,
    this.removeItem,
    this.loading,
  });

  /// Confirm button while nothing is selected. English: "Confirm".
  final String? confirm;

  /// Confirm button with the selected count. English: "Confirm (3)".
  final PickSheetCountText? confirmWithCount;

  /// Sheet description when the field passes none.
  /// English: "Select one or more".
  final String? sheetDescription;

  /// Search box hint. English: "Search".
  final String? search;

  /// Shown when no item matches. English: "No results found".
  final String? noResults;

  /// Tab that shows every item. English: "All (12)".
  final PickSheetCountText? allWithCount;

  /// Tab that shows the selected items; screen readers also read it on the
  /// field. English: "Selected (3)".
  final PickSheetCountText? selectedWithCount;

  /// Toolbar button that selects every visible item. English: "Select all".
  final String? selectAll;

  /// Button that deselects everything. English: "Clear all".
  final String? clearAll;

  /// Screen reader label of a chip's remove button. English: "Remove Cairo".
  final PickSheetItemText? removeItem;

  /// Screen reader label of the default loading placeholder.
  /// English: "Loading".
  final String? loading;

  /// The built-in English texts, used for anything not overridden.
  static const PickSheetStrings english = PickSheetStrings(
    confirm: 'Confirm',
    confirmWithCount: _confirmWithCount,
    sheetDescription: 'Select one or more',
    search: 'Search',
    noResults: 'No results found',
    allWithCount: _allWithCount,
    selectedWithCount: _selectedWithCount,
    selectAll: 'Select all',
    clearAll: 'Clear all',
    removeItem: _removeItem,
    loading: 'Loading',
  );

  /// A copy where every non-null text of [other] replaces this one's.
  PickSheetStrings merge(PickSheetStrings? other) {
    if (other == null) return this;
    return PickSheetStrings(
      confirm: other.confirm ?? confirm,
      confirmWithCount: other.confirmWithCount ?? confirmWithCount,
      sheetDescription: other.sheetDescription ?? sheetDescription,
      search: other.search ?? search,
      noResults: other.noResults ?? noResults,
      allWithCount: other.allWithCount ?? allWithCount,
      selectedWithCount: other.selectedWithCount ?? selectedWithCount,
      selectAll: other.selectAll ?? selectAll,
      clearAll: other.clearAll ?? clearAll,
      removeItem: other.removeItem ?? removeItem,
      loading: other.loading ?? loading,
    );
  }

  static String _confirmWithCount(int count) => 'Confirm ($count)';
  static String _allWithCount(int count) => 'All ($count)';
  static String _selectedWithCount(int count) => 'Selected ($count)';
  static String _removeItem(String label) => 'Remove $label';
}
