import '../entities/pick_sheet_status.dart';

/// Decides when a field waits for its items and when its selection can be
/// normalized to them.
final class FieldReadiness {
  /// Creates the use case.
  const FieldReadiness();

  /// Whether the field shows its loading placeholder: while [status] is
  /// loading, or while it is ready but has no items yet and some selected
  /// values are waiting for them.
  bool isWaitingForItems({
    required PickSheetStatus status,
    required bool hasItems,
    required bool hasUnresolved,
  }) =>
      status == PickSheetStatus.loading ||
      (status == PickSheetStatus.ready && !hasItems && hasUnresolved);

  /// Whether the items have arrived, so the selection can be normalized to
  /// them: values with no matching item are dropped and the rest follow the
  /// items order.
  bool canNormalizeSelection({
    required PickSheetStatus status,
    required bool hasItems,
  }) => status == PickSheetStatus.ready && hasItems;
}
