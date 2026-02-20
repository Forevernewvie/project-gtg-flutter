import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:project_gtg/app/gtg_app.dart';
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

  List<ExerciseLog> _logs = <ExerciseLog>[
    ExerciseLog(
      id: 'seed-1',
      type: ExerciseType.pushUp,
      reps: 12,
      timestamp: DateTime(2026, 2, 20, 7, 10),
    ),
    ExerciseLog(
      id: 'seed-2',
      type: ExerciseType.pullUp,
      reps: 6,
      timestamp: DateTime(2026, 2, 20, 12, 20),
    ),
    ExerciseLog(
      id: 'seed-3',
      type: ExerciseType.dips,
      reps: 9,
      timestamp: DateTime(2026, 2, 19, 18, 5),
    ),
  ];

  ReminderSettings _settings = ReminderSettings.defaults;
  UserPreferences _prefs = const UserPreferences(
    hasCompletedOnboarding: true,
    primaryExercise: ExerciseType.pushUp,
  );

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

void _expectNoFrameworkError(WidgetTester tester, {required String stage}) {
  final exception = tester.takeException();
  expect(
    exception,
    isNull,
    reason: 'Unexpected framework exception at stage: $stage',
  );
}

void main() {
  testWidgets(
    'core screens stay layout-safe across common Galaxy logical sizes',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });

      const profiles = <Size>[
        Size(360, 780), // common Galaxy baseline
        Size(412, 915), // newer Galaxy/S24 class
        Size(480, 1060), // larger Galaxy class
      ];

      const textScales = <double>[1.0, 1.2, 1.4, 1.6];

      var caseIndex = 0;
      for (final profile in profiles) {
        for (final scale in textScales) {
          tester.view.devicePixelRatio = 1.0;
          tester.view.physicalSize = profile;
          tester.platformDispatcher.textScaleFactorTestValue = scale;

          final persistence = _MemoryPersistence();
          await tester.pumpWidget(
            ProviderScope(
              overrides: [persistenceProvider.overrideWithValue(persistence)],
              child: const GtgApp(locale: Locale('ko')),
            ),
          );
          await tester.pumpAndSettle();
          _expectNoFrameworkError(tester, stage: 'initial-load-$caseIndex');

          expect(find.byType(NavigationBar), findsOneWidget);

          await tester.tap(find.text('캘린더'));
          await tester.pumpAndSettle();
          _expectNoFrameworkError(tester, stage: 'calendar-$caseIndex');

          await tester.tap(find.text('설정'));
          await tester.pumpAndSettle();
          _expectNoFrameworkError(tester, stage: 'settings-$caseIndex');

          await tester.tap(find.widgetWithText(ListTile, '리마인더'));
          await tester.pumpAndSettle();
          _expectNoFrameworkError(tester, stage: 'reminders-$caseIndex');

          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          _expectNoFrameworkError(
            tester,
            stage: 'back-from-reminders-$caseIndex',
          );

          await tester.tap(find.widgetWithText(ListTile, '전체 기록'));
          await tester.pumpAndSettle();
          _expectNoFrameworkError(tester, stage: 'all-logs-$caseIndex');

          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          _expectNoFrameworkError(
            tester,
            stage: 'back-from-all-logs-$caseIndex',
          );
          caseIndex++;
        }
      }
    },
  );
}
