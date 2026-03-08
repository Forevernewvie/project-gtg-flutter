import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

import 'package:project_gtg/app/root_overlays_policy.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/core/models/user_preferences.dart';

const _testEnv = RootOverlayEnvironment(
  isTestRuntime: true,
  uiTesting: false,
  smokeScreenshots: false,
);

const _prodEnv = RootOverlayEnvironment(
  isTestRuntime: false,
  uiTesting: false,
  smokeScreenshots: false,
);

void main() {
  test('splash is disabled in test runtime regardless of flags', () {
    expect(RootOverlaysPolicy.shouldShowSplash(_testEnv), isFalse);
    expect(
      RootOverlaysPolicy.shouldShowSplash(
        const RootOverlayEnvironment(
          isTestRuntime: true,
          uiTesting: true,
          smokeScreenshots: true,
        ),
      ),
      isFalse,
    );
  });

  test('uiTesting hides splash unless smoke screenshots is enabled', () {
    expect(
      RootOverlaysPolicy.shouldShowSplash(
        const RootOverlayEnvironment(
          isTestRuntime: false,
          uiTesting: true,
          smokeScreenshots: false,
        ),
      ),
      isFalse,
    );
    expect(
      RootOverlaysPolicy.shouldShowSplash(
        const RootOverlayEnvironment(
          isTestRuntime: false,
          uiTesting: true,
          smokeScreenshots: true,
        ),
      ),
      isTrue,
    );
  });

  test('non-test runtime shows splash by default', () {
    expect(RootOverlaysPolicy.shouldShowSplash(_prodEnv), isTrue);
  });

  test('onboarding shows only after splash for incomplete preferences', () {
    expect(
      RootOverlaysPolicy.shouldShowOnboarding(
        environment: _prodEnv,
        showSplash: false,
        preferences: const UserPreferences(
          hasCompletedOnboarding: false,
          primaryExercise: ExerciseType.pushUp,
        ),
      ),
      isTrue,
    );
    expect(
      RootOverlaysPolicy.shouldShowOnboarding(
        environment: _prodEnv,
        showSplash: true,
        preferences: const UserPreferences(
          hasCompletedOnboarding: false,
          primaryExercise: ExerciseType.pushUp,
        ),
      ),
      isFalse,
    );
    expect(
      RootOverlaysPolicy.shouldShowOnboarding(
        environment: _prodEnv,
        showSplash: false,
        preferences: const UserPreferences(
          hasCompletedOnboarding: true,
          primaryExercise: ExerciseType.pushUp,
        ),
      ),
      isFalse,
    );
  });

  test('reminder sync only runs on resume outside tests', () {
    expect(
      RootOverlaysPolicy.shouldSyncRemindersOnLifecycle(
        environment: _prodEnv,
        state: AppLifecycleState.resumed,
      ),
      isTrue,
    );
    expect(
      RootOverlaysPolicy.shouldSyncRemindersOnLifecycle(
        environment: _prodEnv,
        state: AppLifecycleState.paused,
      ),
      isFalse,
    );
    expect(
      RootOverlaysPolicy.shouldSyncRemindersOnLifecycle(
        environment: _testEnv,
        state: AppLifecycleState.resumed,
      ),
      isFalse,
    );
  });
}
