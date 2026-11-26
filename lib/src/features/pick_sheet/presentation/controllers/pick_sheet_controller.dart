import 'package:flutter/foundation.dart';

/// What caused the latest change of a [PickSheetController].
enum PickSheetChangeSource {
  /// The user picked, removed or cleared values: the field calls `onChanged`
  /// and validates as if the user interacted with it.
  user,

  /// Code changed the selection (a new initial value, a form reset or
  /// [PickSheetController.value]): the field updates without calling
  /// `onChanged`, like Flutter's form fields.
  external,
}

/// Holds the selected values of a `PickSheetFormField`.
///
/// Pass one to control the selection from outside the field, the way a
/// `TextEditingController` controls a text field. Changes are synchronous:
/// listeners run in the same frame, with no stream or event queue.
class PickSheetController<T> extends ChangeNotifier {
  /// Creates a controller that starts with [initialValue] selected.
  PickSheetController({List<T> initialValue = const []})
    : _value = List<T>.unmodifiable(initialValue),
      _initialValue = List<T>.unmodifiable(initialValue);

  List<T> _value;
  List<T> _initialValue;
  PickSheetChangeSource _lastChangeSource = PickSheetChangeSource.external;

  /// The selected values. Unmodifiable; replace it to change the selection.
  List<T> get value => _value;

  /// Replaces the selection as an [PickSheetChangeSource.external] change.
  set value(List<T> newValue) => update(newValue);

  /// The selection that [reset] restores.
  List<T> get initialValue => _initialValue;

  /// What caused the latest change.
  PickSheetChangeSource get lastChangeSource => _lastChangeSource;

  /// Replaces the selection. Does nothing when [newValue] has the same values
  /// in the same order, so listeners only run on real changes.
  void update(
    List<T> newValue, {
    PickSheetChangeSource source = PickSheetChangeSource.external,
  }) {
    if (listEquals(newValue, _value)) return;
    _value = List<T>.unmodifiable(newValue);
    _lastChangeSource = source;
    notifyListeners();
  }

  /// Deselects [value].
  void remove(
    T value, {
    PickSheetChangeSource source = PickSheetChangeSource.external,
  }) {
    if (!_value.contains(value)) return;
    update([
      for (final selected in _value)
        if (selected != value) selected,
    ], source: source);
  }

  /// Deselects everything.
  void clear({PickSheetChangeSource source = PickSheetChangeSource.external}) =>
      update(<T>[], source: source);

  /// Restores [initialValue].
  void reset() => update(_initialValue);

  /// Sets a new [initialValue] and selects it.
  void resetTo(List<T> initialValue) {
    _initialValue = List<T>.unmodifiable(initialValue);
    update(initialValue);
  }
}
