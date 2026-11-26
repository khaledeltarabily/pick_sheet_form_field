import 'package:flutter/widgets.dart';

import '../l10n/pick_sheet_strings.dart';

/// Texts and builders for a pick sheet field or sheet.
///
/// Pass it as `config` to `PickSheetFormField` or `showPickSheet`. Anything
/// left `null` uses the built-in default.
///
/// To use the same config across the whole app, write a wrapper once and use
/// it everywhere:
///
/// ```dart
/// class AppPickSheetField<T> extends StatelessWidget {
///   const AppPickSheetField({super.key, required this.items, required this.labelText});
///
///   final List<PickSheetItem<T>> items;
///   final String labelText;
///
///   @override
///   Widget build(BuildContext context) {
///     final l10n = AppLocalizations.of(context);
///     return PickSheetFormField<T>(
///       items: items,
///       labelText: labelText,
///       config: PickSheetConfig(
///         strings: PickSheetStrings(confirm: l10n.confirm, search: l10n.search),
///         loadingBuilder: (context) => const MySkeleton(),
///       ),
///     );
///   }
/// }
/// ```
///
/// To use a different config each time, pass it directly where you use the
/// field.
@immutable
class PickSheetConfig {
  /// Creates a configuration. Only the values you pass replace the defaults.
  const PickSheetConfig({this.strings, this.loadingBuilder, this.emptyBuilder});

  /// Texts. A text left `null` falls back to [PickSheetStrings.english].
  final PickSheetStrings? strings;

  /// Builds the placeholder shown while a field is loading.
  /// Defaults to a plain box the size of the field.
  final WidgetBuilder? loadingBuilder;

  /// Builds what the sheet shows when no item matches.
  /// Defaults to an icon and [PickSheetStrings.noResults].
  final WidgetBuilder? emptyBuilder;
}
