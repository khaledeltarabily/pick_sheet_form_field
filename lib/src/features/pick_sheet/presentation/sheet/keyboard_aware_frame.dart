import 'package:flutter/material.dart';

/// The sheet's rounded surface, lifted above the keyboard.
///
/// It's the only widget of the sheet that reads the keyboard insets and the
/// screen size, so while the keyboard animates only this frame rebuilds:
/// [child] is the same instance every frame and isn't rebuilt.
class KeyboardAwareFrame extends StatelessWidget {
  /// Creates the frame around [child].
  const KeyboardAwareFrame({
    super.key,
    required this.color,
    required this.child,
  });

  /// The surface color.
  final Color color;

  /// The sheet's content. Build it outside this widget so it isn't rebuilt
  /// on every keyboard frame.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: color,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.85,
          child: child,
        ),
      ),
    );
  }
}
