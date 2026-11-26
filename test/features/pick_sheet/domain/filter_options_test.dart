import 'package:flutter_test/flutter_test.dart';
import 'package:pick_sheet_form_field/src/features/pick_sheet/domain/entities/pick_sheet_option.dart';
import 'package:pick_sheet_form_field/src/features/pick_sheet/domain/usecases/filter_options.dart';
import 'package:pick_sheet_form_field/src/features/pick_sheet/domain/value_objects/search_index.dart';

final class _Option implements PickSheetOption<int> {
  const _Option(this.value, this.label, [this.subtitle]);

  @override
  final int value;

  @override
  final String label;

  @override
  final String? subtitle;

  @override
  String get searchText => subtitle == null ? label : '$label\n$subtitle';
}

void main() {
  const filter = FilterOptions();
  const options = [
    _Option(1, 'Cairo', 'Capital'),
    _Option(2, 'Giza'),
    _Option(3, 'Alexandria'),
  ];
  final index = SearchIndex(options.map((option) => option.searchText));

  List<_Option> run({
    String query = '',
    bool selectedOnly = false,
    Set<int> selected = const {},
  }) => filter<int, _Option>(
    options: options,
    index: index,
    selected: selected,
    query: query,
    selectedOnly: selectedOnly,
  );

  test('returns the same list instance when nothing filters', () {
    expect(identical(run(selected: {1}), options), isTrue);
  });

  test('matches label and subtitle with a normalized query', () {
    expect(run(query: SearchIndex.normalize(' GI ')), [options[1]]);
    expect(run(query: 'capital'), [options[0]]);
  });

  test('keeps only selected options when selectedOnly', () {
    expect(run(selectedOnly: true, selected: {1, 3}), [options[0], options[2]]);
    expect(run(selectedOnly: true, selected: {1, 3}, query: 'alex'), [
      options[2],
    ]);
  });
}
