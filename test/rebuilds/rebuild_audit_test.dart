// Counts which of the package's widgets rebuild for each user action, using
// the framework's `debugOnRebuildDirtyWidget` hook (the same signal DevTools'
// "Track widget rebuilds" uses).
//
// Run: flutter test test/rebuilds --reporter expanded
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pick_sheet_form_field/pick_sheet_form_field.dart';

const _watched = {
  'PickSheetFieldView',
  'InputDecorator',
  'SelectedChipsRow',
  'SelectedChip',
  'FieldTrailing',
  'CountBadge',
  'ClearAllButton',
  'StatusIndicator',
  'PickSheetView',
  'SheetHeader',
  'SheetSearchField',
  'TextField',
  'SelectionToolbar',
  'FilterTab',
  'PickSheetList',
  'ListenableSelector',
  'PickSheetListTile',
  'IconBadge',
  'SelectionCheck',
  'ConfirmButton',
};

final _report = <String>[];

/// Runs [action] and returns how many times each watched widget rebuilt.
Future<Map<String, int>> _track(
  String name,
  Future<void> Function() action,
) async {
  final counts = <String, int>{};
  debugOnRebuildDirtyWidget = (element, _) {
    final type = element.widget.runtimeType.toString().split('<').first;
    if (_watched.contains(type)) {
      counts.update(type, (c) => c + 1, ifAbsent: () => 1);
    }
  };
  try {
    await action();
  } finally {
    debugOnRebuildDirtyWidget = null;
  }
  final sorted = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  _report.add(
    '${name.padRight(46)} '
    '${sorted.isEmpty ? '(nothing)' : sorted.map((e) => '${e.key} ${e.value}').join(', ')}',
  );
  return counts;
}

List<PickSheetItem<int>> _items(int n) => PickSheetItem.listOf(
  List.generate(n, (i) => i),
  label: (i) => 'City $i',
  icon: Icons.location_city_rounded,
);

class _Host extends StatefulWidget {
  const _Host({required this.items, this.maxSelections, this.initialValue});

  final List<PickSheetItem<int>> items;
  final int? maxSelections;
  final List<int>? initialValue;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  List<int> selected = const [];

  void rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          PickSheetFormField<int>(
            items: widget.items,
            labelText: 'Cities',
            searchEnabled: true,
            maxSelections: widget.maxSelections,
            initialValue: widget.initialValue,
            onChanged: (v) => setState(() => selected = v),
          ),
          Text('Selected: ${selected.length}'),
        ],
      ),
    ),
  );
}

Finder _row(int i) => find.descendant(
  of: find.byType(BottomSheet),
  matching: find.text('City $i'),
);

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.byType(PickSheetFormField<int>));
  await tester.pumpAndSettle();
}

