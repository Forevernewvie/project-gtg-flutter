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

const _tempDirPath = '/tmp';

class _DummyDirectoryProvider implements DirectoryProvider {
  @override
  Future<Directory> getApplicationSupportDirectory() async {
    return Directory(_tempDirPath);
  }
}

class _MemoryPersistence extends GtgPersistence {
  _MemoryPersistence()
    : _prefs = UserPreferences(
        hasCompletedOnboarding: true,
        primaryExercise: ExerciseType.pushUp,
      ),
      super(directoryProvider: _DummyDirectoryProvider());

  final List<ExerciseLog> _logs = <ExerciseLog>[
    ExerciseLog(
      id: 'seed-1',
      type: ExerciseType.pushUp,
      reps: 12,
      timestamp: DateTime(2026, 4, 20, 7, 10),
    ),
  ];

  final ReminderSettings _settings = ReminderSettings.defaults;
  final UserPreferences _prefs;

  @override
  Future<List<ExerciseLog>> loadLogs() async => _logs;

  @override
  Future<ReminderSettings> loadReminderSettings() async => _settings;

  @override
  Future<UserPreferences> loadUserPreferences() async => _prefs;

  @override
  Future<AppThemePreference> loadAppThemePreference() async {
    return AppThemePreference.light;
  }
}

void main() {
  testWidgets('home shell stays usable with Android 15 edge-to-edge insets', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.viewPadding = const FakeViewPadding(
      left: 0,
      top: 44,
      right: 0,
      bottom: 34,
    );
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetViewPadding();
    });

    final persistence = _MemoryPersistence();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [persistenceProvider.overrideWithValue(persistence)],
        child: const GtgApp(locale: Locale('ko')),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('dashboard.todayTotalValue')), findsWidgets);
    expect(find.byIcon(Icons.home_rounded), findsWidgets);
    expect(find.byIcon(Icons.calendar_month_rounded), findsWidgets);
    expect(find.byIcon(Icons.tune_rounded), findsWidgets);

    await tester.tap(find.byIcon(Icons.tune_rounded).last);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('설정'), findsWidgets);
    expect(find.text('알림'), findsWidgets);
  });
}
