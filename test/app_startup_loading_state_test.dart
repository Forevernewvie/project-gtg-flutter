import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_gtg/app/gtg_app.dart';
import 'package:project_gtg/core/models/app_theme_preference.dart';
import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/core/models/reminder_settings.dart';
import 'package:project_gtg/core/models/user_preferences.dart';
import 'package:project_gtg/data/persistence/directory_provider.dart';
import 'package:project_gtg/data/persistence/gtg_persistence.dart';
import 'package:project_gtg/data/persistence/persistence_provider.dart';

class _DummyDirectoryProvider implements DirectoryProvider {
  @override
  Future<Directory> getApplicationSupportDirectory() async {
    return Directory('/tmp');
  }
}

class _DelayedStartupPersistence extends GtgPersistence {
  _DelayedStartupPersistence({
    required this.themeCompleter,
    required this.preferencesCompleter,
    required this.logsCompleter,
  }) : super(directoryProvider: _DummyDirectoryProvider());

  final Completer<AppThemePreference> themeCompleter;
  final Completer<UserPreferences> preferencesCompleter;
  final Completer<List<ExerciseLog>> logsCompleter;

  @override
  Future<AppThemePreference> loadAppThemePreference() {
    return themeCompleter.future;
  }

  @override
  Future<UserPreferences> loadUserPreferences() {
    return preferencesCompleter.future;
  }

  @override
  Future<List<ExerciseLog>> loadLogs() {
    return logsCompleter.future;
  }

  @override
  Future<ReminderSettings> loadReminderSettings() async {
    return ReminderSettings.defaults;
  }
}

void main() {
  testWidgets('app cold-start stays interactive while persistence is loading', (
    tester,
  ) async {
    final themeCompleter = Completer<AppThemePreference>();
    final preferencesCompleter = Completer<UserPreferences>();
    final logsCompleter = Completer<List<ExerciseLog>>();
    final persistence = _DelayedStartupPersistence(
      themeCompleter: themeCompleter,
      preferencesCompleter: preferencesCompleter,
      logsCompleter: logsCompleter,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [persistenceProvider.overrideWithValue(persistence)],
        child: const GtgApp(locale: Locale('en')),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.takeException(), isNull);

    themeCompleter.complete(AppThemePreference.system);
    preferencesCompleter.complete(
      const UserPreferences(
        hasCompletedOnboarding: true,
        primaryExercise: ExerciseType.pushUp,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    final loadingMissionButton = tester.widget<FilledButton>(
      find.byKey(const Key('dashboard.missionLogButton')),
    );
    expect(loadingMissionButton.onPressed, isNull);
    expect(find.text('Ready for today'), findsNothing);

    logsCompleter.complete(const <ExerciseLog>[]);

    await tester.pumpAndSettle();

    final readyMissionButton = tester.widget<FilledButton>(
      find.byKey(const Key('dashboard.missionLogButton')),
    );
    expect(readyMissionButton.onPressed, isNotNull);
    expect(find.byKey(const Key('dashboard.missionCard')), findsNothing);
    expect(find.byKey(const Key('dashboard.todayTotalValue')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
