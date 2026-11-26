import '../entities/pick_sheet_option.dart';
import '../value_objects/search_index.dart';

/// Filters options by a search query and, optionally, to the selected ones.
final class FilterOptions {
  /// Creates the use case.
  const FilterOptions();

  /// The [options] matching the already normalized [query] (see
  /// [SearchIndex.normalize]) that are also in [selected] when
  /// [selectedOnly].
  ///
  /// [index] must index [options] in the same order. Returns [options]
  /// itself when nothing filters, so callers can skip a rebuild by identity.
  List<E> call<T, E extends PickSheetOption<T>>({
    required List<E> options,
    required SearchIndex index,
    required Set<T> selected,
    required String query,
    required bool selectedOnly,
  }) {
    if (!selectedOnly && query.isEmpty) return options;
    return [
      for (var i = 0; i < options.length; i++)
        if ((!selectedOnly || selected.contains(options[i].value)) &&
            index.matches(i, query))
          options[i],
    ];
  }
}
