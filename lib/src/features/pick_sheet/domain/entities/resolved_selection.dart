/// A selection split into values that have a matching item and values that
/// don't, for example because the items haven't loaded yet.
final class ResolvedSelection<T> {
  /// Creates a resolved selection.
  const ResolvedSelection({required this.resolved, required this.unresolved});

  /// Selected values with a matching item, in the items order.
  final List<T> resolved;

  /// Selected values with no matching item.
  final List<T> unresolved;

  /// Whether some selected values have no matching item.
  bool get hasUnresolved => unresolved.isNotEmpty;
}
