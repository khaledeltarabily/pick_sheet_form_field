// On-device rebuild audit: counts which of the package's widgets rebuild for
// each user action, with a real keyboard and real frames.
//
// Run from example/:
//   flutter test integration_test/rebuild_test.dart -d <device-id>
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pick_sheet_form_field_example/main.dart';

const _watched = {
  'ExamplePage',
  'PickSheetFieldView',
  'InputDecorator',
  'SelectedChipsRow',
  'SelectedChip',
  'FieldTrailing',
  'PickSheetView',
  'SheetHeader',
  'SheetSearchField',
  'SelectionToolbar',
  'FilterTab',
  'PickSheetList',
  'PickSheetListTile',
  'ConfirmButton',
};

final _report = <String>[];

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
    '${name.padRight(40)} '
    '${sorted.isEmpty ? '(nothing)' : sorted.map((e) => '${e.key} ${e.value}').join(', ')}',
  );
  return counts;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  tearDownAll(() {
    // ignore: avoid_print
    print('\n===== ON-DEVICE REBUILD AUDIT =====\n${_report.join('\n')}\n');
  });

  testWidgets('example app rebuilds', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    await _track('open sheet', () async {
      await tester.tap(find.text('Cities'));
      await tester.pumpAndSettle();
    });

    final keyboard = await _track('tap search (real keyboard opens)', () async {
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      // The keyboard animates on the platform side; let it finish.
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    });
    _report.add(
      '    keyboard inset: '
      '${tester.view.viewInsets.bottom / tester.view.devicePixelRatio}pt, '
      'PickSheetView builds: ${keyboard['PickSheetView'] ?? 0}',
    );

    await _track('toggle "Alexandria" (keyboard up)', () async {
      await tester.tap(find.text('Alexandria').last);
      await tester.pumpAndSettle();
    });

    await _track('dismiss keyboard', () async {
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    });

    await _track('confirm', () async {
      await tester.tap(find.textContaining('Confirm'));
      await tester.pumpAndSettle();
    });

    await _track('tap Validate (no change)', () async {
      await tester.tap(find.text('Validate'));
      await tester.pumpAndSettle();
    });
  });
}
