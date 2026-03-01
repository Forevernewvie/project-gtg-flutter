import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

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

class _MemoryPersistence extends GtgPersistence {
  _MemoryPersistence({required AppThemePreference themePreference})
    : _themePreference = themePreference,
      super(directoryProvider: _DummyDirectoryProvider());

  List<ExerciseLog> _logs = <ExerciseLog>[];
  ReminderSettings _settings = ReminderSettings.defaults;
  UserPreferences _prefs = const UserPreferences(
    hasCompletedOnboarding: true,
    primaryExercise: ExerciseType.pushUp,
  );
  AppThemePreference _themePreference;

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

  @override
  Future<AppThemePreference> loadAppThemePreference() async {
    return _themePreference;
  }

  @override
  Future<void> saveAppThemePreference(AppThemePreference preference) async {
    _themePreference = preference;
  }
}

class _Labels {
  const _Labels({
    required this.home,
    required this.calendar,
    required this.settings,
    required this.calendarTitle,
    required this.themeTitle,
    required this.reminders,
    required this.reminderHeadline,
    required this.allLogs,
  });

  final String home;
  final String calendar;
  final String settings;
  final String calendarTitle;
  final String themeTitle;
  final String reminders;
  final String reminderHeadline;
  final String allLogs;
}

const _en = _Labels(
  home: 'Home',
  calendar: 'Calendar',
  settings: 'Settings',
  calendarTitle: 'Rhythm Calendar',
  themeTitle: 'Theme',
  reminders: 'Reminders',
  reminderHeadline: 'Quiet and consistent',
  allLogs: 'All Logs',
);

const _ko = _Labels(
  home: '홈',
  calendar: '캘린더',
  settings: '설정',
  calendarTitle: '리듬 캘린더',
  themeTitle: '테마',
  reminders: '리마인더',
  reminderHeadline: '조용하고 꾸준하게',
  allLogs: '전체 기록',
);

void _assertNoException(WidgetTester tester, String stage) {
  final exception = tester.takeException();
  expect(
    exception,
    isNull,
    reason: 'Unexpected exception at $stage: $exception',
  );
}

Future<void> _tapListTileWithScroll(WidgetTester tester, String label) async {
  final tile = find.widgetWithText(ListTile, label);
  if (tile.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      tile,
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }

  await tester.tap(tile);
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const locales = <Locale>[Locale('en'), Locale('ko')];
  const themes = <AppThemePreference>[
    AppThemePreference.light,
    AppThemePreference.dark,
  ];

  testWidgets(
    'core navigation flow remains stable for locale/theme combinations',
    (tester) async {
      var caseIndex = 0;
      for (final locale in locales) {
        final labels = locale.languageCode == 'ko' ? _ko : _en;

        for (final theme in themes) {
          caseIndex += 1;
          final persistence = _MemoryPersistence(themePreference: theme);

          await tester.pumpWidget(
            ProviderScope(
              overrides: [persistenceProvider.overrideWithValue(persistence)],
              child: GtgApp(locale: locale),
            ),
          );
          await tester.pumpAndSettle();
          _assertNoException(tester, 'initial-$caseIndex');

          expect(find.text(labels.home), findsOneWidget);
          expect(find.text(labels.calendar), findsOneWidget);
          expect(find.text(labels.settings), findsOneWidget);

          await tester.tap(find.text(labels.calendar));
          await tester.pumpAndSettle();
          _assertNoException(tester, 'calendar-$caseIndex');
          expect(find.text(labels.calendarTitle), findsOneWidget);

          await tester.tap(find.text(labels.settings));
          await tester.pumpAndSettle();
          _assertNoException(tester, 'settings-$caseIndex');
          expect(find.text(labels.themeTitle), findsOneWidget);

          await _tapListTileWithScroll(tester, labels.reminders);
          _assertNoException(tester, 'reminders-$caseIndex');
          expect(find.text(labels.reminderHeadline), findsOneWidget);

          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();

          await _tapListTileWithScroll(tester, labels.allLogs);
          _assertNoException(tester, 'all-logs-$caseIndex');
          expect(find.text(labels.allLogs), findsWidgets);
        }
      }
    },
  );
}
