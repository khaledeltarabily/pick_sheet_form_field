import 'package:flutter/material.dart';

import '../../../../core/l10n/pick_sheet_strings.dart';
import 'selected_chip.dart';

/// One horizontally scrollable line of chips, so the field keeps the same
/// height however many values are selected.
///
/// The fade at the end is drawn only when the chips overflow, because it
/// needs an extra compositing layer.
class SelectedChipsRow<T> extends StatefulWidget {
  /// Creates the chips row.
  const SelectedChipsRow({
    super.key,
    required this.values,
    required this.labelOf,
    required this.enabled,
    required this.removeLabel,
    this.onRemove,
  });

  /// The selected values, in display order.
  final List<T> values;

  /// The chip text of a value.
  final String Function(T value) labelOf;

  /// Whether the chips use the accent color or the disabled color.
  final bool enabled;

  /// Screen reader label of a chip's remove button.
  final PickSheetItemText removeLabel;

  /// Called when a chip's remove button is tapped. No button when `null`.
  final ValueChanged<T>? onRemove;

  @override
  State<SelectedChipsRow<T>> createState() => _SelectedChipsRowState<T>();
}

class _SelectedChipsRowState<T> extends State<SelectedChipsRow<T>> {
  bool _overflows = false;

  bool _onMetricsChanged(ScrollMetricsNotification notification) {
    final overflows = notification.metrics.maxScrollExtent > 0;
    if (overflows != _overflows) setState(() => _overflows = overflows);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final values = widget.values;
    if (values.isEmpty) return const SizedBox.shrink();
    final onRemove = widget.onRemove;

    final list = NotificationListener<ScrollMetricsNotification>(
      onNotification: _onMetricsChanged,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.only(end: 20),
        itemCount: values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final value = values[index];
          final label = widget.labelOf(value);
          return SelectedChip(
            label: label,
            enabled: widget.enabled,
            removeLabel: widget.removeLabel(label),
            onRemove: onRemove == null ? null : () => onRemove(value),
          );
        },
      ),
    );

    if (!_overflows) return list;

    final textDirection = Directionality.of(context);
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => const LinearGradient(
        begin: AlignmentDirectional.centerStart,
        end: AlignmentDirectional.centerEnd,
        colors: [Colors.white, Colors.white, Colors.transparent],
        stops: [0, 0.9, 1],
      ).createShader(rect, textDirection: textDirection),
      child: list,
    );
  }
}
