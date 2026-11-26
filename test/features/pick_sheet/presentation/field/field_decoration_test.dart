import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pick_sheet_form_field/src/core/theme/pick_sheet_theme.dart';
import 'package:pick_sheet_form_field/src/features/pick_sheet/presentation/field/field_decoration.dart';

void main() {
  const appBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: Colors.green),
  );

  Future<InputDecoration> build(
    WidgetTester tester, {
    PickSheetTheme? pickSheet,
    InputDecorationTheme app = const InputDecorationTheme(),
    InputDecoration? base,
  }) async {
    late InputDecoration result;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(inputDecorationTheme: app, extensions: [?pickSheet]),
        home: Builder(
          builder: (context) {
            result = buildFieldDecoration(
              context: context,
              theme: PickSheetTheme.of(context),
              base: base,
              labelText: 'City',
              errorText: null,
              enabled: true,
              focused: false,
            );
            return const SizedBox();
          },
        ),
      ),
    );
    // The theme animates when a test pumps a second app.
    await tester.pumpAndSettle();
    return result;
  }

  Color color(InputBorder? border) => border!.borderSide.color;

  testWidgets('uses the ColorScheme when nothing else is set', (tester) async {
    final decoration = await build(tester);
    final scheme = ThemeData().colorScheme;

    expect(color(decoration.enabledBorder), scheme.outline);
    expect(color(decoration.focusedBorder), scheme.primary);
    expect(color(decoration.errorBorder), scheme.error);
  });

  testWidgets('uses the borders of the app theme', (tester) async {
    final decoration = await build(
      tester,
      app: const InputDecorationTheme(
        enabledBorder: appBorder,
        focusedBorder: appBorder,
      ),
    );

    expect(decoration.enabledBorder, appBorder);
    expect(decoration.focusedBorder, appBorder);
  });

  testWidgets('keeps the app shape for the states it leaves out', (
    tester,
  ) async {
    final decoration = await build(
      tester,
      app: const InputDecorationTheme(border: appBorder),
    );

    final focused = decoration.focusedBorder! as OutlineInputBorder;
    expect(focused.borderRadius, appBorder.borderRadius);
    expect(focused.borderSide.color, ThemeData().colorScheme.primary);
    expect(focused.borderSide.width, 2);
  });

  testWidgets('a PickSheetTheme color wins and keeps the app shape', (
    tester,
  ) async {
    final decoration = await build(
      tester,
      pickSheet: const PickSheetTheme(borderColor: Colors.red),
      app: const InputDecorationTheme(enabledBorder: appBorder),
    );

    final enabled = decoration.enabledBorder! as OutlineInputBorder;
    expect(enabled.borderRadius, appBorder.borderRadius);
    expect(enabled.borderSide.color, Colors.red);
  });

  testWidgets("the field's decoration wins over both themes", (tester) async {
    const own = UnderlineInputBorder();
    final decoration = await build(
      tester,
      pickSheet: const PickSheetTheme(borderColor: Colors.red),
      app: const InputDecorationTheme(enabledBorder: appBorder),
      base: const InputDecoration(enabledBorder: own),
    );

    expect(decoration.enabledBorder, own);
  });
}
