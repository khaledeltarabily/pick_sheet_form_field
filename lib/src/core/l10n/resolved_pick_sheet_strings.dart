import 'package:flutter/widgets.dart';

import '../config/pick_sheet_config.dart';
import 'pick_sheet_strings.dart';

/// [PickSheetStrings] with every text resolved, so widgets don't handle
/// `null`.
@immutable
class ResolvedPickSheetStrings {
  const ResolvedPickSheetStrings._({
    required this.confirm,
    required this.confirmWithCount,
    required this.sheetDescription,
    required this.search,
    required this.noResults,
    required this.allWithCount,
    required this.selectedWithCount,
    required this.selectAll,
    required this.clearAll,
    required this.removeItem,
    required this.loading,
  });

  /// Resolves the texts for [context]: [override] first, then the app-wide
  /// [PickSheetConfig.strings], then English.
  factory ResolvedPickSheetStrings.of(
    BuildContext context, [
    PickSheetStrings? override,
  ]) {
    final strings = PickSheetStrings.english
        .merge(PickSheetConfig.maybeOf(context)?.strings)
        .merge(override);
    return ResolvedPickSheetStrings._(
      confirm: strings.confirm!,
      confirmWithCount: strings.confirmWithCount!,
      sheetDescription: strings.sheetDescription!,
      search: strings.search!,
      noResults: strings.noResults!,
      allWithCount: strings.allWithCount!,
      selectedWithCount: strings.selectedWithCount!,
      selectAll: strings.selectAll!,
      clearAll: strings.clearAll!,
      removeItem: strings.removeItem!,
      loading: strings.loading!,
    );
  }

  /// See [PickSheetStrings.confirm].
  final String confirm;

  /// See [PickSheetStrings.confirmWithCount].
  final PickSheetCountText confirmWithCount;

  /// See [PickSheetStrings.sheetDescription].
  final String sheetDescription;

  /// See [PickSheetStrings.search].
  final String search;

  /// See [PickSheetStrings.noResults].
  final String noResults;

  /// See [PickSheetStrings.allWithCount].
  final PickSheetCountText allWithCount;

  /// See [PickSheetStrings.selectedWithCount].
  final PickSheetCountText selectedWithCount;

  /// See [PickSheetStrings.selectAll].
  final String selectAll;

  /// See [PickSheetStrings.clearAll].
  final String clearAll;

  /// See [PickSheetStrings.removeItem].
  final PickSheetItemText removeItem;

  /// See [PickSheetStrings.loading].
  final String loading;
}
