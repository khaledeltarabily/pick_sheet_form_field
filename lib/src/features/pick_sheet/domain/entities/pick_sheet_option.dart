/// One selectable option, as the domain rules see it: a value plus the texts
/// that describe and find it.
///
/// Pure Dart on purpose. The data layer's `PickSheetItem` implements it and
/// adds what only the UI needs (its icon).
abstract interface class PickSheetOption<T> {
  /// The value returned when this option is selected. Compared with `==`.
  T get value;

  /// The option's text.
  String get label;

  /// An optional second line under [label].
  String? get subtitle;

  /// The text search matches against.
  String get searchText;
}
