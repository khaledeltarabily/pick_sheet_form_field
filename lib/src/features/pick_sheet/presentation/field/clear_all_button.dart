import 'package:flutter/material.dart';

import '../../../../core/theme/pick_sheet_theme.dart';
import '../../../../core/utils/haptics.dart';

/// The small round button that deselects everything.
class ClearAllButton extends StatelessWidget {
  /// Creates the button.
  const ClearAllButton({
    super.key,
    required this.tooltip,
    required this.onPressed,
  });

  /// Tooltip and screen reader label.
  final String tooltip;

  /// Called when pressed.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = PickSheetTheme.of(context);

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Haptics.impact(enabled: theme.enableHaptics);
            onPressed();
          },
          // Padding widens the tap area beyond the 22px circle.
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(6, 4, 2, 4),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: theme.border,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, size: 14, color: theme.label),
            ),
          ),
        ),
      ),
    );
  }
}
