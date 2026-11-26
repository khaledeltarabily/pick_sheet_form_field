// Memory tests: checks that the sheet and the field release what they
// allocate, and that repeated use doesn't grow the Dart heap.
//
// Undisposed notifiers, focus nodes and controllers are caught for every
// widget test by `test/flutter_test_config.dart`. These tests cover what
// that can't see: objects kept alive through a listener or a route after
// they've left the tree.
//
// The GC-based tests need the VM service and are skipped without it:
//   flutter test test/memory --enable-vmservice --reporter expanded
@Tags(['performance'])
library;

import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker/leak_tracker.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart'
    show LeakTesting;
import 'package:pick_sheet_form_field/pick_sheet_form_field.dart';
import 'package:vm_service/vm_service.dart' show VmService;
import 'package:vm_service/vm_service_io.dart';

List<PickSheetItem<int>> _items(int n) => PickSheetItem.listOf(
  List.generate(n, (i) => i),
  label: (i) => 'City number $i',
  subtitle: (i) => i.isEven ? 'Region ${i % 97}' : null,
);

Widget _app(Widget field) => MaterialApp(
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(16), child: field),
  ),
);

final _sheetView = find.byWidgetPredicate(
  (widget) => widget.runtimeType.toString().startsWith('PickSheetView<'),
);

void _useTallView(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1170, 2532)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// A VM service connection, or `null` without `--enable-vmservice`.
Future<VmService?> _connect(WidgetTester tester) async {
  final info = await tester.runAsync(Service.getInfo);
  final uri = info?.serverWebSocketUri;
  if (uri == null) return null;
  final vm = await tester.runAsync(() => vmServiceConnectUri(uri.toString()));
  addTearDown(() => tester.runAsync(vm!.dispose));
  return vm;
}

/// Runs full GCs until the heap stops shrinking, and returns the Dart heap
/// usage in MB. [forceGC] alone doesn't reliably clear weak references to
/// old-space objects, so each round also collects through the VM service.
///
/// One round isn't always enough: right after many sheets close, the first
/// collection can leave dozens of them in the heap though nothing references
/// them any more (their retaining path is empty). The next round frees them.
/// A single reading then looks hundreds of MB too high, which failed CI once
/// at +402 MB.
Future<double> _gc(WidgetTester tester, VmService vm) async {
  final isolateId = Service.getIsolateId(Isolate.current)!;
  double? previous;
  for (var round = 0; round < 5; round++) {
    await tester.pump();
    await tester.runAsync(() async {
      await forceGC(fullGcCycles: 3);
      await vm.getAllocationProfile(isolateId, gc: true);
    });
    final usage = await tester.runAsync(() => vm.getMemoryUsage(isolateId));
    final mb = usage!.heapUsage! / (1 << 20);
    if (previous != null && previous - mb < 1) return math.min(previous, mb);
    previous = mb;
  }
  return previous!;
}

/// Opens the sheet, searches, toggles "Select all", then confirms on even
/// cycles and dismisses on odd ones. Returns the sheet's state.
Future<State> _openAndClose(WidgetTester tester, {required int cycle}) async {
  // Tap the field's top-left: its center can land on a chip's remove button.
  final field = find.byType(PickSheetFormField<int>);
  await tester.tapAt(tester.getTopLeft(field) + const Offset(24, 24));
  await tester.pumpAndSettle();
  final sheet = tester.state(_sheetView);

  await tester.enterText(find.byType(TextField), 'region ${cycle % 9}');
  await tester.pump(const Duration(milliseconds: 350)); // debounce
  final selectAll = find.text('Select all');
  await tester.tap(
    selectAll.evaluate().isEmpty ? find.text('Clear all') : selectAll,
  );
  await tester.pump();

  if (cycle.isEven) {
    await tester.tap(find.textContaining('Confirm'));
  } else {
    await tester.tapAt(const Offset(10, 10)); // barrier: dismiss
  }
  await tester.pumpAndSettle();
  expect(_sheetView, findsNothing);
  return sheet;
}

