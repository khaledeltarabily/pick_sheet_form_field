import 'package:flutter/material.dart';

/// The small bar at the top of the sheet.
class DragHandle extends StatelessWidget {
  /// Creates a drag handle of [color].
  const DragHandle({super.key, required this.color});

  /// The handle's color.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      width: 44,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
