// On-device stress + frame-timing test for pick_sheet_form_field.
//
// Run on a simulator/device from example/:
//   flutter test integration_test/stress_test.dart -d <device-id>
// Frame timings are only meaningful in --profile on a real device; on the
// simulator (debug only) they're relative indicators.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pick_sheet_form_field/pick_sheet_form_field.dart';

final _binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
final _log = <String>[];
final _issues = <String>[];
final _issueDetails = <String>[];

/// Every Flutter error reported during the current test, with its stack.
/// [WidgetTester.takeException] returns only the exception, so
/// [_drainErrors] looks the details up here.
final _errorDetails = <FlutterErrorDetails>[];

/// Like [testWidgets], but records each Flutter error's details first.
void _testWidgets(String description, WidgetTesterCallback callback) =>
    testWidgets(description, (tester) async {
      _errorDetails.clear();
      // The binding installs its own handler for each test and restores the
      // previous one afterwards, so this wrapper only lives for this test.
      final handler = FlutterError.onError;
      FlutterError.onError = (details) {
        _errorDetails.add(details);
        handler?.call(details);
      };
      await callback(tester);
    });

List<PickSheetItem<int>> _items(int n) => PickSheetItem.listOf(
  List.generate(n, (i) => i),
  label: (i) => 'City number $i',
  subtitle: (i) => i.isEven ? 'Region ${i % 97}' : null,
  icon: Icons.location_city_rounded,
);

Finder _row(String i) => find.descendant(
  of: find.byType(BottomSheet),
  matching: find.text('City number $i'),
);

/// Runs [action] with live frames, recording frame timings under [key].
Future<void> _perf(
  WidgetTester tester,
  String key,
  Future<void> Function() action,
) async {
  final sw = Stopwatch()..start();
  await _binding.watchPerformance(action, reportKey: key);
  final data = _binding.reportData![key] as Map<String, dynamic>;
  String f(String k) => (data[k] as num?)?.toStringAsFixed(1) ?? '-';
  _log.add(
    '${key.padRight(44)} wall ${sw.elapsedMilliseconds.toString().padLeft(6)}ms '
    '| frames ${data['frame_count']} '
    '| build avg ${f('average_frame_build_time_millis')} '
    'p90 ${f('90th_percentile_frame_build_time_millis')} '
    'worst ${f('worst_frame_build_time_millis')} '
    '| raster avg ${f('average_frame_rasterizer_time_millis')} '
    'worst ${f('worst_frame_rasterizer_time_millis')} '
    '| missed build ${data['missed_frame_build_budget_count']} '
    'raster ${data['missed_frame_rasterizer_budget_count']}',
  );
}

void _drainErrors(WidgetTester tester, String where) {
  Object? e;
  while ((e = tester.takeException()) != null) {
    final summary = '$where: ${'$e'.split('\n').first}';
    _issues.add(summary);
    final details = _errorDetails
        .where((d) => identical(d.exception, e))
        .lastOrNull;
    if (details != null) {
      final stack = '${details.stack ?? ''}'.trimRight().split('\n');
      _issueDetails.add(
        [
          '## $summary',
          if (details.context != null) 'Context: ${details.context}',
          '$e',
          'Stack:',
          ...stack.take(40),
          if (stack.length > 40) '... (${stack.length - 40} more frames)',
        ].join('\n'),
      );
    }
  }
}

class _App extends StatelessWidget {
  const _App({
    required this.items,
    this.maxSelections,
    this.formKey,
    this.onChanged,
    this.status = PickSheetStatus.ready,
    this.initialValue,
    this.textScale = 1.0,
  });

