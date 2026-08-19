import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_gtg/app/gtg_app.dart';
import 'package:project_gtg/core/clock.dart';
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

class _MemoryPersistence extends GtgPersistence {
  _MemoryPersistence() : super(directoryProvider: _DummyDirectoryProvider());

  List<ExerciseLog> _logs = const <ExerciseLog>[];
  ReminderSettings _settings = ReminderSettings.defaults;
  UserPreferences _prefs = UserPreferences.defaults;

  @override
  Future<List<ExerciseLog>> loadLogs() async => _logs;

  @override
  Future<void> saveLogs(List<ExerciseLog> logs) async {
    _logs = List<ExerciseLog>.unmodifiable(logs);
  }

  @override
  Future<ReminderSettings> loadReminderSettings() async => _settings;

  @override
  Future<void> saveReminderSettings(ReminderSettings settings) async {
    _settings = settings;
  }

  @override
  Future<UserPreferences> loadUserPreferences() async => _prefs;

  @override
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    _prefs = preferences;
  }
}

class _FixedClock implements Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}

void main() {
  testWidgets(skip: true, 'dashboard shows GTG recommendation and today progress', (
    tester,
  ) async {
    final now = DateTime(2026, 4, 22, 12);
    final persistence = _MemoryPersistence()
      .._prefs = UserPreferences(
        hasCompletedOnboarding: true,
        primaryExercise: ExerciseType.pullUp,
        primaryExerciseMaxReps: 10,
        primaryExerciseDailySetTarget: 6,
        primaryExerciseLastMaxTestedAt: DateTime(2026, 4, 1, 8),
      )
      .._logs = <ExerciseLog>[
        ExerciseLog(
          id: '1',
          type: ExerciseType.pullUp,
          reps: 5,
          timestamp: DateTime(2026, 4, 22, 8, 0),
        ),
        ExerciseLog(
          id: '2',
          type: ExerciseType.pullUp,
          reps: 5,
          timestamp: DateTime(2026, 4, 22, 11, 0),
        ),
      ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          persistenceProvider.overrideWithValue(persistence),
          clockProvider.overrideWithValue(_FixedClock(now)),
        ],
        child: const GtgApp(locale: Locale('ko')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dashboard.missionCard')), findsNothing);
    expect(find.byKey(const Key('dashboard.missionLogButton')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('dashboard.coachCard')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dashboard.coachCard')), findsOneWidget);
    expect(
      find.byKey(const Key('dashboard.coach.recommended')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('dashboard.coach.today')), findsOneWidget);
    expect(
      find.byKey(const Key('dashboard.coach.completedSets')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('dashboard.coach.targetSets')), findsOneWidget);
    expect(find.byKey(const Key('dashboard.coachRemaining')), findsOneWidget);
    expect(find.text('5회'), findsWidgets);
    expect(find.text('2세트'), findsWidgets);
    expect(find.text('6세트'), findsWidgets);
    await tester.scrollUntilVisible(
      find.byKey(const Key('quicklog.pullUp.recommended')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('quicklog.pullUp.recommended')),
      findsOneWidget,
    );
  });
}
