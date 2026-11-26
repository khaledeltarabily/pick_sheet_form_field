import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pick_sheet_form_field/src/core/theme/pick_sheet_theme.dart';
import 'package:pick_sheet_form_field/src/core/theme/resolved_pick_sheet_theme.dart';
import 'package:pick_sheet_form_field/src/features/pick_sheet/presentation/sheet/confirm_button.dart';

void main() {
  final appTheme = ThemeData(
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.green),
      errorStyle: TextStyle(color: Colors.brown),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.yellow,
      dragHandleColor: Colors.cyan,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(backgroundColor: Colors.orange),
    ),
  );

  const pickSheet = PickSheetTheme(
    accentColor: Colors.red,
    labelColor: Colors.pink,
    surfaceColor: Colors.grey,
    errorColor: Colors.purple,
    dragHandleColor: Colors.teal,
  );

  test('values left out come from the app theme', () {
    final theme = ResolvedPickSheetTheme.from(appTheme);

    expect(theme.label, Colors.green);
    expect(theme.floatingLabel, Colors.green);
    expect(theme.error, Colors.brown);
    expect(theme.surface, Colors.yellow);
    expect(theme.dragHandle, Colors.cyan);
    expect(theme.accent, appTheme.colorScheme.primary);
  });

  test('values set in PickSheetTheme win', () {
    final theme = ResolvedPickSheetTheme.from(
      appTheme.copyWith(extensions: [pickSheet]),
    );

    expect(theme.accent, Colors.red);
    expect(theme.label, Colors.pink);
    expect(theme.floatingLabel, Colors.pink);
    expect(theme.error, Colors.purple);
    expect(theme.surface, Colors.grey);
    expect(theme.dragHandle, Colors.teal);
  });

  Color? buttonColor(WidgetTester tester, Finder button) => tester
      .widget<Material>(
        find.descendant(of: button, matching: find.byType(Material)),
      )
      .color;

  Future<void> pumpButtons(WidgetTester tester, ThemeData theme) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Column(
            children: [
              ConfirmButton(label: 'Confirm', onPressed: () {}),
              FilledButton(
                key: const Key('app'),
                onPressed: () {},
                child: const Text('App'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final pickButton = find.descendant(
    of: find.byType(ConfirmButton),
    matching: find.byType(FilledButton),
  );

  testWidgets('the sheet button follows the app button theme', (tester) async {
    await pumpButtons(tester, appTheme);

    expect(buttonColor(tester, pickButton), Colors.orange);
  });

  testWidgets('PickSheetTheme does not change the app widgets', (tester) async {
    await pumpButtons(tester, appTheme.copyWith(extensions: [pickSheet]));

    expect(buttonColor(tester, pickButton), Colors.red);
    expect(buttonColor(tester, find.byKey(const Key('app'))), Colors.orange);
  });
}
