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

  group('sheet with little vertical room', () {
    // Physical size and bottom safe area in logical pixels, at 3x.
    void screen(WidgetTester tester, Size size, {double safeBottom = 0}) {
      tester.view.physicalSize = size * 3;
      tester.view.devicePixelRatio = 3;
      tester.view.padding = FakeViewPadding(bottom: safeBottom * 3);
      tester.view.viewPadding = FakeViewPadding(bottom: safeBottom * 3);
      addTearDown(tester.view.reset);
    }

    void keyboard(WidgetTester tester, double height) =>
        tester.view.viewInsets = FakeViewPadding(bottom: height * 3);

    Future<void> openSheet(
      WidgetTester tester, {
      int items = 20,
      ValueChanged<List<int>>? onChanged,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PickSheetFormField<int>(
              items: _items(items),
              labelText: 'Cities',
              searchEnabled: true,
              onChanged: onChanged,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(PickSheetFormField<int>));
      await tester.pumpAndSettle();
    }

    ScrollPosition sheetScroll(WidgetTester tester) =>
        Scrollable.of(tester.element(find.text('Confirm'))).position;

    testWidgets('does not scroll when it fits', (tester) async {
      screen(tester, const Size(402, 874), safeBottom: 34);
      await openSheet(tester);
      expect(sheetScroll(tester).maxScrollExtent, 0);

      keyboard(tester, 335);
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(sheetScroll(tester).maxScrollExtent, 0);
    });

    testWidgets('scrolls in landscape with the keyboard up', (tester) async {
      screen(tester, const Size(874, 402), safeBottom: 21);
      List<int>? changed;
      await openSheet(tester, onChanged: (v) => changed = v);

      await tester.tap(find.byType(TextField));
      keyboard(tester, 209);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(sheetScroll(tester).maxScrollExtent, greaterThan(0));
      // The search field keeps focus while the layout changes.
      expect(
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<EditableText>(),
        isNotNull,
      );

      // The list and the confirm button are below the keyboard until the
      // sheet is scrolled: drag it up by the header.
      expect(tester.getCenter(find.text('City 0')).dy, greaterThan(193));
      final sheetIcon = find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(Icon),
      );
      await tester.drag(sheetIcon.first, const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(tester.getCenter(find.text('City 0')).dy, lessThan(193));
      await tester.tap(find.text('City 0'));
      await tester.pump();
      await tester.ensureVisible(find.text('Confirm (1)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm (1)'));
      await tester.pumpAndSettle();
      expect(changed, [0]);
    });

    testWidgets('no-results state fits a small phone with the keyboard up', (
      tester,
    ) async {
      screen(tester, const Size(375, 667));
      await openSheet(tester);
      await tester.enterText(find.byType(TextField), 'zzz');
      keyboard(tester, 260);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('No results found'), findsOneWidget);
    });
  });
}
