import 'package:flutter/material.dart';

import '../../../../core/theme/pick_sheet_theme.dart';
import '../../../../core/l10n/resolved_pick_sheet_strings.dart';
import '../controllers/pick_sheet_list_controller.dart';
import '../../../../core/utils/haptics.dart';
import 'filter_tab.dart';

/// The "All / Selected" tabs and the "Select all / Clear all" button.
class SelectionToolbar<T> extends StatefulWidget {
  /// Creates the toolbar.
  const SelectionToolbar({
    super.key,
    required this.controller,
    required this.strings,
  });

  /// The sheet's state.
  final PickSheetListController<T> controller;

  /// The resolved texts.
  final ResolvedPickSheetStrings strings;

  @override
  State<SelectionToolbar<T>> createState() => _SelectionToolbarState<T>();
}

class _SelectionToolbarState<T> extends State<SelectionToolbar<T>> {
  late Listenable _listenable = _merge(widget.controller);

  static Listenable _merge(PickSheetListController<Object?> controller) =>
      Listenable.merge([
        controller.selection,
        controller.showSelectedOnly,
        controller.allVisibleSelected,
        controller.visibleItems,
      ]);

  @override
  void didUpdateWidget(covariant SelectionToolbar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _listenable = _merge(widget.controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = PickSheetTheme.of(context);
    final controller = widget.controller;
    final strings = widget.strings;

    return ListenableBuilder(
      listenable: _listenable,
      builder: (context, _) {
        final showSelectedOnly = controller.showSelectedOnly.value;
        final allVisibleSelected = controller.allVisibleSelected.value;
        final canToggle =
            controller.visibleItems.value.isNotEmpty &&
            (allVisibleSelected || controller.canSelectAllVisible);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: LayoutBuilder(
            builder: (context, constraints) => Row(
              children: [
                // The tabs scroll when long counts, long translations or a
                // large text size don't fit next to the button.
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterTab(
                          label: strings.allWithCount(controller.items.length),
                          isActive: !showSelectedOnly,
                          onTap: () => controller.setShowSelectedOnly(false),
                        ),
                        const SizedBox(width: 8),
                        FilterTab(
                          label: strings.selectedWithCount(
                            controller.selection.value.length,
                          ),
                          isActive: showSelectedOnly,
                          onTap: () => controller.setShowSelectedOnly(true),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // At most half the row, so the tabs always keep some room.
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth / 2,
                  ),
                  child: TextButton(
                    onPressed: canToggle
                        ? () {
                            Haptics.selection(enabled: theme.enableHaptics);
                            controller.toggleVisible();
                          }
                        : null,
                    style: TextButton.styleFrom(
                      // `null` leaves the color to the app's TextButtonTheme.
                      foregroundColor: Theme.of(
                        context,
                      ).extension<PickSheetTheme>()?.accentColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      allVisibleSelected ? strings.clearAll : strings.selectAll,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