  final List<PickSheetItem<int>> items;
  final int? maxSelections;
  final GlobalKey<FormState>? formKey;
  final ValueChanged<List<int>>? onChanged;
  final PickSheetStatus status;
  final List<int>? initialValue;
  final double textScale;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.indigo),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: Scaffold(
      appBar: AppBar(title: const Text('stress')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            PickSheetFormField<int>(
              items: items,
              labelText: 'Cities',
              searchEnabled: true,
              maxSelections: maxSelections,
              status: status,
              initialValue: initialValue,
              onChanged: onChanged,
              validator: (v) => v!.isEmpty ? 'Pick at least one' : null,
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  _binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  tearDownAll(() {
    // ignore: avoid_print
    print(
      '\n===== ON-DEVICE STRESS REPORT =====\n${_log.join('\n')}\n'
      '----- issues (${_issues.length}) -----\n${_issues.join('\n')}\n'
      '${_issueDetails.isEmpty ? '' : '----- issue details -----\n${_issueDetails.join('\n\n')}\n'}'
      '===================================\n',
    );
  });

  for (final n in [7, 1000, 100000]) {
    _testWidgets('n=$n full flow', (tester) async {
      final items = _items(n);
      List<int>? changed;
      await tester.pumpWidget(
        _App(items: items, onChanged: (v) => changed = v),
      );
      await tester.pumpAndSettle();

      await _perf(tester, '[$n] open sheet', () async {
        await tester.tap(find.byType(PickSheetFormField<int>));
        await tester.pumpAndSettle();
      });
      _drainErrors(tester, '[$n] open sheet');
      expect(find.text('All ($n)'), findsOneWidget);

      await _perf(tester, '[$n] 10 flings', () async {
        for (var i = 0; i < 10; i++) {
          await tester.fling(
            find.byType(ListView).last,
            const Offset(0, -1500),
            6000,
          );
          await tester.pumpAndSettle();
        }
      });
      await _perf(tester, '[$n] 10 flings back up', () async {
        for (var i = 0; i < 10; i++) {
          await tester.fling(
            find.byType(ListView).last,
            const Offset(0, 1500),
            6000,
          );
          await tester.pumpAndSettle();
        }
      });

      await _perf(tester, '[$n] type "region 5" char by char', () async {
        const q = 'region 5';
        for (var i = 1; i <= q.length; i++) {
          await tester.enterText(find.byType(TextField), q.substring(0, i));
          await tester.pump(const Duration(milliseconds: 80));
        }
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();
      });
      if (n > 7) expect(find.textContaining('Region 5'), findsWidgets);

      await _perf(tester, '[$n] clear search (x button)', () async {
        await tester.tap(find.byIcon(Icons.cancel_rounded));
        await tester.pumpAndSettle();
      });
      expect(_row('0'), findsOneWidget);
      // Dismiss keyboard.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      await _perf(tester, '[$n] select all', () async {
        await tester.tap(find.text('Select all'));
        await tester.pumpAndSettle();
      });
      _drainErrors(tester, '[$n] after select all');
      expect(find.text('Selected ($n)'), findsOneWidget);

      await _perf(tester, '[$n] 20 row taps (all selected)', () async {
        for (var i = 0; i < 20; i++) {
          await tester.tap(_row('${i % 2}'));
          await tester.pump(const Duration(milliseconds: 30));
        }
        await tester.pumpAndSettle();
      });
      expect(find.text('Selected ($n)'), findsOneWidget);

      await _perf(tester, '[$n] Selected tab + deselect 1', () async {
        await tester.ensureVisible(find.text('Selected ($n)'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Selected ($n)'));
        await tester.pumpAndSettle();
        await tester.tap(_row('1'));
        await tester.pumpAndSettle();
      });
      expect(find.text('Selected (${n - 1})'), findsOneWidget);

      await _perf(tester, '[$n] confirm', () async {
        await tester.tap(find.text('Confirm (${n - 1})'));
        await tester.pumpAndSettle();
      });
      expect(changed!.length, n - 1);

      await _perf(tester, '[$n] scroll chips row', () async {
        for (var i = 0; i < 5; i++) {
          await tester.fling(
            find.byType(ListView).last,
            const Offset(-600, 0),
            4000,
          );
          await tester.pumpAndSettle();
        }
      });

      await _perf(tester, '[$n] remove 5 chips', () async {
        for (var i = 0; i < 5; i++) {
          await tester.tap(
            find.byIcon(Icons.close_rounded).hitTestable().first,
          );
          await tester.pumpAndSettle();
        }
      });
      expect(changed!.length, n - 6);
      _drainErrors(tester, '[$n] end');
    });
  }

  _testWidgets('single-select (max 1) and max 3 limit', (tester) async {
    List<int>? changed;
    await tester.pumpWidget(
      _App(items: _items(500), maxSelections: 1, onChanged: (v) => changed = v),
    );
    await tester.tap(find.byType(PickSheetFormField<int>));
    await tester.pumpAndSettle();
    for (var i = 0; i < 4; i++) {
      await tester.tap(_row('$i'));
      await tester.pump(const Duration(milliseconds: 30));
    }
    await tester.pumpAndSettle();
    expect(find.text('Selected (1)'), findsOneWidget);
    await tester.tap(find.text('Confirm (1)'));
    await tester.pumpAndSettle();
    expect(changed, [3]);

    await tester.pumpWidget(const SizedBox()); // fresh field state
    await tester.pumpWidget(
      _App(items: _items(500), maxSelections: 3, onChanged: (v) => changed = v),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PickSheetFormField<int>));
    await tester.pumpAndSettle();
    for (var i = 0; i < 5; i++) {
      await tester.tap(_row('$i'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 30));
    }
    await tester.pumpAndSettle();
    expect(find.text('Selected (3)'), findsOneWidget);
    await tester.tap(find.text('Confirm (3)'));
    await tester.pumpAndSettle();
    expect(changed, [0, 1, 2]);
    _drainErrors(tester, 'max limits');
  });

  _testWidgets('dismiss without confirm keeps old value', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _App(items: _items(100), onChanged: (_) => calls++),
    );
    await tester.tap(find.byType(PickSheetFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(_row('0'));
    await tester.pump();
    await tester.tapAt(const Offset(195, 40)); // barrier
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(calls, 0);
  });

  _testWidgets('loading -> ready, validate, reset', (tester) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      _App(
        items: const [],
        status: PickSheetStatus.loading,
        formKey: formKey,
        initialValue: const [5, 99999, -1],
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(InputDecorator), findsNothing);
    final items = _items(100000);
    await _perf(tester, 'loading -> ready (100k)', () async {
      await tester.pumpWidget(
        _App(
          items: items,
          formKey: formKey,
          initialValue: const [5, 99999, -1],
        ),
      );
      await tester.pumpAndSettle();
    });
    final state = tester.state<PickSheetFormFieldState<int>>(
      find.byType(PickSheetFormField<int>),
    );
    expect(state.value, [5, 99999]);
    expect(formKey.currentState!.validate(), isTrue);
    await tester.tap(find.byIcon(Icons.close_rounded).first); // remove one chip
    await tester.pumpAndSettle();
    formKey.currentState!.reset();
    await tester.pumpAndSettle();
    expect(state.value, [5, 99999]);
    _drainErrors(tester, 'loading/validate/reset');
  });

  _testWidgets('open/close churn x25 with 20k items', (tester) async {
    await tester.pumpWidget(_App(items: _items(20000)));
    await _perf(tester, 'open/close churn x25 (20k)', () async {
      for (var i = 0; i < 25; i++) {
        await tester.tap(find.byType(PickSheetFormField<int>));
        await tester.pumpAndSettle();
        await tester.tap(_row('${i % 3}'));
        await tester.pump();
        await tester.tap(find.textContaining('Confirm'));
        await tester.pumpAndSettle();
      }
    });
    _drainErrors(tester, 'churn');
  });

  _testWidgets('real-font toolbar fit at 390pt and large text', (tester) async {
    for (final scale in [1.0, 1.3, 2.0]) {
      await tester.pumpWidget(_App(items: _items(100000), textScale: scale));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PickSheetFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select all'), warnIfMissed: false);
      await tester.pumpAndSettle();
      _drainErrors(tester, 'toolbar 100k all selected, textScale $scale');
      Navigator.of(tester.element(find.byType(BottomSheet))).pop();
      await tester.pumpAndSettle();
    }
  });
}
