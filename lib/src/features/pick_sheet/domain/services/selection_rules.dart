/// Pure selection rules shared by the field and the sheet.
///
/// Every method returns a new collection and leaves its arguments unchanged,
/// so callers can compare old and new values by identity.
abstract final class SelectionRules {
  /// [selected] with [value] added, or removed if it was already selected.
  ///
  /// With [max], adding is ignored once [max] values are selected, except
  /// when [max] is 1: then [value] replaces the current selection.
  static Set<T> toggle<T>(Set<T> selected, T value, {int? max}) {
    if (selected.contains(value)) return {...selected}..remove(value);
    if (max == 1) return {value};
    if (!canSelect(selected, value, max: max)) return {...selected};
    return {...selected, value};
  }

  /// Whether tapping [value] can change the selection under [max]: it is
  /// already selected (so it can be removed), there is no limit, the limit is
  /// 1 (tapping replaces), or fewer than [max] values are selected.
  static bool canSelect<T>(Set<T> selected, T value, {int? max}) =>
      max == null ||
      max == 1 ||
      selected.contains(value) ||
      selected.length < max;

  /// Whether adding every one of [values] keeps the selection within [max].
  static bool canSelectAll<T>(Set<T> selected, Iterable<T> values, {int? max}) {
    if (max == null) return true;
    var count = selected.length;
    for (final value in values) {
      if (!selected.contains(value) && ++count > max) return false;
    }
    return true;
  }

  /// [selected] with all [values] added, or all removed when [allSelected].
  static Set<T> toggleAll<T>(
    Set<T> selected,
    Iterable<T> values, {
    required bool allSelected,
  }) {
    final next = {...selected};
    if (allSelected) {
      next.removeAll(values);
    } else {
      next.addAll(values);
    }
    return next;
  }

  /// Whether every one of [values] is in [selected]. False when [values] is
  /// empty, so "Select all" shows on an empty list.
  static bool containsAll<T>(Set<T> selected, Iterable<T> values) {
    var hasValues = false;
    for (final value in values) {
      if (!selected.contains(value)) return false;
      hasValues = true;
    }
    return hasValues;
  }

  /// The values of [selected] in the order they appear in [order].
  static List<T> ordered<T>(Iterable<T> order, Set<T> selected) => [
    for (final value in order)
      if (selected.contains(value)) value,
  ];
}
