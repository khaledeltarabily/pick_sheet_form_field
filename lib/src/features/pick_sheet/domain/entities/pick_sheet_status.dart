/// Loading state of the items of a pick sheet field, usually mapped from the
/// status of the bloc or provider that loads them.
enum PickSheetStatus {
  /// The items are loading: the field shows its loading placeholder.
  loading,

  /// The items are available and the field can be opened.
  ready,

  /// The items couldn't load because the device is offline.
  offline,

  /// The items failed to load.
  failure;

  /// Whether the field can be opened in this status.
  bool get isReady => this == ready;
}
