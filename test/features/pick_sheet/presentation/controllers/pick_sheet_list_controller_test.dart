import 'package:flutter_test/flutter_test.dart';
import 'package:pick_sheet_form_field/pick_sheet_form_field.dart';
import 'package:pick_sheet_form_field/src/features/pick_sheet/presentation/controllers/pick_sheet_list_controller.dart';

void main() {
  const items = [
    PickSheetItem(value: 'cairo', label: 'Cairo', subtitle: 'Egypt'),
    PickSheetItem(value: 'giza', label: 'Giza'),
    PickSheetItem(value: 'paris', label: 'Paris', subtitle: 'France'),
  ];

  late PickSheetListController<String> controller;

  setUp(() {
    controller = PickSheetListController(
      items: items,
      initialSelected: ['paris'],
    );
  });

  tearDown(() => controller.dispose());

  test('selectedValues follow the items order', () {
    controller.toggle('cairo');
    expect(controller.selectedValues, ['cairo', 'paris']);
  });

  test('toggling keeps the same visibleItems instance', () {
    final before = controller.visibleItems.value;
    controller.toggle('giza');
    expect(identical(before, controller.visibleItems.value), isTrue);
  });

  test('search matches labels and subtitles', () {
    controller.search('EGY');
    expect(controller.visibleItems.value.map((i) => i.value), ['cairo']);
    controller.search('');
    expect(controller.visibleItems.value.length, 3);
  });

  test('selected only shows selected items and follows toggles', () {
    controller.setShowSelectedOnly(true);
    expect(controller.visibleItems.value.map((i) => i.value), ['paris']);
    controller.toggle('paris');
    expect(controller.visibleItems.value, isEmpty);
  });

  test('toggleVisible selects, then clears, only the visible items', () {
    controller.search('gi'); // only Giza
    expect(controller.visibleItems.value.map((i) => i.value), ['giza']);
    expect(controller.allVisibleSelected.value, isFalse);

    controller.toggleVisible();
    expect(controller.selection.value, {'paris', 'giza'});
    expect(controller.allVisibleSelected.value, isTrue);

    controller.toggleVisible();
    expect(controller.selection.value, {'paris'});
  });
}
