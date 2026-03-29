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
import 'package:project_gtg/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:project_gtg/l10n/app_localizations.dart';

const _tempDirPath = '/tmp';
const _scrollStep = 200.0;

/// Directory provider test double that avoids platform channel IO in integration tests.
class _DummyDirectoryProvider implements DirectoryProvider {
  @override
  Future<Directory> getApplicationSupportDirectory() async {
    return Directory(_tempDirPath);
  }
}

/// In-memory persistence double that keeps integration flows deterministic.
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
    required this.reminders,
    required this.reminderHeadline,
    required this.allLogs,
    required this.onboardingNext,
    required this.onboardingLater,
  });

  final String home;
  final String calendar;
  final String settings;
  final String calendarTitle;
  final String reminders;
  final String reminderHeadline;
  final String allLogs;
  final String onboardingNext;
  final String onboardingLater;
}

const _en = _Labels(
  home: 'Home',
  calendar: 'Calendar',
  settings: 'Settings',
  calendarTitle: 'Rhythm Calendar',
  reminders: 'Reminders',
  reminderHeadline: 'Quiet and consistent',
  allLogs: 'All Logs',
  onboardingNext: 'Next',
  onboardingLater: 'Later',
);

const _ko = _Labels(
  home: '홈',
  calendar: '캘린더',
  settings: '설정',
  calendarTitle: '리듬 캘린더',
  reminders: '리마인더',
  reminderHeadline: '조용하게, 꾸준히',
  allLogs: '전체 기록',
  onboardingNext: '다음',
  onboardingLater: '나중에',
);

/// Fails immediately when a framework exception is pending.
void _assertNoException(WidgetTester tester, String stage) {
  final exception = tester.takeException();
  expect(
    exception,
    isNull,
    reason: 'Unexpected exception at $stage: $exception',
  );
}

/// Taps a list tile after scrolling it into view on compact screens.
Future<void> _tapListTileWithScroll(WidgetTester tester, String label) async {
  final tile = find.widgetWithText(ListTile, label);
  if (tile.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      tile,
      _scrollStep,
      scrollable: find.byType(Scrollable).first,
    );
  }

  await tester.ensureVisible(tile.first);
  await tester.tap(tile.first);
  await tester.pumpAndSettle();
}

/// Taps a text control after bringing it into view inside scrollable onboarding layouts.
Future<void> _tapTextControlWithScroll(
  WidgetTester tester,
  String label,
) async {
  final control = find.text(label);
  expect(control, findsOneWidget);

  await tester.ensureVisible(control.first);
  await tester.pumpAndSettle();
  await tester.tap(control.first);
  await tester.pumpAndSettle();
}

/// Scrolls lazily built content into view before asserting on it.
Future<void> _expectFinderVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    _scrollStep,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
  expect(finder, findsOneWidget);
}

/// Runs onboarding and core navigation assertions across locale/theme combinations.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const locales = <Locale>[Locale('en'), Locale('ko')];
  const themes = <AppThemePreference>[
    AppThemePreference.light,
    AppThemePreference.dark,
  ];

  testWidgets('onboarding + core navigation flow remains stable', (
    tester,
  ) async {
    var caseIndex = 0;
    for (final locale in locales) {
      final labels = locale.languageCode == 'ko' ? _ko : _en;

      for (final theme in themes) {
        caseIndex += 1;

        var completeCalls = 0;
        var skipCalls = 0;

        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: theme == AppThemePreference.dark
                ? ThemeMode.dark
                : ThemeMode.light,
            home: OnboardingScreen(
              initialExercise: ExerciseType.pushUp,
              onComplete: (_) async {
                completeCalls += 1;
              },
              onSkip: () async {
                skipCalls += 1;
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
        _assertNoException(tester, 'onboarding-initial-$caseIndex');

        expect(find.text(labels.onboardingNext), findsOneWidget);
        expect(find.text(labels.onboardingLater), findsOneWidget);

        await _tapTextControlWithScroll(tester, labels.onboardingNext);
        _assertNoException(tester, 'onboarding-complete-$caseIndex');
        expect(completeCalls, 1);
        expect(skipCalls, 0);

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
        await _expectFinderVisible(
          tester,
          find.byKey(const Key('quicklog.pushUp.record')),
        );

        await tester.tap(find.text(labels.calendar));
        await tester.pumpAndSettle();
        _assertNoException(tester, 'calendar-$caseIndex');
        expect(find.text(labels.calendarTitle), findsOneWidget);

        await tester.tap(find.text(labels.settings));
        await tester.pumpAndSettle();
        _assertNoException(tester, 'settings-$caseIndex');

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
  });
}
