import 'package:flutter/material.dart';

import '../../../../core/theme/pick_sheet_theme.dart';
import '../../../../core/theme/resolved_pick_sheet_theme.dart';
import '../../data/models/pick_sheet_item.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/widgets/icon_badge.dart';
import 'selection_check.dart';

/// One checkable row of the sheet.
class PickSheetListTile<T> extends StatelessWidget {
  /// Creates a row.
  const PickSheetListTile({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    this.enabled = true,
    this.entranceIndex,
  });

  /// Whether the row can be tapped. A row is disabled when the selection
  /// limit is reached and it isn't selected.
  final bool enabled;

  /// The item shown.
  final PickSheetItem<T> item;

  /// Whether the item is selected.
  final bool isSelected;

  /// Called when tapped.
  final VoidCallback onTap;

  /// When set, the row slides in, delayed by its position. `null` shows it
  /// at once.
  final int? entranceIndex;

  @override
  Widget build(BuildContext context) {
    final theme = PickSheetTheme.of(context);
    final tile = _buildTile(theme);
    final index = entranceIndex;
    if (index == null) return tile;

    final direction = Directionality.of(context) == TextDirection.rtl
        ? -1.0
        : 1.0;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 200 + index * 50),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(30 * (1 - value) * direction, 0),
          child: child,
        ),
      ),
      child: tile,
    );
  }

  Widget _buildTile(ResolvedPickSheetTheme theme) {
    final icon = item.icon;
    final subtitle = item.subtitle;

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled
            ? () {
                Haptics.selection(enabled: theme.enableHaptics);
                onTap();
              }
            : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: enabled ? 1 : 0.4,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.accent.withValues(alpha: 0.08)
                  : theme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? theme.accent.withValues(alpha: 0.3)
                    : theme.subtitle.withValues(alpha: 0.1),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  IconBadge(
                    icon: icon,
                    color: theme.accent,
                    onColor: theme.onAccent,
                    filled: isSelected,
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected ? theme.accent : theme.title,
                          height: 1.3,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(fontSize: 12, color: theme.subtitle),
                        ),
                      ],
                    ],
                  ),
                ),
                SelectionCheck(isSelected: isSelected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
