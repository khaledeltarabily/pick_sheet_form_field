import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/pick_sheet_theme.dart';

/// The sheet's search box. Calls [onSearch] once typing pauses for
/// [debounce], so long lists aren't filtered on every keystroke.
class SheetSearchField extends StatefulWidget {
  /// Creates the search box.
  const SheetSearchField({
    super.key,
    required this.hintText,
    required this.onSearch,
    this.debounce = const Duration(milliseconds: 300),
  });

  /// The hint shown while empty.
  final String hintText;

  /// Called with the query after typing pauses, and right away when cleared.
  final ValueChanged<String> onSearch;

  /// How long typing must pause before [onSearch] runs.
  final Duration debounce;

  @override
  State<SheetSearchField> createState() => _SheetSearchFieldState();
}

class _SheetSearchFieldState extends State<SheetSearchField> {
  final _controller = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounce, () => widget.onSearch(query));
  }

  void _clear() {
    _debounceTimer?.cancel();
    _controller.clear();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = PickSheetTheme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.accent.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: theme.accent.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: TextField(
          controller: _controller,
          onChanged: _onChanged,
          textInputAction: TextInputAction.search,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: theme.title,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: theme.subtitle, fontSize: 15),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.search_rounded,
                color: theme.accent.withValues(alpha: 0.7),
                size: 24,
              ),
            ),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, child) => value.text.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      onPressed: _clear,
                      icon: Icon(
                        Icons.cancel_rounded,
                        color: theme.subtitle,
                        size: 20,
                      ),
                    ),
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }
}
