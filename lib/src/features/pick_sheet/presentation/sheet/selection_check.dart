import 'package:flutter/material.dart';

import '../../../../core/theme/pick_sheet_theme.dart';

/// The round check mark at the end of a row.
class SelectionCheck extends StatelessWidget {
  /// Creates a check mark.
  const SelectionCheck({super.key, required this.isSelected});

  /// Whether to show it checked.
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = PickSheetTheme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isSelected
            ? theme.accent
            : theme.subtitle.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? theme.accent
              : theme.subtitle.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: isSelected
          ? Icon(Icons.check_rounded, color: theme.onAccent, size: 14)
          : null,
    );
  }
}
