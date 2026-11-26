import 'dart:async';

import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

/// Runs every `testWidgets` in this package with leak tracking on: a test
/// fails if a `ChangeNotifier`, `FocusNode`, controller or other disposable
/// created during it is never disposed, or is disposed but never collected.
///
/// A test can opt out with
/// `experimentalLeakTesting: LeakTesting.settings.withIgnoredAll()`.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  LeakTesting.enable();
  LeakTracking.warnForUnsupportedPlatforms = false;
  LeakTesting.settings = LeakTesting.settings.withTrackedAll().withIgnored(
    createdByTestHelpers: true,
  );
  await testMain();
}
