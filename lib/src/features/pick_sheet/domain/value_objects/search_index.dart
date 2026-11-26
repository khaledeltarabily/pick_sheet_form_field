/// Lower-cased search text of every item, computed once so filtering doesn't
/// normalize every item again on each keystroke.
final class SearchIndex {
  /// Indexes [texts], one per item, in the items order.
  SearchIndex(Iterable<String> texts)
    : _keys = List.unmodifiable(texts.map((text) => text.toLowerCase()));

  final List<String> _keys;

  /// Number of indexed items.
  int get length => _keys.length;

  /// Normalizes a raw query the same way the item texts are normalized.
  static String normalize(String query) => query.trim().toLowerCase();

  /// Whether the item at [index] matches an already [normalize]d query.
  /// An empty query matches every item.
  bool matches(int index, String normalizedQuery) =>
      normalizedQuery.isEmpty || _keys[index].contains(normalizedQuery);
}
