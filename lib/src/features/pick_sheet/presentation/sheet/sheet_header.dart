import 'package:flutter/material.dart';

import '../../../../core/theme/pick_sheet_theme.dart';
import '../../../../core/widgets/drag_handle.dart';
import '../../../../core/widgets/icon_badge.dart';

/// The sheet's drag handle, icon, title and description.
class SheetHeader extends StatelessWidget {
  /// Creates the header.
  const SheetHeader({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  /// The title.
  final String title;

  /// The line under the title.
  final String description;

  /// The icon before the title.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = PickSheetTheme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        children: [
          DragHandle(color: theme.dragHandle),
          const SizedBox(height: 20),
          Row(
            children: [
              IconBadge(
                icon: icon,
                color: theme.accent,
                bordered: true,
                iconSize: 24,
                radius: 14,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: theme.title,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: theme.subtitle),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
