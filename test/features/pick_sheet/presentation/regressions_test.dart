import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pick_sheet_form_field/pick_sheet_form_field.dart';

List<PickSheetItem<int>> _items(int n) =>
    PickSheetItem.listOf(List.generate(n, (i) => i), label: (i) => 'City $i');

void main() {
  testWidgets('Form.reset does not restore values dropped after loading', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    List<int>? saved;
    Widget build(PickSheetStatus status, List<PickSheetItem<int>> items) =>
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: PickSheetFormField<int>(
                items: items,
                labelText: 'Cities',
                status: status,
                initialValue: const [5, 99, -1],
                onSaved: (v) => saved = v,
              ),
            ),
          ),
        );

    await tester.pumpWidget(build(PickSheetStatus.loading, const []));
    await tester.pumpWidget(build(PickSheetStatus.ready, _items(100)));
    final state = tester.state<PickSheetFormFieldState<int>>(
      find.byType(PickSheetFormField<int>),
    );
    expect(state.value, [5, 99]);

    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pump();
    expect(state.value, [99]);

    formKey.currentState!.reset();
    await tester.pump();
    expect(state.value, [5, 99]);
    expect(state.controller.value, [5, 99]);
    formKey.currentState!.save();
    expect(saved, [5, 99]);
  });

  for (final scale in [1.0, 1.3, 2.0, 3.0]) {
    testWidgets('toolbar fits a 390pt screen at text scale $scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: Scaffold(
            body: PickSheetFormField<int>(
              items: _items(100000),
              labelText: 'Cities',
            ),
          ),
        ),
      );
      await tester.tap(find.byType(PickSheetFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select all'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Clear all'), findsOneWidget);
      // Both tabs are still reachable.
      await tester.tap(find.text('Selected (100000)'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  // While the iOS keyboard closes, its bottom inset can dip below zero for a
  // frame. The sheet used it as padding as-is, and Padding asserts on a
  // negative value (seen in the on-device stress test after "Select all").
  testWidgets('sheet tolerates a negative keyboard inset', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(viewInsets: const EdgeInsets.only(bottom: -3)),
          child: child!,
        ),
        home: Scaffold(
          body: PickSheetFormField<int>(items: _items(20), labelText: 'Cities'),
        ),
      ),
    );
    await tester.tap(find.byType(PickSheetFormField<int>));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('All (20)'), findsOneWidget);
  });
}
