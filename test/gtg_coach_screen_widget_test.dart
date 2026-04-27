import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_gtg/core/clock.dart';
import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/core/models/reminder_settings.dart';
import 'package:project_gtg/core/models/user_preferences.dart';
import 'package:project_gtg/data/persistence/directory_provider.dart';
import 'package:project_gtg/data/persistence/gtg_persistence.dart';
import 'package:project_gtg/data/persistence/persistence_provider.dart';
import 'package:project_gtg/features/coaching/presentation/screens/gtg_coach_screen.dart';

import 'test_app.dart';

class _DummyDirectoryProvider implements DirectoryProvider {
  @override
  Future<Directory> getApplicationSupportDirectory() async {
    return Directory('/tmp');
  }
}

class _MemoryPersistence extends GtgPersistence {
  _MemoryPersistence() : super(directoryProvider: _DummyDirectoryProvider());

  UserPreferences _prefs = const UserPreferences(
    hasCompletedOnboarding: true,
    primaryExercise: ExerciseType.pullUp,
  );
  List<ExerciseLog> _logs = const <ExerciseLog>[];
  ReminderSettings _settings = ReminderSettings.defaults;

  @override
  Future<List<ExerciseLog>> loadLogs() async => _logs;

  @override
  Future<void> saveLogs(List<ExerciseLog> logs) async {
    _logs = List<ExerciseLog>.unmodifiable(logs);
  }

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

class _FixedClock implements Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}

void main() {
  testWidgets('GTG coach screen persists baseline and daily set target', (
    tester,
  ) async {
    final persistence = _MemoryPersistence();
    final now = DateTime(2026, 4, 22, 7, 30);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          persistenceProvider.overrideWithValue(persistence),
          clockProvider.overrideWithValue(_FixedClock(now)),
        ],
        child: testApp(const GtgCoachScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('coach.maxReps.plus')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('coach.dailySetTarget.plus')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('coach.dailySetTarget.plus')));
    await tester.pumpAndSettle();

    expect(persistence._prefs.primaryExerciseMaxReps, 1);
    expect(persistence._prefs.primaryExerciseDailySetTarget, 9);
    expect(persistence._prefs.primaryExerciseLastMaxTestedAt, now);
  });

  testWidgets('GTG coach screen renders complete daily plan details', (
    tester,
  ) async {
    final now = DateTime(2026, 4, 22, 13);
    final persistence = _MemoryPersistence()
      .._prefs = UserPreferences(
        hasCompletedOnboarding: true,
        primaryExercise: ExerciseType.pullUp,
        primaryExerciseMaxReps: 12,
        primaryExerciseDailySetTarget: 5,
        primaryExerciseLastMaxTestedAt: DateTime(2026, 4, 20),
      )
      .._logs = <ExerciseLog>[
        ExerciseLog(
          id: '1',
          type: ExerciseType.pullUp,
          reps: 6,
          timestamp: DateTime(2026, 4, 22, 8),
        ),
        ExerciseLog(
          id: '2',
          type: ExerciseType.pullUp,
          reps: 6,
          timestamp: DateTime(2026, 4, 22, 12),
        ),
      ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          persistenceProvider.overrideWithValue(persistence),
          clockProvider.overrideWithValue(_FixedClock(now)),
        ],
        child: testApp(const GtgCoachScreen(), locale: const Locale('en')),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Completed sets'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Recommended GTG reps'), findsWidgets);
    expect(find.text('6 reps'), findsWidgets);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('2/5 sets'), findsOneWidget);
    expect(find.text('Completed sets'), findsOneWidget);
    expect(find.text('2 sets'), findsOneWidget);
    expect(find.text('Target sets'), findsOneWidget);
    expect(find.text('5 sets'), findsWidgets);
    expect(find.text('3 sets left today'), findsOneWidget);
  });

  testWidgets('GTG coach screen renders local insight guidance', (
    tester,
  ) async {
    final now = DateTime(2026, 4, 22, 13);
    final persistence = _MemoryPersistence()
      .._prefs = const UserPreferences(
        hasCompletedOnboarding: true,
        primaryExercise: ExerciseType.pullUp,
        primaryExerciseMaxReps: 0,
        primaryExerciseDailySetTarget: 5,
      );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          persistenceProvider.overrideWithValue(persistence),
          clockProvider.overrideWithValue(_FixedClock(now)),
        ],
        child: testApp(const GtgCoachScreen(), locale: const Locale('en')),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('coach.localInsights')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Local insights'), findsOneWidget);
    expect(find.text('Private signals from your recent logs.'), findsOneWidget);
    expect(
      find.text('Add max reps to unlock personalized guidance.'),
      findsOneWidget,
    );
  });
}
