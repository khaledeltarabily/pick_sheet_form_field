// Aggressive micro-benchmarks of the pure selection/search logic.
//
// Run: flutter test test/performance --reporter expanded
//
// Budgets are generous (flutter test runs in JIT/debug) — they catch
// complexity regressions (O(n) -> O(n^2)), not small slowdowns.
@Tags(['performance'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:pick_sheet_form_field/pick_sheet_form_field.dart';
import 'package:pick_sheet_form_field/src/features/pick_sheet/domain/services/selection_rules.dart';
import 'package:pick_sheet_form_field/src/features/pick_sheet/domain/usecases/filter_options.dart';
import 'package:pick_sheet_form_field/src/features/pick_sheet/domain/usecases/resolve_selection.dart';
import 'package:pick_sheet_form_field/src/features/pick_sheet/domain/value_objects/search_index.dart';
import 'package:pick_sheet_form_field/src/features/pick_sheet/presentation/controllers/pick_sheet_list_controller.dart';

const _sizes = [1000, 10000, 100000, 1000000];

List<PickSheetItem<int>> _items(int n) => PickSheetItem.listOf(
  List.generate(n, (i) => i),
  label: (i) => 'City number $i',
  subtitle: (i) => i.isEven ? 'Region ${i % 97}' : null,
);

/// Runs [body] [runs] times after a warm-up and returns the median in µs.
double _bench(void Function() body, {int runs = 5}) {
  body();
  final samples = <int>[];
  for (var r = 0; r < runs; r++) {
    final sw = Stopwatch()..start();
    body();
    samples.add(sw.elapsedMicroseconds);
  }
  samples.sort();
  return samples[samples.length ~/ 2].toDouble();
}

final _report = <String>[];

void _record(String name, int n, double micros, {double? budgetMs}) {
  final ms = micros / 1000;
  _report.add(
    '${name.padRight(42)} n=${n.toString().padLeft(8)}  '
    '${ms.toStringAsFixed(3).padLeft(10)} ms',
  );
  if (budgetMs != null) {
    expect(ms, lessThan(budgetMs), reason: '$name n=$n took $ms ms');
  }
}

void main() {
  tearDownAll(() {
    // ignore: avoid_print
    print('\n==== DOMAIN BENCHMARK (median) ====\n${_report.join('\n')}\n');
  });

  for (final n in _sizes) {
    group('n=$n', () {
      late List<PickSheetItem<int>> items;
      setUpAll(() => items = _items(n));

      // Linear budget: ~1µs/item is very loose for JIT; scale with n.
      double linear(double perItemUs) => n * perItemUs / 1000 + 5;

      test('SearchIndex build', () {
        final us = _bench(() => SearchIndex(items.map((e) => e.searchText)));
        _record('SearchIndex build', n, us, budgetMs: linear(2));
      });

      test('filter per keystroke (miss / hit / single char)', () {
        final index = SearchIndex(items.map((e) => e.searchText));
        const filter = FilterOptions();
        for (final q in ['zzz', 'region 5', '7']) {
          List<PickSheetItem<int>>? out;
          final us = _bench(
            () => out = filter<int, PickSheetItem<int>>(
              options: items,
              index: index,
              selected: const {},
              query: SearchIndex.normalize(q),
              selectedOnly: false,
            ),
          );
          _record(
            'filter "$q" (${out!.length} hits)',
            n,
            us,
            budgetMs: linear(1),
          );
        }
      });

      test('ResolveSelection with every value selected (reversed)', () {
        final values = [for (final i in items) i.value];
        final selected = values.reversed.toList();
        const resolve = ResolveSelection();
        late List<int> resolved;
        final us = _bench(() => resolved = resolve(selected, values).resolved);
        expect(resolved.length, n);
        expect(resolved.first, 0);
        _record('ResolveSelection all selected', n, us, budgetMs: linear(2));
      });

      test('SelectionRules.toggle on a full selection (copies set)', () {
        final full = {for (final i in items) i.value};
        final us = _bench(() => SelectionRules.toggle(full, 0));
        _record('toggle with all selected', n, us, budgetMs: linear(1));
      });

      test('PickSheetListController: open + select all + 200 toggles', () {
        late PickSheetListController<int> c;
        final open = _bench(
          () => c = PickSheetListController(items: items),
          runs: 3,
        );
        _record('controller open', n, open, budgetMs: linear(3));

        final selAll = _bench(() {
          c.toggleVisible(); // select all
          c.toggleVisible(); // clear all
        }, runs: 3);
        _record('select all + clear all', n, selAll, budgetMs: linear(4));

        c.toggleVisible(); // everything selected: worst case for toggles
        final sw = Stopwatch()..start();
        for (var i = 0; i < 200; i++) {
          c.toggle(i % 100); // each of 100 items toggled twice
        }
        final perToggle = sw.elapsedMicroseconds / 200;
        _record(
          'toggle (all selected) per op',
          n,
          perToggle,
          budgetMs: linear(1),
        );
        expect(c.selection.value.length, n); // 200 toggles = even = restored

        final search = _bench(() {
          c.search('region 9');
          c.search('');
        }, runs: 3);
        _record('search + clear search', n, search, budgetMs: linear(3));

        c.setShowSelectedOnly(true);
        final selOnlyToggle = _bench(() => c.toggle(1));
        _record(
          'toggle in "selected only" (refilter)',
          n,
          selOnlyToggle,
          budgetMs: linear(2),
        );

        final confirm = _bench(() => c.selectedValues);
        _record('selectedValues (confirm)', n, confirm, budgetMs: linear(1));
        c.dispose();
      });

      test('PickSheetController: 1000 external updates with full list', () {
        final c = PickSheetController<int>();
        final a = [for (var i = 0; i < n; i++) i];
        final b = [...a]..removeLast();
        var notifications = 0;
        c.addListener(() => notifications++);
        final sw = Stopwatch()..start();
        final rounds = n >= 1000000 ? 20 : 1000;
        for (var i = 0; i < rounds; i++) {
          c.update(i.isEven ? a : b);
        }
        _record(
          'controller.update per op',
          n,
          sw.elapsedMicroseconds / rounds,
          budgetMs: linear(1),
        );
        expect(notifications, rounds);
        c.update([...c.value]); // equal content: must not notify
        expect(notifications, rounds);
        c.dispose();
      });
    });
  }

  test('maxSelections=1 single-select: 100k rapid toggles stay at 1', () {
    final c = PickSheetListController(items: _items(1000), maxSelections: 1);
    for (var i = 0; i < 100000; i++) {
      c.toggle(i % 1000);
      expect(c.selection.value.length, 1);
    }
    c.dispose();
  });

  test('maxSelections=5: never exceeded under random toggles', () {
    final c = PickSheetListController(items: _items(500), maxSelections: 5);
    var seed = 42;
    for (var i = 0; i < 50000; i++) {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      c.toggle(seed % 500);
      expect(c.selection.value.length, lessThanOrEqualTo(5));
    }
    c.toggleVisible(); // select all must be refused over the limit
    expect(c.selection.value.length, lessThanOrEqualTo(5));
    c.dispose();
  });
}
