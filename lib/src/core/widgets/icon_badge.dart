import 'package:flutter/material.dart';

/// An icon on a soft gradient of [color], or on a solid gradient when
/// [filled]. Used by the sheet header, the list rows and the empty state.
class IconBadge extends StatelessWidget {
  /// Creates an icon badge.
  const IconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.onColor = Colors.white,
    this.filled = false,
    this.bordered = false,
    this.circle = false,
    this.iconSize = 20,
    this.padding = 12,
    this.radius = 12,
    this.iconOpacity = 1,
  });

  /// The icon.
  final IconData icon;

  /// The badge's color.
  final Color color;

  /// Icon color when [filled].
  final Color onColor;

  /// Whether to use a solid gradient (for a selected item).
  final bool filled;

  /// Whether to draw a faint outline.
  final bool bordered;

  /// Whether the badge is a circle instead of a rounded square.
  final bool circle;

  /// The icon's size.
  final double iconSize;

  /// Space around the icon.
  final double padding;

  /// Corner radius when not a [circle].
  final double radius;

  /// Opacity of the icon when not [filled].
  final double iconOpacity;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: filled
              ? [color, color.withValues(alpha: 0.8)]
              : [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
        ),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius),
        border: bordered
            ? Border.all(color: color.withValues(alpha: 0.1))
            : null,
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: filled ? onColor : color.withValues(alpha: iconOpacity),
      ),
    );
  }
}
