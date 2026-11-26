// Aggressive widget-level stress tests: huge lists, rapid input, many
// rebuilds, open/close churn. Prints wall-clock timings for each scenario.
//
// Run: flutter test test/performance --reporter expanded
@Tags(['performance'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart'
    show LeakTesting;
import 'package:pick_sheet_form_field/pick_sheet_form_field.dart';

List<PickSheetItem<int>> _items(int n, {bool icons = true}) =>
    PickSheetItem.listOf(
      List.generate(n, (i) => i),
      label: (i) => 'City number $i',
      subtitle: (i) => i.isEven ? 'Region ${i % 97}' : null,
      icon: icons ? Icons.location_city_rounded : null,
    );

final _report = <String>[];

Future<T> _time<T>(
  String name,
  Future<T> Function() body, {
  double? budgetMs,
}) async {
  final sw = Stopwatch()..start();
  final result = await body();
  final ms = sw.elapsedMicroseconds / 1000;
  _report.add('${name.padRight(58)} ${ms.toStringAsFixed(1).padLeft(9)} ms');
  if (budgetMs != null) {
    expect(ms, lessThan(budgetMs), reason: '$name took $ms ms');
  }
  return result;
}

class _Host extends StatefulWidget {
  const _Host({
    required this.items,
    this.controller,
    this.maxSelections,
    this.onChanged,
    this.recreateItemsOnBuild = false,
  });

  final List<PickSheetItem<int>> items;
  final PickSheetController<int>? controller;
  final int? maxSelections;
  final ValueChanged<List<int>>? onChanged;
  final bool recreateItemsOnBuild;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  int builds = 0;
  void rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    builds++;
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              PickSheetFormField<int>(
                items: widget.recreateItemsOnBuild
                    ? [...widget.items]
                    : widget.items,
                labelText: 'Cities',
                controller: widget.controller,
                searchEnabled: true,
                maxSelections: widget.maxSelections,
                onChanged: widget.onChanged,
              ),
              Text('builds $builds'),
            ],
          ),
        ),
      ),
    );
  }
}

/// A row label inside the open sheet (chips in the field repeat labels).
Finder _row(String index) => find.descendant(
  of: find.byType(BottomSheet),
  matching: find.text('City number $index'),
);

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.byType(PickSheetFormField<int>));
  await tester.pumpAndSettle();
}

Future<void> _search(WidgetTester tester, String q) async {
  await tester.enterText(find.byType(TextField), q);
  await tester.pump(const Duration(milliseconds: 350)); // debounce
  await tester.pump();
}

