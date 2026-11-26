import 'package:flutter/material.dart';

import '../../../../core/theme/pick_sheet_theme.dart';
import '../../domain/entities/pick_sheet_status.dart';

/// The icon at the end of the field: a dropdown arrow when ready, or an
/// offline or error icon.
class StatusIndicator extends StatelessWidget {
  /// Creates the icon for [status].
  const StatusIndicator({
    super.key,
    required this.status,
    required this.enabled,
  });

  /// The items' status.
  final PickSheetStatus status;

  /// Whether the field can be used.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = PickSheetTheme.of(context);

    final icon = switch (status) {
      PickSheetStatus.offline => Icon(
        Icons.signal_wifi_connected_no_internet_4,
        color: theme.statusIcon,
      ),
      PickSheetStatus.failure => Icon(
        Icons.error_outline,
        size: 27,
        color: theme.statusIcon,
      ),
      PickSheetStatus.loading || PickSheetStatus.ready => Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 22,
        color: enabled ? theme.label : theme.disabled,
      ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: icon,
    );
  }
}
