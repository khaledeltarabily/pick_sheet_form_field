import 'package:flutter_test/flutter_test.dart';
import 'package:pick_sheet_form_field/pick_sheet_form_field.dart';

void main() {
  late PickSheetController<String> controller;
  late int notifications;

  setUp(() {
    controller = PickSheetController(initialValue: ['a']);
    notifications = 0;
    controller.addListener(() => notifications++);
  });

  tearDown(() => controller.dispose());

  test('update notifies only on a real change', () {
    controller.update(['a']);
    expect(notifications, 0);

    controller.update(['a', 'b'], source: PickSheetChangeSource.user);
    expect(notifications, 1);
    expect(controller.value, ['a', 'b']);
    expect(controller.lastChangeSource, PickSheetChangeSource.user);
  });

  test('value setter is an external change', () {
    controller.update(['b'], source: PickSheetChangeSource.user);
    controller.value = ['c'];
    expect(controller.lastChangeSource, PickSheetChangeSource.external);
  });

  test('remove and clear', () {
    controller.update(['a', 'b']);
    controller.remove('a');
    expect(controller.value, ['b']);
    controller.remove('missing');
    expect(notifications, 2);
    controller.clear();
    expect(controller.value, isEmpty);
  });

  test('reset restores the initial value; resetTo replaces it', () {
    controller.update(['b']);
    controller.reset();
    expect(controller.value, ['a']);

    controller.resetTo(['c']);
    controller.update(['d']);
    controller.reset();
    expect(controller.value, ['c']);
  });

  test('value is unmodifiable', () {
    expect(() => controller.value.add('x'), throwsUnsupportedError);
  });
}
