import 'package:flutter/material.dart';

import '../../../../core/theme/pick_sheet_theme.dart';
import '../../../../core/utils/haptics.dart';

/// A selected value inside the field, with an optional remove button.
class SelectedChip extends StatelessWidget {
  /// Creates a chip.
  const SelectedChip({
    super.key,
    required this.label,
    required this.enabled,
    required this.removeLabel,
    this.onRemove,
  });

  /// The chip's text.
  final String label;

  /// Whether to use the accent color or the disabled color.
  final bool enabled;

  /// Screen reader label of the remove button.
  final String removeLabel;

  /// Called when the remove button is tapped. No button when `null`.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = PickSheetTheme.of(context);
    final color = enabled ? theme.accent : theme.disabled;
    final remove = onRemove;

    return Center(
      child: Container(
        height: 28,
        padding: EdgeInsetsDirectional.only(
          start: 10,
          end: remove == null ? 10 : 2,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            if (remove != null)
              // container: its own node, so a screen reader can focus each
              // remove button instead of merging it into the field's label.
              Semantics(
                container: true,
                button: true,
                label: removeLabel,
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Haptics.selection(enabled: theme.enableHaptics);
                    remove();
                  },
                  // Padding widens the tap area beyond the small icon.
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 4, 6),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: color.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
