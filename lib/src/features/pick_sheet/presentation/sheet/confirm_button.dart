import 'package:flutter/material.dart';

import '../../../../core/theme/pick_sheet_theme.dart';

/// The full-width button that closes the sheet with the selection.
class ConfirmButton extends StatelessWidget {
  /// Creates the button.
  const ConfirmButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  /// The button's text.
  final String label;

  /// Called when pressed.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // Only colors set in PickSheetTheme are passed on. A `null` leaves the
    // choice to the app's FilledButtonTheme, then to the ColorScheme.
    final chosen = Theme.of(context).extension<PickSheetTheme>();
    final app = FilledButtonTheme.of(context).style;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: chosen?.accentColor,
          foregroundColor: chosen?.onAccentColor,
          minimumSize: const Size(double.infinity, 48),
          shape: app?.shape != null
              ? null
              : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          // Built on labelLarge so the button keeps the app's font family.
          textStyle: app?.textStyle != null
              ? null
              : (Theme.of(context).textTheme.labelLarge ?? const TextStyle())
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        child: Text(label),
      ),
    );
  }
}
