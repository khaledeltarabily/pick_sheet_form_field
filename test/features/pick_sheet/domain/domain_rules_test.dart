import 'package:flutter_test/flutter_test.dart';
import 'package:pick_sheet_form_field/src/features/pick_sheet/domain/entities/pick_sheet_status.dart';
import 'package:pick_sheet_form_field/src/features/pick_sheet/domain/services/selection_rules.dart';
import 'package:pick_sheet_form_field/src/features/pick_sheet/domain/usecases/field_readiness.dart';
import 'package:pick_sheet_form_field/src/features/pick_sheet/domain/usecases/resolve_selection.dart';
import 'package:pick_sheet_form_field/src/features/pick_sheet/domain/value_objects/search_index.dart';

void main() {
  group('SelectionRules', () {
    test('toggle adds then removes a value, without changing the input', () {
      final initial = {'a'};
      final added = SelectionRules.toggle(initial, 'b');
      expect(added, {'a', 'b'});
      expect(initial, {'a'});
      expect(SelectionRules.toggle(added, 'a'), {'b'});
    });

    test('toggleAll selects all, or removes all when allSelected', () {
      expect(SelectionRules.toggleAll({'a'}, ['b', 'c'], allSelected: false), {
        'a',
        'b',
        'c',
      });
      expect(
        SelectionRules.toggleAll(
          {'a', 'b', 'c'},
          ['b', 'c'],
          allSelected: true,
        ),
        {'a'},
      );
    });

    test('containsAll is false for no values', () {
      expect(SelectionRules.containsAll({'a'}, const <String>[]), isFalse);
      expect(SelectionRules.containsAll({'a', 'b'}, ['a', 'b']), isTrue);
      expect(SelectionRules.containsAll({'a'}, ['a', 'b']), isFalse);
    });

    test('toggle ignores additions past max, but still removes', () {
      expect(SelectionRules.toggle({'a', 'b'}, 'c', max: 2), {'a', 'b'});
      expect(SelectionRules.toggle({'a', 'b'}, 'a', max: 2), {'b'});
      expect(SelectionRules.toggle({'a'}, 'b', max: 2), {'a', 'b'});
    });

    test('toggle with max 1 replaces the selection', () {
      expect(SelectionRules.toggle({'a'}, 'b', max: 1), {'b'});
      expect(SelectionRules.toggle({'a'}, 'a', max: 1), <String>{});
    });

    test('canSelect blocks only unselected values at the limit', () {
      expect(SelectionRules.canSelect({'a', 'b'}, 'c', max: 2), isFalse);
      expect(SelectionRules.canSelect({'a', 'b'}, 'a', max: 2), isTrue);
      expect(SelectionRules.canSelect({'a'}, 'b', max: 1), isTrue);
      expect(SelectionRules.canSelect({'a', 'b'}, 'c'), isTrue);
    });

    test('canSelectAll counts only values not yet selected', () {
      expect(SelectionRules.canSelectAll({'a'}, ['a', 'b'], max: 2), isTrue);
      expect(SelectionRules.canSelectAll({'a'}, ['b', 'c'], max: 2), isFalse);
      expect(SelectionRules.canSelectAll({'a'}, ['b', 'c']), isTrue);
    });

    test('ordered follows the given order', () {
      expect(SelectionRules.ordered(['a', 'b', 'c'], {'c', 'a'}), ['a', 'c']);
    });
  });

  group('SearchIndex', () {
    final index = SearchIndex(['Cairo\nEgypt', 'Giza']);

    test('matches case-insensitively, including the subtitle', () {
      expect(index.matches(0, SearchIndex.normalize(' EGY ')), isTrue);
      expect(index.matches(1, SearchIndex.normalize('egy')), isFalse);
    });

    test('an empty query matches everything', () {
      expect(index.matches(1, SearchIndex.normalize('  ')), isTrue);
    });
  });

  group('ResolveSelection', () {
    test('splits values and follows the items order', () {
      final result = const ResolveSelection()(['c', 'x', 'a'], ['a', 'b', 'c']);
      expect(result.resolved, ['a', 'c']);
      expect(result.unresolved, ['x']);
      expect(result.hasUnresolved, isTrue);
    });
  });

  group('FieldReadiness.isWaitingForItems', () {
    bool waiting(
      PickSheetStatus status, {
      bool hasItems = false,
      bool unresolved = false,
    }) => const FieldReadiness().isWaitingForItems(
      status: status,
      hasItems: hasItems,
      hasUnresolved: unresolved,
    );

    test('waits while loading', () {
      expect(waiting(PickSheetStatus.loading, hasItems: true), isTrue);
    });

    test('waits when ready with no items and unresolved values', () {
      expect(waiting(PickSheetStatus.ready, unresolved: true), isTrue);
    });

    test('does not wait once items arrived, or with nothing to resolve', () {
      expect(
        waiting(PickSheetStatus.ready, hasItems: true, unresolved: true),
        isFalse,
      );
      expect(waiting(PickSheetStatus.ready), isFalse);
      expect(waiting(PickSheetStatus.failure, unresolved: true), isFalse);
      expect(waiting(PickSheetStatus.offline, unresolved: true), isFalse);
    });
  });
  group('FieldReadiness.canNormalizeSelection', () {
    const readiness = FieldReadiness();

    test('only once ready with items', () {
      expect(
        readiness.canNormalizeSelection(
          status: PickSheetStatus.ready,
          hasItems: true,
        ),
        isTrue,
      );
      expect(
        readiness.canNormalizeSelection(
          status: PickSheetStatus.ready,
          hasItems: false,
        ),
        isFalse,
      );
      expect(
        readiness.canNormalizeSelection(
          status: PickSheetStatus.loading,
          hasItems: true,
        ),
        isFalse,
      );
    });
  });
}
