import 'package:flutter/material.dart';

import '../../domain/entities/pick_sheet_status.dart';
import 'clear_all_button.dart';
import 'count_badge.dart';
import 'status_indicator.dart';

/// The end of the field: selected count, "clear all" button and status icon.
class FieldTrailing extends StatelessWidget {
  /// Creates the trailing part.
  const FieldTrailing({
    super.key,
    required this.count,
    required this.status,
    required this.enabled,
    required this.clearAllLabel,
    this.onClearAll,
  });

  /// Number of selected values.
  final int count;

  /// The items' status, shown as an icon.
  final PickSheetStatus status;

  /// Whether the field can be used.
  final bool enabled;

  /// Tooltip of the "clear all" button.
  final String clearAllLabel;

  /// Called by the "clear all" button. No button when `null`.
  final VoidCallback? onClearAll;

  @override
  Widget build(BuildContext context) {
    final clearAll = onClearAll;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (count > 0) ...[
          const SizedBox(width: 6),
          CountBadge(count: count, enabled: enabled),
        ],
        if (clearAll != null)
          ClearAllButton(tooltip: clearAllLabel, onPressed: clearAll),
        StatusIndicator(status: status, enabled: enabled),
      ],
    );
  }
}
