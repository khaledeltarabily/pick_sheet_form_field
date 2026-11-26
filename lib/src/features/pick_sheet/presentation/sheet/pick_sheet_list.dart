import 'dart:async';

import 'package:flutter/widgets.dart';

import '../controllers/pick_sheet_list_controller.dart';
import '../../data/models/pick_sheet_item.dart';
import '../../../../core/widgets/listenable_selector.dart';
import 'pick_sheet_list_tile.dart';
import 'sheet_empty_state.dart';

/// The sheet's scrollable list of items.
///
/// The list rebuilds only when the filter result changes. Toggling an item
/// rebuilds just that row.
class PickSheetList<T> extends StatefulWidget {
  /// Creates the list.
  const PickSheetList({
    super.key,
    required this.controller,
    required this.emptyText,
    this.emptyBuilder,
  });

  /// The sheet's state.
  final PickSheetListController<T> controller;

  /// Shown when no item matches.
  final String emptyText;

  /// Replaces the default empty state when set.
  final WidgetBuilder? emptyBuilder;

  @override
  State<PickSheetList<T>> createState() => _PickSheetListState<T>();
}

class _PickSheetListState<T> extends State<PickSheetList<T>> {
  /// Only rows built while the sheet opens slide in. Rows built later (by
  /// scrolling or filtering) appear at once, so scrolling stays smooth.
  static const _entranceDuration = Duration(milliseconds: 800);
  static const _animatedRows = 10;

  bool _animateEntrance = true;
  Timer? _entranceTimer;

  @override
  void initState() {
    super.initState();
    _entranceTimer = Timer(_entranceDuration, _endEntrance);
  }

  @override
  void dispose() {
    _entranceTimer?.cancel();
    super.dispose();
  }

  // No setState: rows already built keep their animation; only rows built
  // from now on skip it.
  void _endEntrance() => _animateEntrance = false;

  bool _onScrollStart(ScrollStartNotification notification) {
    _endEntrance();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return ValueListenableBuilder<List<PickSheetItem<T>>>(
      valueListenable: controller.visibleItems,
      builder: (context, items, _) {
        if (items.isEmpty) {
          return widget.emptyBuilder?.call(context) ??
              SheetEmptyState(text: widget.emptyText);
        }

        return NotificationListener<ScrollStartNotification>(
          onNotification: _onScrollStart,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final entranceIndex = _animateEntrance && index < _animatedRows
                  ? index
                  : null;

              return ListenableSelector<({bool selected, bool enabled})>(
                listenable: controller.selection,
                selector: () => (
                  selected: controller.isSelected(item.value),
                  enabled: controller.canSelect(item.value),
                ),
                builder: (context, state) => PickSheetListTile<T>(
                  item: item,
                  isSelected: state.selected,
                  enabled: state.enabled,
                  entranceIndex: entranceIndex,
                  onTap: () => controller.toggle(item.value),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
