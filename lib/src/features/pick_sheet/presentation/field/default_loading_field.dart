import 'package:flutter/material.dart';

/// The placeholder shown while a field is loading, when the app sets no
/// `PickSheetConfig.loadingBuilder`. A plain box the size of the field.
class DefaultLoadingField extends StatelessWidget {
  /// Creates the placeholder.
  const DefaultLoadingField({super.key, required this.semanticLabel});

  /// What screen readers announce.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;

    return Semantics(
      label: semanticLabel,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
