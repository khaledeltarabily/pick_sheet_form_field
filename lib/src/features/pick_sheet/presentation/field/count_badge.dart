import 'package:flutter/material.dart';

import '../../../../core/theme/pick_sheet_theme.dart';

/// The round badge with the number of selected values.
class CountBadge extends StatelessWidget {
  /// Creates a badge showing [count].
  const CountBadge({super.key, required this.count, required this.enabled});

  /// The number shown.
  final int count;

  /// Whether to use the accent color or the disabled color.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = PickSheetTheme.of(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: Container(
        key: ValueKey(count),
        constraints: const BoxConstraints(minWidth: 22),
        height: 22,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? theme.accent : theme.disabled,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          '$count',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: theme.onAccent,
          ),
        ),
      ),
    );
  }
}
