import 'package:flutter/material.dart';

import '../../../../core/theme/pick_sheet_theme.dart';
import '../../../../core/widgets/icon_badge.dart';

/// Shown in the sheet when no item matches the search or filter.
class SheetEmptyState extends StatelessWidget {
  /// Creates the empty state with [text].
  const SheetEmptyState({super.key, required this.text});

  /// The message.
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = PickSheetTheme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconBadge(
            icon: Icons.search_off_rounded,
            color: theme.accent,
            circle: true,
            padding: 28,
            iconSize: 52,
            iconOpacity: 0.6,
          ),
          const SizedBox(height: 24),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.title,
            ),
          ),
        ],
      ),
    );
  }
}
