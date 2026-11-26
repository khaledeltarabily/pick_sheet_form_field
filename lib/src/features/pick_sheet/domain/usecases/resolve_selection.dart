import '../entities/resolved_selection.dart';

/// Splits a selection into values found among the item values and values
/// that aren't.
final class ResolveSelection {
  /// Creates the use case.
  const ResolveSelection();

  /// Splits [selected] into values found in [itemValues] and values that
  /// aren't. Resolved values follow the order of [itemValues].
  ResolvedSelection<T> call<T>(Iterable<T> selected, Iterable<T> itemValues) {
    final wanted = selected.toSet();
    final found = <T>{};
    final resolved = <T>[];
    for (final value in itemValues) {
      if (wanted.contains(value) && found.add(value)) resolved.add(value);
    }
    return ResolvedSelection(
      resolved: resolved,
      unresolved: [
        for (final value in wanted)
          if (!found.contains(value)) value,
      ],
    );
  }
}
