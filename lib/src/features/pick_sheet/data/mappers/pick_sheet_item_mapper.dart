import 'package:flutter/widgets.dart';

import '../models/pick_sheet_item.dart';

/// Maps the host app's values to [PickSheetItem]s.
abstract final class PickSheetItemMapper {
  /// One item per value, in the same order.
  static List<PickSheetItem<V>> fromValues<V>(
    Iterable<V> values, {
    required String Function(V value) label,
    String? Function(V value)? subtitle,
    IconData? icon,
  }) => [
    for (final value in values)
      PickSheetItem<V>(
        value: value,
        label: label(value),
        subtitle: subtitle?.call(value),
        icon: icon,
      ),
  ];
}
