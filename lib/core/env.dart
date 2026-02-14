import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract final class Env {
  static const bool uiTesting = bool.fromEnvironment('UI_TESTING');
  static const bool smokeScreenshots = bool.fromEnvironment(
    'SMOKE_SCREENSHOTS',
  );

  /// True when running under `flutter test` (unit/widget tests).
  static bool get isTestRuntime {
    if (const bool.fromEnvironment('FLUTTER_TEST')) return true;

    if (!kIsWeb) {
      final env = Platform.environment;
      if (env.containsKey('FLUTTER_TEST') || env.containsKey('DART_TEST')) {
        return true;
      }
    }

    try {
      final bindingName = WidgetsBinding.instance.runtimeType.toString();
      if (bindingName.contains('TestWidgets') ||
          bindingName.contains('AutomatedTestWidgets')) {
        return true;
      }
    } catch (_) {
      // If binding isn't initialized yet, assume non-test.
    }

    return false;
  }

  /// Enables fakes to avoid OS calls (permissions/notifications) during tests.
  static bool get useFakes => uiTesting || isTestRuntime;
}
