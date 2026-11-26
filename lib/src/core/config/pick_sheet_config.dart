import 'package:flutter/widgets.dart';

import '../l10n/pick_sheet_strings.dart';

/// App-wide texts and builders for every pick sheet field below it.
///
/// Optional. Put it in `MaterialApp.builder`, so it sits above the
/// `Navigator` and the bottom sheets can see it too:
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => PickSheetConfig(
///     strings: PickSheetStrings(confirm: 'تأكيد'),
///     loadingBuilder: (context) => const MySkeleton(),
///     child: child!,
///   ),
/// )
/// ```
class PickSheetConfig extends InheritedWidget {
  /// Creates the app-wide configuration.
  const PickSheetConfig({
    super.key,
    this.strings,
    this.loadingBuilder,
    this.emptyBuilder,
    required super.child,
  });

  /// Texts used by every field. A field's own `strings` override these.
  final PickSheetStrings? strings;

  /// Builds the placeholder shown while a field is loading.
  /// Defaults to a plain box the size of the field.
  final WidgetBuilder? loadingBuilder;

  /// Builds what the sheet shows when no item matches.
  /// Defaults to an icon and [PickSheetStrings.noResults].
  final WidgetBuilder? emptyBuilder;

  /// The closest configuration above [context], if any.
  static PickSheetConfig? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PickSheetConfig>();

  @override
  bool updateShouldNotify(PickSheetConfig oldWidget) =>
      strings != oldWidget.strings ||
      loadingBuilder != oldWidget.loadingBuilder ||
      emptyBuilder != oldWidget.emptyBuilder;
}
