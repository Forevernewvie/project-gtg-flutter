import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_gtg/app/root_overlays.dart';
import 'package:project_gtg/app/root_overlays_policy.dart';
import 'package:project_gtg/core/external_link_launcher.dart';
import 'package:project_gtg/core/logging/app_logger.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/core/models/reminder_settings.dart';
import 'package:project_gtg/core/models/user_preferences.dart';
import 'package:project_gtg/core/platform/app_build_info.dart';
import 'package:project_gtg/data/persistence/directory_provider.dart';
import 'package:project_gtg/data/persistence/gtg_persistence.dart';
import 'package:project_gtg/data/persistence/persistence_provider.dart';
import 'package:project_gtg/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:project_gtg/features/update/models/app_update_info.dart';
import 'package:project_gtg/features/update/services/app_update_checker.dart';

import 'test_app.dart';

class _DummyDirectoryProvider implements DirectoryProvider {
  @override
  Future<Directory> getApplicationSupportDirectory() async {
    return Directory('/tmp');
  }
}

class _MemoryPersistence extends GtgPersistence {
  _MemoryPersistence()
    : _prefs = const UserPreferences(
        hasCompletedOnboarding: false,
        primaryExercise: ExerciseType.pushUp,
      ),
      super(directoryProvider: _DummyDirectoryProvider());

  UserPreferences _prefs;
  ReminderSettings _settings = ReminderSettings.defaults;

  @override
  Future<UserPreferences> loadUserPreferences() async => _prefs;

  @override
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    _prefs = preferences;
  }

  @override
  Future<ReminderSettings> loadReminderSettings() async => _settings;

  @override
  Future<void> saveReminderSettings(ReminderSettings settings) async {
    _settings = settings;
  }
}

class _FakeExternalLinkLauncher implements ExternalLinkLauncher {
  int launchCount = 0;
  Uri? lastUri;

  @override
  Future<bool> launch(Uri uri) async {
    launchCount += 1;
    lastUri = uri;
    return true;
  }
}

class _FakeAppUpdateChecker extends AppUpdateChecker {
  _FakeAppUpdateChecker(this.update)
    : super(
        buildInfoReader: const _NeverCalledBuildInfoReader(),
        logger: _NoopLogger(),
      );

  final AppUpdateInfo? update;

  @override
  Future<AppUpdateInfo?> checkForUpdate() async => update;
}

class _NeverCalledBuildInfoReader implements AppBuildInfoReader {
  const _NeverCalledBuildInfoReader();

  @override
  Future<AppBuildInfo> read() {
    throw UnimplementedError();
  }
}

class _NoopLogger implements AppLogger {
  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}

  @override
  void info(String message) {}

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) {}
}

void main() {
  testWidgets(
    'RootOverlays completes first-run onboarding and dismisses overlay',
    (tester) async {
      final persistence = _MemoryPersistence();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [persistenceProvider.overrideWithValue(persistence)],
          child: testApp(
            const RootOverlays(
              environmentOverride: RootOverlayEnvironment(
                isTestRuntime: false,
                uiTesting: false,
                smokeScreenshots: false,
              ),
              child: Scaffold(body: Center(child: Text('base-child'))),
            ),
            locale: const Locale('en'),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Tap to skip'));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);

      await tester.tap(find.text('Pull-ups'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding.maxReps.plus')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding.maxReps.plus')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Next'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.text('base-child'), findsOneWidget);
      expect(persistence._prefs.hasCompletedOnboarding, isTrue);
      expect(persistence._prefs.primaryExercise, ExerciseType.pullUp);
      expect(persistence._prefs.primaryExerciseMaxReps, 2);
    },
  );

  testWidgets('RootOverlays shows hosted update prompt after splash', (
    tester,
  ) async {
    final persistence = _MemoryPersistence()
      .._prefs = const UserPreferences(
        hasCompletedOnboarding: true,
        primaryExercise: ExerciseType.pushUp,
      );
    final launcher = _FakeExternalLinkLauncher();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          persistenceProvider.overrideWithValue(persistence),
          appUpdateCheckerProvider.overrideWithValue(
            _FakeAppUpdateChecker(
              const AppUpdateInfo(
                latestVersionCode: 4,
                latestVersionName: '1.0.0',
                forceUpdate: false,
                message: 'A new update is available.',
                storeUrl:
                    'https://play.google.com/store/apps/details?id=com.forevernewvie.projectgtg',
              ),
            ),
          ),
          externalLinkLauncherProvider.overrideWithValue(launcher),
        ],
        child: testApp(
          const RootOverlays(
            environmentOverride: RootOverlayEnvironment(
              isTestRuntime: false,
              uiTesting: false,
              smokeScreenshots: false,
            ),
            child: Scaffold(body: Center(child: Text('base-child'))),
          ),
          locale: const Locale('en'),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Tap to skip'));
    await tester.pumpAndSettle();

    expect(find.text('Update available'), findsOneWidget);
    expect(find.text('A new update is available.'), findsOneWidget);

    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();

    expect(launcher.launchCount, 1);
    expect(launcher.lastUri, isNotNull);
  });
}
