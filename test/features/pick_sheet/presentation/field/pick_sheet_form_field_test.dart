import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pick_sheet_form_field/pick_sheet_form_field.dart';
import 'package:pick_sheet_form_field/src/features/pick_sheet/presentation/field/default_loading_field.dart';
import 'package:pick_sheet_form_field/src/features/pick_sheet/presentation/field/selected_chip.dart';

const _cities = [
  PickSheetItem(value: 'cairo', label: 'Cairo'),
  PickSheetItem(value: 'giza', label: 'Giza'),
  PickSheetItem(value: 'alex', label: 'Alexandria'),
];

/// The field's outlined box. Tapping its label text would hit the label's
/// edge once it floats above the border.
final _field = find.byType(InputDecorator);

Widget _app(Widget field, {GlobalKey<FormState>? formKey}) => MaterialApp(
  home: Scaffold(
    body: Form(key: formKey, child: field),
  ),
);

void main() {
  testWidgets('shows chips in the items order', (tester) async {
    await tester.pumpWidget(
      _app(
        PickSheetFormField<String>(
          items: _cities,
          labelText: 'Cities',
          initialValue: const ['alex', 'cairo'],
        ),
      ),
    );

    final chips = tester.widgetList<SelectedChip>(find.byType(SelectedChip));
    expect(chips.map((chip) => chip.label), ['Cairo', 'Alexandria']);
  });

  testWidgets('waits for items instead of showing empty chips', (tester) async {
    final changes = <List<String>>[];
    Widget field(List<PickSheetItem<String>> items) => _app(
      PickSheetFormField<String>(
        items: items,
        labelText: 'Cities',
        initialValue: const ['giza'],
        onChanged: changes.add,
      ),
    );

    await tester.pumpWidget(field(const []));
    expect(find.byType(DefaultLoadingField), findsOneWidget);
    expect(find.byType(SelectedChip), findsNothing);

    await tester.pumpWidget(field(_cities));
    expect(find.byType(DefaultLoadingField), findsNothing);
    expect(find.text('Giza'), findsOneWidget);
    expect(changes, isEmpty);
  });

  testWidgets('drops values with no matching item, without onChanged', (
    tester,
  ) async {
    final key = GlobalKey<FormFieldState<List<String>>>();
    final changes = <List<String>>[];
    await tester.pumpWidget(
      _app(
        PickSheetFormField<String>(
          key: key,
          items: _cities,
          labelText: 'Cities',
          initialValue: const ['cairo', 'deleted'],
          onChanged: changes.add,
        ),
      ),
    );

    expect(key.currentState!.value, ['cairo']);
    expect(find.byType(SelectedChip), findsOneWidget);
    expect(changes, isEmpty);
  });

  testWidgets('shows the loading placeholder while loading', (tester) async {
    await tester.pumpWidget(
      _app(
        PickSheetFormField<String>(
          items: _cities,
          labelText: 'Cities',
          status: PickSheetStatus.loading,
        ),
      ),
    );
    expect(find.byType(DefaultLoadingField), findsOneWidget);
  });

  testWidgets('a new initialValue does not call onChanged', (tester) async {
    final changes = <List<String>>[];
    Widget field(List<String> initial) => _app(
      PickSheetFormField<String>(
        items: _cities,
        labelText: 'Cities',
        initialValue: initial,
        onChanged: changes.add,
      ),
    );

    await tester.pumpWidget(field(const ['cairo']));
    await tester.pumpWidget(field(const ['giza']));
    expect(find.text('Giza'), findsOneWidget);
    expect(find.text('Cairo'), findsNothing);
    expect(changes, isEmpty);
  });

  testWidgets('removing a chip calls onChanged; reset restores', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    final changes = <List<String>>[];
    await tester.pumpWidget(
      _app(
        PickSheetFormField<String>(
          items: _cities,
          labelText: 'Cities',
          initialValue: const ['cairo', 'giza'],
          onChanged: changes.add,
        ),
        formKey: formKey,
      ),
    );

    await tester.tap(find.bySemanticsLabel('Remove Cairo'));
    await tester.pump();
    expect(changes, [
      ['giza'],
    ]);
    expect(find.text('Cairo'), findsNothing);

    formKey.currentState!.reset();
    await tester.pump();
    expect(find.text('Cairo'), findsOneWidget);
  });

  testWidgets('validates like a form field', (tester) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      _app(
        PickSheetFormField<String>(
          items: _cities,
          labelText: 'Cities',
          validator: (value) => value!.isEmpty ? 'Required' : null,
        ),
        formKey: formKey,
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);
  });

  testWidgets('the sheet returns the selection in the items order', (
    tester,
  ) async {
    final changes = <List<String>>[];
    await tester.pumpWidget(
      _app(
        PickSheetFormField<String>(
          items: _cities,
          labelText: 'Cities',
          initialValue: const ['alex'],
          onChanged: changes.add,
        ),
      ),
    );

    await tester.tap(_field);
    await tester.pumpAndSettle();
    expect(find.text('Select one or more'), findsOneWidget);

    await tester.tap(find.text('Cairo').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm (2)'));
    await tester.pumpAndSettle();

    expect(changes, [
      ['cairo', 'alex'],
    ]);
  });

  testWidgets('uses the config strings in the field and the sheet', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        PickSheetFormField<String>(
          items: _cities,
          labelText: 'Cities',
          config: PickSheetConfig(
            strings: PickSheetStrings(
              sheetDescription: 'From config',
              confirmWithCount: (n) => 'OK $n',
            ),
          ),
        ),
      ),
    );

    await tester.tap(_field);
    await tester.pumpAndSettle();
    expect(find.text('From config'), findsOneWidget);

    await tester.tap(find.text('Giza'));
    await tester.pumpAndSettle();
    expect(find.text('OK 1'), findsOneWidget);
  });

  testWidgets('texts missing from the config fall back to English', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        PickSheetFormField<String>(
          items: _cities,
          labelText: 'Cities',
          config: const PickSheetConfig(
            strings: PickSheetStrings(confirm: 'تأكيد'),
          ),
        ),
      ),
    );

    await tester.tap(_field);
    await tester.pumpAndSettle();
    expect(find.text('تأكيد'), findsOneWidget);
    expect(find.text('Select all'), findsOneWidget);
  });

  testWidgets('uses the loadingBuilder from the config', (tester) async {
    await tester.pumpWidget(
      _app(
        PickSheetFormField<String>(
          items: const [],
          labelText: 'Cities',
          status: PickSheetStatus.loading,
          config: PickSheetConfig(
            loadingBuilder: (context) => const Text('Skeleton'),
          ),
        ),
      ),
    );

    expect(find.text('Skeleton'), findsOneWidget);
    expect(find.byType(DefaultLoadingField), findsNothing);
  });

  testWidgets('showPickSheet uses its config, emptyBuilder included', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showPickSheet<String>(
                context: context,
                items: const [],
                title: 'Cities',
                config: PickSheetConfig(
                  strings: const PickSheetStrings(confirm: 'Done'),
                  emptyBuilder: (context) => const Text('Nothing here'),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Nothing here'), findsOneWidget);
  });

  testWidgets('maxSelections blocks picks past the limit', (tester) async {
    final changes = <List<String>>[];
    await tester.pumpWidget(
      _app(
        PickSheetFormField<String>(
          items: _cities,
          labelText: 'Cities',
          maxSelections: 2,
          onChanged: changes.add,
        ),
      ),
    );

    await tester.tap(_field);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cairo'));
    await tester.tap(find.text('Giza'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alexandria'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm (2)'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Select all'))
          .onPressed,
      isNull,
    );

    await tester.tap(find.text('Confirm (2)'));
    await tester.pumpAndSettle();
    expect(changes.single, ['cairo', 'giza']);
  });

  testWidgets('maxSelections: 1 replaces the previous pick', (tester) async {
    final changes = <List<String>>[];
    await tester.pumpWidget(
      _app(
        PickSheetFormField<String>(
          items: _cities,
          labelText: 'Cities',
          maxSelections: 1,
          onChanged: changes.add,
        ),
      ),
    );

    await tester.tap(_field);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cairo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alexandria'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm (1)'));
    await tester.pumpAndSettle();
    expect(changes.single, ['alex']);
  });
}
