import 'package:flutter/widgets.dart';

import '../../domain/entities/pick_sheet_option.dart';
import '../mappers/pick_sheet_item_mapper.dart';

/// One option of a pick sheet.
///
/// Items are matched by [value] with `==`, so `T` must override `==` and
/// `hashCode` (for example by extending `Equatable`), the same requirement as
/// `DropdownButtonFormField`.
@immutable
class PickSheetItem<T> implements PickSheetOption<T> {
  /// Creates an item.
  const PickSheetItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });

  /// The value returned when this item is selected.
  @override
  final T value;

  /// The item's text, also shown on its chip in the field.
  @override
  final String label;

  /// An optional second line under [label]. Search matches it too.
  @override
  final String? subtitle;

  /// An optional icon shown before [label] in the sheet. No icon box is shown
  /// when it is `null`.
  final IconData? icon;

  /// The text the sheet's search matches against.
  @override
  String get searchText => subtitle == null ? label : '$label\n$subtitle';

  /// Builds one item per value, in the same order.
  ///
  /// ```dart
  /// PickSheetItem.listOf(cities, label: (city) => city.name, icon: Icons.place)
  /// ```
  static List<PickSheetItem<V>> listOf<V>(
    Iterable<V> values, {
    required String Function(V value) label,
    String? Function(V value)? subtitle,
    IconData? icon,
  }) => PickSheetItemMapper.fromValues(
    values,
    label: label,
    subtitle: subtitle,
    icon: icon,
  );
}