void main() {
  // Wall-clock budgets: leak tracking's bookkeeping would skew them.
  // test/memory covers leaks under the same kind of churn.
  LeakTesting.settings = LeakTesting.settings.withIgnoredAll();

  tearDownAll(() {
    // ignore: avoid_print
    print(
      '\n==== WIDGET STRESS (wall clock, debug/JIT) ====\n'
      '${_report.join('\n')}\n',
    );
  });

  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(
      1170,
      2532,
    );
    binding.platformDispatcher.views.first.devicePixelRatio = 3;
  });
  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.views.first.resetPhysicalSize();
    binding.platformDispatcher.views.first.resetDevicePixelRatio();
  });

  for (final n in [1000, 100000]) {
    testWidgets('n=$n: open, fling, search, select all, confirm, remove', (
      tester,
    ) async {
      final items = _items(n);
      List<int>? changed;
      await tester.pumpWidget(
        _Host(items: items, onChanged: (v) => changed = v),
      );

      await _time(
        '[$n] open sheet (tap -> settled)',
        () => _open(tester),
        budgetMs: 3000,
      );
      expect(find.text('All ($n)'), findsOneWidget);

      await _time('[$n] 15 flings down', () async {
        for (var i = 0; i < 15; i++) {
          await tester.fling(
            find.byType(ListView).last,
            const Offset(0, -2000),
            8000,
          );
          await tester.pumpAndSettle();
        }
      }, budgetMs: 8000);
      expect(find.textContaining('City number'), findsWidgets);

      await _time(
        '[$n] search "region 5" (debounced)',
        () => _search(tester, 'region 5'),
        budgetMs: 2000,
      );
      expect(find.text('City number 0'), findsNothing);
      expect(find.textContaining('Region 5'), findsWidgets);

      await _time('[$n] 30 rapid keystrokes (no debounce fire)', () async {
        for (var i = 0; i < 30; i++) {
          await tester.enterText(find.byType(TextField), 'city ${i % 10}');
          await tester.pump(const Duration(milliseconds: 50));
        }
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pump();
      }, budgetMs: 4000);

      await _time(
        '[$n] search no-match -> empty state',
        () => _search(tester, 'zzzz'),
        budgetMs: 2000,
      );
      expect(find.text('No results found'), findsOneWidget);

      await _time(
        '[$n] clear search',
        () => _search(tester, ''),
        budgetMs: 2000,
      );
      expect(find.text('City number 0'), findsOneWidget);

      await _time('[$n] select all', () async {
        await tester.tap(find.text('Select all'));
        await tester.pumpAndSettle();
      }, budgetMs: 2000);
      expect(find.text('Selected ($n)'), findsOneWidget);
      expect(find.text('Confirm ($n)'), findsOneWidget);

      await _time('[$n] 24 row toggles with all selected', () async {
        for (var i = 0; i < 24; i++) {
          await tester.tap(_row('${i % 4}'));
          await tester.pump();
        }
        await tester.pumpAndSettle();
      }, budgetMs: 4000);
      expect(find.text('Selected ($n)'), findsOneWidget);

      await _time('[$n] "Selected" tab + toggle (refilter)', () async {
        await tester.ensureVisible(find.text('Selected ($n)'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Selected ($n)'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('City number 1'));
        await tester.pumpAndSettle();
      }, budgetMs: 2000);
      expect(find.text('Selected (${n - 1})'), findsOneWidget);
      expect(find.text('City number 1'), findsNothing);

      await _time('[$n] confirm -> field shows chips', () async {
        await tester.tap(find.text('Confirm (${n - 1})'));
        await tester.pumpAndSettle();
      }, budgetMs: 2000);
      expect(changed!.length, n - 1);
      expect(changed!.first, 0);
      expect(changed!.contains(1), isFalse);

      await _time('[$n] remove 10 chips one by one', () async {
        for (var i = 0; i < 10; i++) {
          await tester.tap(find.byIcon(Icons.close_rounded).first);
          await tester.pump();
        }
        await tester.pumpAndSettle();
      }, budgetMs: 3000);
      expect(changed!.length, n - 11);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('parent rebuilds 300x with recreated 100k items list', (
    tester,
  ) async {
    final items = _items(100000);
    final controller = PickSheetController<int>(
      initialValue: [for (var i = 0; i < 5000; i++) i * 3],
    );
    await tester.pumpWidget(
      _Host(items: items, controller: controller, recreateItemsOnBuild: true),
    );
    final state = tester.state<_HostState>(find.byType(_Host));
    await _time(
      '300 parent rebuilds (100k items recreated, 5k selected)',
      () async {
        for (var i = 0; i < 300; i++) {
          state.rebuild();
          await tester.pump();
        }
      },
      budgetMs: 30000,
    );
    expect(controller.value.length, 5000);
    controller.dispose();
  });

  testWidgets('parent rebuilds 300x with same 100k items list', (tester) async {
    final items = _items(100000);
    final controller = PickSheetController<int>(
      initialValue: [for (var i = 0; i < 5000; i++) i * 3],
    );
    await tester.pumpWidget(_Host(items: items, controller: controller));
    final state = tester.state<_HostState>(find.byType(_Host));
    await _time('300 parent rebuilds (same 100k list, 5k selected)', () async {
      for (var i = 0; i < 300; i++) {
        state.rebuild();
        await tester.pump();
      }
    }, budgetMs: 30000);
    controller.dispose();
  });

  testWidgets('5000 external controller updates while mounted', (tester) async {
    final items = _items(10000);
    final controller = PickSheetController<int>();
    var userChanges = 0;
    await tester.pumpWidget(
      _Host(
        items: items,
        controller: controller,
        onChanged: (_) => userChanges++,
      ),
    );
    await _time('5000 controller.update + pump (10k items)', () async {
      for (var i = 0; i < 5000; i++) {
        controller.value = [i % 10000, (i * 7) % 10000];
        if (i % 10 == 0) await tester.pump();
      }
      await tester.pump();
    }, budgetMs: 20000);
    expect(userChanges, 0, reason: 'external changes must not call onChanged');
    controller.dispose();
  });

  testWidgets('open/close churn: 40 cycles, mixed dismiss and confirm', (
    tester,
  ) async {
    final items = _items(20000);
    final values = <List<int>>[];
    await tester.pumpWidget(_Host(items: items, onChanged: values.add));
    await _time('40 open/close cycles (20k items)', () async {
      for (var i = 0; i < 40; i++) {
        await _open(tester);
        await tester.tap(_row('${i % 3}'));
        await tester.pump();
        if (i.isEven) {
          await tester.tap(find.textContaining('Confirm'));
        } else {
          await tester.tapAt(const Offset(10, 10)); // barrier: dismiss
        }
        await tester.pumpAndSettle();
      }
    }, budgetMs: 30000);
    expect(values.length, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('single-select (max 1): 200 rapid taps', (tester) async {
    await tester.pumpWidget(_Host(items: _items(5000), maxSelections: 1));
    await _open(tester);
    await _time('200 taps single-select', () async {
      for (var i = 0; i < 200; i++) {
        await tester.tap(_row('${i % 5}'));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.pumpAndSettle();
    }, budgetMs: 10000);
    expect(find.text('Selected (1)'), findsOneWidget);
  });

  testWidgets('max 3: extra taps on disabled rows are ignored', (tester) async {
    await tester.pumpWidget(_Host(items: _items(5000), maxSelections: 3));
    await _open(tester);
    for (var i = 0; i < 5; i++) {
      await tester.tap(_row('$i'), warnIfMissed: false);
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.text('Selected (3)'), findsOneWidget);
    // Select all over the limit must be disabled.
    await tester.tap(find.text('Select all'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Selected (3)'), findsOneWidget);
  });

  testWidgets('async load: status loading -> ready with 100k items', (
    tester,
  ) async {
    Widget build(PickSheetStatus status, List<PickSheetItem<int>> items) =>
        MaterialApp(
          home: Scaffold(
            body: PickSheetFormField<int>(
              items: items,
              labelText: 'Cities',
              status: status,
              initialValue: const [99999, 5, -1, 42],
            ),
          ),
        );
    await tester.pumpWidget(build(PickSheetStatus.loading, const []));
    expect(find.byType(InputDecorator), findsNothing);
    final items = _items(100000);
    await _time('loading -> ready (normalize 4 values over 100k)', () async {
      await tester.pumpWidget(build(PickSheetStatus.ready, items));
      await tester.pumpAndSettle();
    }, budgetMs: 2000);
    final state = tester.state<PickSheetFormFieldState<int>>(
      find.byType(PickSheetFormField<int>),
    );
    expect(state.value, [5, 42, 99999]); // -1 dropped, items order
  });

  testWidgets('Form reset/validate with 50k selected', (tester) async {
    final formKey = GlobalKey<FormState>();
    final items = _items(50000);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: PickSheetFormField<int>(
              items: items,
              labelText: 'Cities',
              initialValue: [for (var i = 0; i < 50000; i++) i],
              validator: (v) => v!.length > 10 ? 'Too many' : null,
            ),
          ),
        ),
      ),
    );
    await _time('validate + reset x50 (50k selected)', () async {
      for (var i = 0; i < 50; i++) {
        expect(formKey.currentState!.validate(), isFalse);
        formKey.currentState!.reset();
        await tester.pump();
      }
    }, budgetMs: 10000);
    expect(find.text('Too many'), findsNothing);
  });
}
