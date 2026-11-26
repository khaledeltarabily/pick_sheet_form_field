import 'package:flutter/widgets.dart';

/// Rebuilds only when the value picked by [selector] changes, not on every
/// notification of [listenable].
///
/// The sheet uses it per row: toggling one item runs every visible row's
/// selector (a set lookup) but rebuilds only the toggled row.
class ListenableSelector<S> extends StatefulWidget {
  /// Creates a selector.
  const ListenableSelector({
    super.key,
    required this.listenable,
    required this.selector,
    required this.builder,
  });

  /// What to listen to.
  final Listenable listenable;

  /// Picks the value this widget depends on. Compared with `==`.
  final S Function() selector;

  /// Builds the child from the selected value.
  final Widget Function(BuildContext context, S value) builder;

  @override
  State<ListenableSelector<S>> createState() => _ListenableSelectorState<S>();
}

class _ListenableSelectorState<S> extends State<ListenableSelector<S>> {
  late S _value = widget.selector();

  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant ListenableSelector<S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(_onChanged);
      widget.listenable.addListener(_onChanged);
    }
    // The selector may now read a different item (e.g. after filtering).
    _value = widget.selector();
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    final value = widget.selector();
    if (value != _value) setState(() => _value = value);
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _value);
}