void main() {
  tearDownAll(() {
    // ignore: avoid_print
    print('\n===== REBUILD AUDIT =====\n${_report.join('\n')}\n');
  });

  group('sheet', () {
    testWidgets('toggle one row', (tester) async {
      await tester.pumpWidget(_Host(items: _items(50)));
      await _openSheet(tester);
      final c = await _track('sheet: toggle row 0', () async {
        await tester.tap(_row(0));
        await tester.pumpAndSettle();
      });
      expect(c['PickSheetListTile'], 1);
      expect(c['SheetHeader'], isNull);
      expect(c['SheetSearchField'], isNull);
      expect(c['PickSheetList'], isNull);
    });

    testWidgets('keyboard opens (view insets animate)', (tester) async {
      await tester.pumpWidget(_Host(items: _items(50)));
      await _openSheet(tester);
      final c = await _track(
        'sheet: keyboard opens (10 inset frames)',
        () async {
          for (var i = 1; i <= 10; i++) {
            tester.view.viewInsets = FakeViewPadding(bottom: 30.0 * i);
            await tester.pump(const Duration(milliseconds: 16));
          }
        },
      );
      addTearDown(tester.view.resetViewInsets);
      // Only the frame around the sheet depends on the insets; nothing
      // inside it should rebuild while the keyboard animates.
      expect(c, isEmpty);
    });

    testWidgets('type one character (before debounce)', (tester) async {
      await tester.pumpWidget(_Host(items: _items(50)));
      await _openSheet(tester);
      await _track('sheet: type "1" (debounce pending)', () async {
        await tester.enterText(find.byType(TextField), '1');
        await tester.pump(const Duration(milliseconds: 50));
      });
      await _track('sheet: debounced search runs', () async {
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();
      });
    });

    testWidgets('switch to Selected tab', (tester) async {
      await tester.pumpWidget(_Host(items: _items(50), initialValue: [1, 2]));
      await tester.pumpAndSettle();
      await _openSheet(tester);
      await _track('sheet: Selected tab', () async {
        await tester.tap(find.text('Selected (2)'));
        await tester.pumpAndSettle();
      });
    });

    testWidgets('select all', (tester) async {
      await tester.pumpWidget(_Host(items: _items(50)));
      await _openSheet(tester);
      await _track('sheet: select all', () async {
        await tester.tap(find.text('Select all'));
        await tester.pumpAndSettle();
      });
    });

    testWidgets('reach maxSelections', (tester) async {
      await tester.pumpWidget(_Host(items: _items(50), maxSelections: 2));
      await _openSheet(tester);
      await tester.tap(_row(0));
      await tester.pumpAndSettle();
      await _track('sheet: 2nd pick hits max (rows disable)', () async {
        await tester.tap(_row(1));
        await tester.pumpAndSettle();
      });
    });

    testWidgets('scroll list', (tester) async {
      await tester.pumpWidget(_Host(items: _items(200)));
      await _openSheet(tester);
      await _track('sheet: drag list 300px', () async {
        await tester.drag(find.byType(ListView).last, const Offset(0, -300));
        await tester.pumpAndSettle();
      });
    });
  });

  group('field', () {
    testWidgets('open sheet animation', (tester) async {
      await tester.pumpWidget(_Host(items: _items(50), initialValue: [1, 2]));
      await tester.pumpAndSettle();
      await _track('field+sheet: open sheet (whole animation)', () async {
        await _openSheet(tester);
      });
    });

    testWidgets('confirm changes', (tester) async {
      await tester.pumpWidget(_Host(items: _items(50), initialValue: [1, 2]));
      await tester.pumpAndSettle();
      await _openSheet(tester);
      await tester.tap(_row(0));
      await tester.pumpAndSettle();
      await _track('field: confirm (sheet closes, value set)', () async {
        await tester.tap(find.textContaining('Confirm'));
        await tester.pumpAndSettle();
      });
    });

    testWidgets('focus change', (tester) async {
      await tester.pumpWidget(_Host(items: _items(50), initialValue: [1, 2]));
      await tester.pumpAndSettle();
      final state = tester.state<PickSheetFormFieldState<int>>(
        find.byType(PickSheetFormField<int>),
      );
      await _track('field: gains focus', () async {
        state.focusNode.requestFocus();
        await tester.pumpAndSettle();
      });
    });

    testWidgets('remove one chip', (tester) async {
      await tester.pumpWidget(
        _Host(items: _items(50), initialValue: [1, 2, 3]),
      );
      await tester.pumpAndSettle();
      await _track('field: remove 1 of 3 chips', () async {
        await tester.tap(find.byIcon(Icons.close_rounded).first);
        await tester.pumpAndSettle();
      });
    });

    testWidgets('unrelated parent rebuild', (tester) async {
      await tester.pumpWidget(_Host(items: _items(50), initialValue: [1, 2]));
      await tester.pumpAndSettle();
      final host = tester.state<_HostState>(find.byType(_Host));
      await _track('field: parent setState, nothing changed', () async {
        host.rebuild();
        await tester.pumpAndSettle();
      });
    });
  });
}
