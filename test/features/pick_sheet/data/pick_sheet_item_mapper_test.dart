import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pick_sheet_form_field/pick_sheet_form_field.dart';
import 'package:pick_sheet_form_field/src/features/pick_sheet/data/mappers/pick_sheet_item_mapper.dart';

void main() {
  test('fromValues maps every value in order', () {
    final items = PickSheetItemMapper.fromValues(
      [1, 2],
      label: (value) => 'L$value',
      subtitle: (value) => value.isEven ? 'even' : null,
      icon: Icons.place,
    );

    expect(items.map((item) => item.value), [1, 2]);
    expect(items.map((item) => item.label), ['L1', 'L2']);
    expect(items.map((item) => item.subtitle), [null, 'even']);
    expect(items.every((item) => item.icon == Icons.place), isTrue);
    expect(items.last.searchText, 'L2\neven');
  });

  test('PickSheetItem.listOf delegates to the mapper', () {
    final items = PickSheetItem.listOf(['a'], label: (value) => value);
    expect(items.single.value, 'a');
    expect(items.single.label, 'a');
  });
}
