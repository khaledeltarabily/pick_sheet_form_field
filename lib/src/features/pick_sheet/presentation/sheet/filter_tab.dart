import 'package:flutter/material.dart';

import '../../../../core/theme/pick_sheet_theme.dart';
import '../../../../core/utils/haptics.dart';

/// One of the toolbar's "All / Selected" tabs.
class FilterTab extends StatelessWidget {
  /// Creates a tab.
  const FilterTab({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  /// The tab's text.
  final String label;

  /// Whether this tab is the current filter.
  final bool isActive;

  /// Called when tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = PickSheetTheme.of(context);

    return Semantics(
      button: true,
      selected: isActive,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Haptics.selection(enabled: theme.enableHaptics);
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? theme.accent
                : theme.accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? theme.onAccent : theme.accent,
            ),
          ),
        ),
      ),
    );
  }
}
