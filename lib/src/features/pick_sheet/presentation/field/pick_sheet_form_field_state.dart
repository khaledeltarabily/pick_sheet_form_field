import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../domain/entities/resolved_selection.dart';
import '../../domain/usecases/field_readiness.dart';
import '../../domain/usecases/resolve_selection.dart';
import '../controllers/pick_sheet_controller.dart';
import '../sheet/show_pick_sheet.dart';
import 'pick_sheet_form_field.dart';

/// State of a [PickSheetFormField]. Use it through a `GlobalKey` to call
/// `validate()`, `save()` or `reset()` on one field.
///
/// The [controller] owns the selection; this state keeps the form value in
/// sync with it. Updates are synchronous, so no change can be missed.
class PickSheetFormFieldState<T> extends FormFieldState<List<T>> {
  static const _resolveSelection = ResolveSelection();
  static const _readiness = FieldReadiness();

  PickSheetController<T>? _ownController;
  late List<T> _itemValues;
  late Map<T, String> _labels;
  late ResolvedSelection<T> _resolution;
  bool _hasFocus = false;

  /// Focus of the field, so it works with a keyboard and screen readers.
  final FocusNode focusNode = FocusNode(debugLabel: 'PickSheetFormField');

  PickSheetFormField<T> get _field => widget as PickSheetFormField<T>;

  /// The controller in use: the field's own, or the one passed to it.
  PickSheetController<T> get controller => _field.controller ?? _ownController!;

  /// Selected values with a matching item, in the items order. These are the
  /// chips shown in the field.
  List<T> get shownSelection => _resolution.resolved;

  /// Whether the field is focused.
  bool get hasFocus => _hasFocus;

  /// Whether the field shows its loading placeholder.
  bool get isWaiting => _readiness.isWaitingForItems(
    status: _field.status,
    hasItems: _itemValues.isNotEmpty,
    hasUnresolved: _resolution.hasUnresolved,
  );

  /// Whether the user can open the sheet and remove chips.
  bool get isInteractive =>
      _field.enabled && _field.status.isReady && !isWaiting;

  /// The chip label of [value].
  String labelOf(T value) => _labels[value] ?? '';

  @override
  void initState() {
    super.initState();
    if (_field.controller == null) {
      _ownController = PickSheetController<T>(
        initialValue: widget.initialValue ?? <T>[],
      );
    }
    _indexItems();
    _resolve();
    _normalizeSelection();
    setValue(controller.value);
    controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant PickSheetFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != _field.controller) {
      _swapController(oldWidget.controller);
    }
    if (!identical(oldWidget.items, _field.items)) _indexItems();
    if (_field.controller == null &&
        !listEquals(oldWidget.initialValue, widget.initialValue)) {
      controller.resetTo(widget.initialValue ?? <T>[]);
    }
    _resolve();
    _normalizeSelection();
  }

  @override
  void reset() {
    super.reset();
    controller.reset();
    // The initial value may hold values already dropped once the items
    // loaded; drop them again so the form never sees unmatched values.
    _resolve();
    _normalizeSelection();
    setValue(controller.value);
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    _ownController?.dispose();
    focusNode.dispose();
    super.dispose();
  }

  /// Updates the focused look when focus changes.
  void handleFocusChange(bool hasFocus) {
    if (hasFocus != _hasFocus) setState(() => _hasFocus = hasFocus);
  }

  /// Opens the sheet and applies the confirmed selection.
  Future<void> openSheet() async {
    final field = _field;
    final result = await showPickSheet<T>(
      context: context,
      items: field.items,
      title: field.sheetTitle ?? field.labelText,
      description: field.sheetDescription,
      icon: field.sheetIcon,
      initialSelected: shownSelection,
      searchEnabled: field.searchEnabled,
      maxSelections: field.maxSelections,
      config: field.config,
    );
    if (result == null || !mounted) return;
    controller.update(result, source: PickSheetChangeSource.user);
  }

  /// Deselects [value], as a user change.
  void removeValue(T value) =>
      controller.remove(value, source: PickSheetChangeSource.user);

  /// Deselects everything, as a user change.
  void clearAll() => controller.clear(source: PickSheetChangeSource.user);

  void _onControllerChanged() {
    _resolve();
    final value = controller.value;
    if (controller.lastChangeSource == PickSheetChangeSource.user) {
      // Marks the field as interacted, so it auto-validates.
      didChange(value);
      _field.onChanged?.call(value);
    } else {
      setState(() => setValue(value));
      if (hasError) validate();
    }
  }

  void _swapController(PickSheetController<T>? oldController) {
    (oldController ?? _ownController)?.removeListener(_onControllerChanged);
    if (_field.controller != null) {
      _ownController?.dispose();
      _ownController = null;
    } else {
      _ownController ??= PickSheetController<T>(
        initialValue: oldController?.value ?? <T>[],
      );
    }
    controller.addListener(_onControllerChanged);
    setValue(controller.value);
  }

  void _indexItems() {
    final items = _field.items;
    _itemValues = [for (final item in items) item.value];
    _labels = {for (final item in items) item.value: item.label};
  }

  void _resolve() =>
      _resolution = _resolveSelection(controller.value, _itemValues);

  /// Once the items have arrived, drops values with no matching item and
  /// puts the rest in the items order, without calling `onChanged`.
  void _normalizeSelection() {
    final canNormalize = _readiness.canNormalizeSelection(
      status: _field.status,
      hasItems: _itemValues.isNotEmpty,
    );
    if (!canNormalize || listEquals(_resolution.resolved, controller.value)) {
      return;
    }
    assert(() {
      if (_resolution.hasUnresolved) {
        debugPrint(
          'PickSheetFormField: dropped ${_resolution.unresolved.length} '
          'selected value(s) with no matching item.',
        );
      }
      return true;
    }());
    controller.update(_resolution.resolved);
    _resolve();
  }
}