void main() {
  testWidgets('closed sheets are garbage-collected', (tester) async {
    final vm = await _connect(tester);
    if (vm == null) return markTestSkipped('needs --enable-vmservice');
    _useTallView(tester);
    await tester.pumpWidget(
      _app(
        PickSheetFormField<int>(
          items: _items(5000),
          labelText: 'Cities',
          searchEnabled: true,
        ),
      ),
    );

    final sheets = [
      for (var i = 0; i < 12; i++)
        WeakReference(await _openAndClose(tester, cycle: i)),
    ];
    await _gc(tester, vm);

    // Flutter's semantics tree may hold the most recently closed route until
    // its next update; that's bounded. Any more means each sheet leaks.
    final alive = sheets.where((ref) => ref.target != null).length;
    expect(alive, lessThanOrEqualTo(1), reason: '$alive of 12 sheets leaked');
  });

  testWidgets('a removed field is collected though its controller lives on', (
    tester,
  ) async {
    final vm = await _connect(tester);
    if (vm == null) return markTestSkipped('needs --enable-vmservice');
    final controller = PickSheetController<int>(initialValue: [1, 2]);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _app(
        PickSheetFormField<int>(
          items: _items(1000),
          labelText: 'Cities',
          controller: controller,
        ),
      ),
    );
    final field = WeakReference(
      tester.state<PickSheetFormFieldState<int>>(
        find.byType(PickSheetFormField<int>),
      ),
    );

    await tester.pumpWidget(_app(const SizedBox()));
    await _gc(tester, vm);

    // ignore: invalid_use_of_protected_member
    expect(controller.hasListeners, isFalse);
    expect(field.target, isNull, reason: 'the controller keeps the field');
  });

  testWidgets('swapping controllers releases the old ones', (tester) async {
    final controllers = [
      for (var i = 0; i < 20; i++) PickSheetController<int>(initialValue: [i]),
    ];
    addTearDown(() {
      for (final c in controllers) {
        c.dispose();
      }
    });
    final items = _items(100);

    // External -> own -> external ..., so the field's own controller is
    // created and disposed too.
    for (var i = 0; i < controllers.length; i++) {
      await tester.pumpWidget(
        _app(
          PickSheetFormField<int>(
            items: items,
            labelText: 'Cities',
            controller: i.isEven ? controllers[i] : null,
          ),
        ),
      );
    }
    await tester.pumpWidget(_app(const SizedBox()));

    for (final c in controllers) {
      // ignore: invalid_use_of_protected_member
      expect(c.hasListeners, isFalse);
    }
  });

  testWidgets(
    '150 open/close cycles over 20k items keep the Dart heap flat',
    (tester) async {
      final vm = await _connect(tester);
      if (vm == null) return markTestSkipped('needs --enable-vmservice');
      _useTallView(tester);
      await tester.pumpWidget(
        _app(
          PickSheetFormField<int>(
            items: _items(20000),
            labelText: 'Cities',
            searchEnabled: true,
          ),
        ),
      );

      // Warm up: let fonts, caches and the first routes settle.
      for (var i = 0; i < 20; i++) {
        await _openAndClose(tester, cycle: i);
      }
      final before = await _gc(tester, vm);
      const cycles = 150;
      for (var i = 0; i < cycles; i++) {
        await _openAndClose(tester, cycle: i);
      }
      final after = await _gc(tester, vm);

      final growth = after - before;
      // ignore: avoid_print
      print(
        '\n==== MEMORY ($cycles open/close cycles, 20k items) ====\n'
        'Dart heap ${before.toStringAsFixed(1)} MB -> '
        '${after.toStringAsFixed(1)} MB '
        '(${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)} MB, '
        '${(growth * 1024 / cycles).toStringAsFixed(1)} KB/cycle); '
        'RSS ${(ProcessInfo.currentRss / (1 << 20)).toStringAsFixed(0)} MB, '
        'peak ${(ProcessInfo.maxRss / (1 << 20)).toStringAsFixed(0)} MB\n',
      );

      // A leaked sheet over 20k items keeps its search index and filtered
      // lists, over 1 MB each, so a leak per cycle would add 150+ MB.
      expect(growth, lessThan(20));
    },
    // Leak tracking adds per-object bookkeeping that would skew the numbers;
    // the tests above cover leaks.
    experimentalLeakTesting: LeakTesting.settings.withIgnoredAll(),
  );
}
