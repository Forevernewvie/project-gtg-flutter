import 'package:flutter/material.dart';

import '../core/models/user_preferences.dart';

/// Immutable environment flags used to decide root overlay behavior.
final class RootOverlayEnvironment {
  /// Creates the environment snapshot used by root overlay policies.
  const RootOverlayEnvironment({
    required this.isTestRuntime,
    required this.uiTesting,
    required this.smokeScreenshots,
  });

  final bool isTestRuntime;
  final bool uiTesting;
  final bool smokeScreenshots;
}

/// Pure policy helpers for splash/onboarding visibility and lifecycle side effects.
abstract final class RootOverlaysPolicy {
  static const Duration splashDuration = Duration(seconds: 2);

  /// Returns whether the in-app splash should appear for the current environment.
  static bool shouldShowSplash(RootOverlayEnvironment environment) {
    return !environment.isTestRuntime &&
        (!environment.uiTesting || environment.smokeScreenshots);
  }

  /// Returns whether onboarding should appear once splash handling is complete.
  static bool shouldShowOnboarding({
    required RootOverlayEnvironment environment,
    required bool showSplash,
    required UserPreferences? preferences,
  }) {
    return !showSplash &&
        !environment.isTestRuntime &&
        !environment.uiTesting &&
        !environment.smokeScreenshots &&
        preferences != null &&
        !preferences.hasCompletedOnboarding;
  }

  /// Returns whether reminder synchronization should run for the lifecycle event.
  static bool shouldSyncRemindersOnLifecycle({
    required RootOverlayEnvironment environment,
    required AppLifecycleState state,
  }) {
    return !environment.isTestRuntime && state == AppLifecycleState.resumed;
  }
}
