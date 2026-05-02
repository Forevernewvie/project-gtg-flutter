import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import 'package:project_gtg/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:project_gtg/features/reminders/presentation/screens/reminder_settings_screen.dart';
import 'package:project_gtg/features/settings/presentation/screens/all_logs_screen.dart';
import 'package:project_gtg/l10n/app_localizations.dart';

const _tempDirPath = '/tmp';
const _scrollStep = 220.0;
const _maxScrollAttempts = 25;
const _surfaceSettleDuration = Duration(milliseconds: 50);
const _screenshotPixelRatio = 1.0;

/// Directory provider test double that avoids platform channel calls in widget tests.
class _DummyDirectoryProvider implements DirectoryProvider {
  @override
  Future<Directory> getApplicationSupportDirectory() async {
    return Directory(_tempDirPath);
  }
}

class _MemoryPersistence extends GtgPersistence {
  /// In-memory persistence double to keep matrix tests deterministic and fast.
  _MemoryPersistence({
    required AppThemePreference themePreference,
    required bool onboardingCompleted,
  }) : _themePreference = themePreference,
       _prefs = UserPreferences(
         hasCompletedOnboarding: onboardingCompleted,
         primaryExercise: ExerciseType.pushUp,
       ),
       super(directoryProvider: _DummyDirectoryProvider());

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
  AppThemePreference _themePreference;
  UserPreferences _prefs;

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

class _LocalizedLabels {
  const _LocalizedLabels({
    required this.calendarTitle,
    required this.today,
    required this.remindersTitle,
    required this.allLogsTitle,
    required this.privacyPolicyTitle,
    required this.settingsThemeSystem,
    required this.settingsThemeLight,
    required this.settingsThemeDark,
    required this.enableRemindersTitle,
    required this.intervalLabel,
    required this.maxPerDayLabel,
    required this.quietHoursTitle,
    required this.weekendsOffTitle,
    required this.onboardingNext,
    required this.onboardingLater,
  });

  final String calendarTitle;
  final String today;
  final String remindersTitle;
  final String allLogsTitle;
  final String privacyPolicyTitle;
  final String settingsThemeSystem;
  final String settingsThemeLight;
  final String settingsThemeDark;
  final String enableRemindersTitle;
  final String intervalLabel;
  final String maxPerDayLabel;
  final String quietHoursTitle;
  final String weekendsOffTitle;
  final String onboardingNext;
  final String onboardingLater;
}

const _enLabels = _LocalizedLabels(
  calendarTitle: 'Rhythm Calendar',
  today: 'Today',
  remindersTitle: 'Reminders',
  allLogsTitle: 'All Logs',
  privacyPolicyTitle: 'Privacy Policy',
  settingsThemeSystem: 'System',
  settingsThemeLight: 'Light',
  settingsThemeDark: 'Dark',
  enableRemindersTitle: 'Enable reminders',
  intervalLabel: 'Interval',
  maxPerDayLabel: 'Max per day',
  quietHoursTitle: 'Quiet hours',
  weekendsOffTitle: 'Weekends off',
  onboardingNext: 'Next',
  onboardingLater: 'Later',
);

const _koLabels = _LocalizedLabels(
  calendarTitle: '리듬 캘린더',
  today: '오늘',
  remindersTitle: '리마인더',
  allLogsTitle: '전체 기록',
  privacyPolicyTitle: '개인정보 처리방침',
  settingsThemeSystem: '시스템',
  settingsThemeLight: '라이트',
  settingsThemeDark: '다크',
  enableRemindersTitle: '리마인더 켜기',
  intervalLabel: '반복 간격',
  maxPerDayLabel: '하루 최대',
  quietHoursTitle: '조용한 시간',
  weekendsOffTitle: '주말 쉬기',
  onboardingNext: '다음',
  onboardingLater: '나중에',
);

const _viewports = <Size>[
  Size(320, 568),
  Size(360, 640),
  Size(390, 844),
  Size(412, 915),
  Size(768, 1024),
  Size(360, 382),
  Size(884, 1104),
  Size(1104, 884),
];

const _screenshotViewports = <Size>[Size(360, 640), Size(768, 1024)];
const _textScales = <double>[0.85, 1.0, 1.3, 1.6, 2.0];
const _screenshotScales = <double>[1.0, 1.6];
const _persistedCompatibilityThemes = <AppThemePreference>[
  AppThemePreference.light,
  AppThemePreference.dark,
];

/// Matches framework layout error phrases that represent overflow/clipping regressions.
bool _isLayoutFailureMessage(String message) {
  final lower = message.toLowerCase();
  return lower.contains('a renderflex overflowed') ||
      lower.contains('overflowed by') ||
      lower.contains('was given an infinite size') ||
      lower.contains('renderbox was not laid out') ||
      lower.contains('pixel overflow') ||
      lower.contains('clipped');
}

/// Asserts there are no pending framework exceptions after a test step.
void _assertNoUnexpectedException(
  WidgetTester tester, {
  required String stage,
}) {
  final exception = tester.takeException();
  expect(
    exception,
    isNull,
    reason: 'Unexpected framework exception at $stage: $exception',
  );
}

/// Taps bottom navigation by icon using a hit-testable target when available.
Future<void> _tapNavigationDestination(
  WidgetTester tester,
  IconData icon,
) async {
  final destination = find.byIcon(icon);
  final hitTestable = destination.hitTestable();
  final target = hitTestable.evaluate().isNotEmpty ? hitTestable : destination;

  await tester.tap(target.last);
  await tester.pump();
}

/// Scrolls until the target is built/visible, then verifies it can be interacted with.
Future<void> _ensureVisibleWithScroll(
  WidgetTester tester,
  Finder target, {
  required String stage,
}) async {
  if (target.evaluate().isEmpty) {
    for (
      var i = 0;
      i < _maxScrollAttempts && target.evaluate().isEmpty;
      i += 1
    ) {
      final scrollables = find.byType(Scrollable);
      if (scrollables.evaluate().isEmpty) {
        break;
      }
      await tester.drag(scrollables.first, const Offset(0, -_scrollStep));
      await tester.pump();
    }
  }

  expect(
    target,
    findsAtLeastNWidgets(1),
    reason: 'Expected visible target at $stage',
  );
  await tester.ensureVisible(target.first);
  await tester.pump();
}

/// Executes an action while converting Flutter layout errors into hard test failures.
Future<void> _expectNoOverflowErrors(
  WidgetTester tester,
  Future<void> Function() action, {
  required String stage,
}) async {
  final previousOnError = FlutterError.onError;
  final layoutErrors = <String>[];

  FlutterError.onError = (details) {
    final message = details.exceptionAsString();
    final detailText = details.toString();
    if (_isLayoutFailureMessage(message) ||
        _isLayoutFailureMessage(detailText)) {
      layoutErrors.add(detailText);
    }
  };

  try {
    await action();
    await tester.pump();

    final exception = tester.takeException();
    if (exception != null) {
      final message = exception.toString();
      if (_isLayoutFailureMessage(message)) {
        final details = layoutErrors.isEmpty
            ? message
            : layoutErrors.join('\n\n');
        fail('Layout failure at $stage:\n$details');
      }
      fail('Unexpected framework exception at $stage: $message');
    }

    expect(
      layoutErrors,
      isEmpty,
      reason: layoutErrors.isEmpty
          ? 'Layout errors at $stage'
          : 'Layout errors at $stage:\n${layoutErrors.join('\n\n')}',
    );
  } finally {
    FlutterError.onError = previousOnError;
  }
}

/// Captures a repaint boundary image and validates non-empty bytes for smoke coverage.
Future<void> _captureAndAssertScreenshot(
  WidgetTester tester,
  Key boundaryKey,
) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(boundaryKey),
  );
  final image = await boundary.toImage(pixelRatio: _screenshotPixelRatio);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  expect(data, isNotNull);
  image.dispose();
  expect(data!.lengthInBytes, greaterThan(0));
}

/// Builds a standalone app shell around a single screen for focused matrix checks.
Widget _standaloneScreen({
  required Locale locale,
  required AppThemePreference themePreference,
  required GtgPersistence persistence,
  required Widget screen,
  required String keyTag,
}) {
  return ProviderScope(
    overrides: [persistenceProvider.overrideWithValue(persistence)],
    child: MaterialApp(
      key: ValueKey(keyTag),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themePreference == AppThemePreference.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      home: screen,
    ),
  );
}

/// Applies viewport/text-scale/brightness settings for one matrix case.
void _configureTestSurface(
  WidgetTester tester, {
  required Size viewport,
  required double textScale,
  required Brightness brightness,
}) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = viewport;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  tester.platformDispatcher.platformBrightnessTestValue = brightness;
}

/// Restores test surface defaults after each matrix run.
void _resetTestSurface(WidgetTester tester) {
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
  tester.platformDispatcher.clearTextScaleFactorTestValue();
  tester.platformDispatcher.clearPlatformBrightnessTestValue();
}

/// Runs home/calendar/settings/reminder/history matrix assertions for one locale.
Future<void> _runCoreMatrixForLocale(
  WidgetTester tester, {
  required Locale locale,
  required _LocalizedLabels labels,
}) async {
  var caseIndex = 0;

  for (final themePreference in _persistedCompatibilityThemes) {
    for (final viewport in _viewports) {
      for (final textScale in _textScales) {
        caseIndex += 1;
        final caseTag =
            'core-${locale.languageCode}-$caseIndex-${themePreference.name}-${viewport.width}x${viewport.height}-x$textScale';

        _configureTestSurface(
          tester,
          viewport: viewport,
          textScale: textScale,
          brightness: themePreference == AppThemePreference.dark
              ? Brightness.dark
              : Brightness.light,
        );

        final persistence = _MemoryPersistence(
          themePreference: themePreference,
          onboardingCompleted: true,
        );

        await _expectNoOverflowErrors(tester, () async {
          await tester.pumpWidget(
            ProviderScope(
              overrides: [persistenceProvider.overrideWithValue(persistence)],
              child: GtgApp(key: ValueKey(caseTag), locale: locale),
            ),
          );
        }, stage: '$caseTag-home');

        await tester.pumpAndSettle(_surfaceSettleDuration);
        final nav = find.byType(NavigationBar).first;
        expect(Theme.of(tester.element(nav)).brightness, Brightness.dark);
        expect(
          find.byKey(const Key('dashboard.todayTotalValue')),
          findsAtLeastNWidgets(1),
        );
        await _ensureVisibleWithScroll(
          tester,
          find.byKey(const Key('quicklog.pushUp.record')),
          stage: '$caseTag-home-quicklog-pushup',
        );
        await _ensureVisibleWithScroll(
          tester,
          find.byKey(const Key('quicklog.pullUp.record')),
          stage: '$caseTag-home-quicklog-pullup',
        );
        await _ensureVisibleWithScroll(
          tester,
          find.byKey(const Key('quicklog.dips.record')),
          stage: '$caseTag-home-quicklog-dips',
        );

        await _expectNoOverflowErrors(
          tester,
          () => _tapNavigationDestination(tester, Icons.calendar_month_rounded),
          stage: '$caseTag-calendar',
        );
        expect(find.text(labels.calendarTitle), findsAtLeastNWidgets(1));
        expect(find.text(labels.today), findsAtLeastNWidgets(1));
        await _ensureVisibleWithScroll(
          tester,
          find.byKey(const Key('calendar.selectedDateLabel')),
          stage: '$caseTag-calendar-selected-day',
        );

        await _expectNoOverflowErrors(
          tester,
          () => _tapNavigationDestination(tester, Icons.tune_rounded),
          stage: '$caseTag-settings',
        );
        expect(find.text(labels.remindersTitle), findsAtLeastNWidgets(1));
        expect(find.text(labels.allLogsTitle), findsAtLeastNWidgets(1));
        expect(find.text(labels.settingsThemeSystem), findsNothing);
        expect(find.text(labels.settingsThemeLight), findsNothing);
        expect(find.text(labels.settingsThemeDark), findsNothing);
        expect(find.byKey(const Key('settings.theme.segmented')), findsNothing);
        await _ensureVisibleWithScroll(
          tester,
          find.text(labels.privacyPolicyTitle),
          stage: '$caseTag-settings-privacy',
        );

        await _expectNoOverflowErrors(tester, () async {
          await tester.pumpWidget(
            _standaloneScreen(
              locale: locale,
              themePreference: themePreference,
              persistence: persistence,
              screen: const ReminderSettingsScreen(),
              keyTag: '$caseTag-reminder-standalone',
            ),
          );
          await tester.pumpAndSettle(_surfaceSettleDuration);
        }, stage: '$caseTag-reminder-screen');

        await _expectNoOverflowErrors(
          tester,
          () => _ensureVisibleWithScroll(
            tester,
            find.byKey(const Key('reminders.enabledSwitch')),
            stage: '$caseTag-reminders-enabled-switch',
          ),
          stage: '$caseTag-reminders-enabled-switch-check',
        );
        await _expectNoOverflowErrors(
          tester,
          () => _ensureVisibleWithScroll(
            tester,
            find.text(labels.enableRemindersTitle),
            stage: '$caseTag-reminders-enable',
          ),
          stage: '$caseTag-reminders-enable-check',
        );
        await _expectNoOverflowErrors(
          tester,
          () => _ensureVisibleWithScroll(
            tester,
            find.text(labels.intervalLabel),
            stage: '$caseTag-reminders-interval',
          ),
          stage: '$caseTag-reminders-interval-check',
        );
        await _expectNoOverflowErrors(
          tester,
          () => _ensureVisibleWithScroll(
            tester,
            find.text(labels.maxPerDayLabel),
            stage: '$caseTag-reminders-max',
          ),
          stage: '$caseTag-reminders-max-check',
        );
        await _expectNoOverflowErrors(
          tester,
          () => _ensureVisibleWithScroll(
            tester,
            find.text(labels.quietHoursTitle),
            stage: '$caseTag-reminders-quiet-hours',
          ),
          stage: '$caseTag-reminders-quiet-hours-check',
        );
        await _expectNoOverflowErrors(
          tester,
          () => _ensureVisibleWithScroll(
            tester,
            find.text(labels.weekendsOffTitle),
            stage: '$caseTag-reminders-weekends-off',
          ),
          stage: '$caseTag-reminders-weekends-off-check',
        );

        await _expectNoOverflowErrors(tester, () async {
          await tester.pumpWidget(
            _standaloneScreen(
              locale: locale,
              themePreference: themePreference,
              persistence: persistence,
              keyTag: '$caseTag-all-logs-standalone',
              screen: const AllLogsScreen(),
            ),
          );
          await tester.pumpAndSettle(_surfaceSettleDuration);
        }, stage: '$caseTag-all-logs-screen');

        expect(find.text(labels.allLogsTitle), findsAtLeastNWidgets(1));
        _assertNoUnexpectedException(tester, stage: '$caseTag-final');
      }
    }
  }
}

/// Runs onboarding matrix assertions for one locale.
Future<void> _runOnboardingMatrixForLocale(
  WidgetTester tester, {
  required Locale locale,
  required _LocalizedLabels labels,
}) async {
  var caseIndex = 0;

  for (final themePreference in _persistedCompatibilityThemes) {
    for (final viewport in _viewports) {
      for (final textScale in _textScales) {
        caseIndex += 1;
        final caseTag =
            'onboarding-${locale.languageCode}-$caseIndex-${themePreference.name}-${viewport.width}x${viewport.height}-x$textScale';

        _configureTestSurface(
          tester,
          viewport: viewport,
          textScale: textScale,
          brightness: themePreference == AppThemePreference.dark
              ? Brightness.dark
              : Brightness.light,
        );

        var completeCalls = 0;
        var skipCalls = 0;

        await _expectNoOverflowErrors(tester, () async {
          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              themeMode: themePreference == AppThemePreference.dark
                  ? ThemeMode.dark
                  : ThemeMode.light,
              home: OnboardingScreen(
                initialExercise: ExerciseType.pushUp,
                onComplete:
                    ({
                      required primaryExercise,
                      required primaryExerciseMaxReps,
                    }) async {
                      completeCalls += 1;
                    },
                onSkip: () async {
                  skipCalls += 1;
                },
              ),
            ),
          );
        }, stage: '$caseTag-initial');

        expect(find.text(labels.onboardingNext), findsOneWidget);
        expect(find.text(labels.onboardingLater), findsOneWidget);

        await _expectNoOverflowErrors(tester, () async {
          final nextButton = find.text(labels.onboardingNext);
          await tester.ensureVisible(nextButton);
          await tester.tap(nextButton);
        }, stage: '$caseTag-next');

        expect(completeCalls, 1);
        expect(skipCalls, 0);
        _assertNoUnexpectedException(tester, stage: '$caseTag-final');
      }
    }
  }
}

/// Verifies the app remains dark across platform brightness combinations.
Future<void> _runForcedDarkThemeMatrixForLocale(
  WidgetTester tester, {
  required Locale locale,
}) async {
  const brightnesses = <Brightness>[Brightness.light, Brightness.dark];
  var caseIndex = 0;

  for (final brightness in brightnesses) {
    for (final viewport in _viewports) {
      for (final textScale in _textScales) {
        caseIndex += 1;
        final caseTag =
            'forced-dark-${locale.languageCode}-$caseIndex-${brightness.name}-${viewport.width}x${viewport.height}-x$textScale';

        _configureTestSurface(
          tester,
          viewport: viewport,
          textScale: textScale,
          brightness: brightness,
        );

        final persistence = _MemoryPersistence(
          themePreference: AppThemePreference.system,
          onboardingCompleted: true,
        );

        await _expectNoOverflowErrors(tester, () async {
          await tester.pumpWidget(
            ProviderScope(
              overrides: [persistenceProvider.overrideWithValue(persistence)],
              child: GtgApp(key: ValueKey(caseTag), locale: locale),
            ),
          );
        }, stage: '$caseTag-home');

        final nav = find.byType(NavigationBar).first;
        final effectiveBrightness = Theme.of(tester.element(nav)).brightness;
        expect(effectiveBrightness, Brightness.dark);
        _assertNoUnexpectedException(tester, stage: '$caseTag-final');
      }
    }
  }
}

/// Runs screenshot smoke capture flow for key screens when environment supports it.
Future<void> _runScreenshotSmokeForLocale(
  WidgetTester tester, {
  required Locale locale,
  required _LocalizedLabels labels,
}) async {
  const screenshotBoundaryKey = Key('qa.screenshotBoundary');

  for (final viewport in _screenshotViewports) {
    for (final scale in _screenshotScales) {
      final caseTag =
          'shot-${locale.languageCode}-${viewport.width}x${viewport.height}-x$scale';

      _configureTestSurface(
        tester,
        viewport: viewport,
        textScale: scale,
        brightness: Brightness.light,
      );

      final persistence = _MemoryPersistence(
        themePreference: AppThemePreference.light,
        onboardingCompleted: true,
      );

      await _expectNoOverflowErrors(tester, () async {
        await tester.pumpWidget(
          RepaintBoundary(
            key: screenshotBoundaryKey,
            child: ProviderScope(
              overrides: [persistenceProvider.overrideWithValue(persistence)],
              child: GtgApp(key: ValueKey(caseTag), locale: locale),
            ),
          ),
        );
      }, stage: '$caseTag-home');

      await _captureAndAssertScreenshot(tester, screenshotBoundaryKey);

      await _expectNoOverflowErrors(
        tester,
        () => _tapNavigationDestination(tester, Icons.calendar_month_rounded),
        stage: '$caseTag-calendar',
      );
      expect(find.text(labels.calendarTitle), findsAtLeastNWidgets(1));
      await _captureAndAssertScreenshot(tester, screenshotBoundaryKey);

      await _expectNoOverflowErrors(
        tester,
        () => _tapNavigationDestination(tester, Icons.tune_rounded),
        stage: '$caseTag-settings',
      );
      expect(find.text(labels.remindersTitle), findsAtLeastNWidgets(1));
      await _captureAndAssertScreenshot(tester, screenshotBoundaryKey);
    }
  }
}

void main() {
  testWidgets('core screens matrix EN (persisted theme compatibility)', (
    tester,
  ) async {
    addTearDown(() => _resetTestSurface(tester));
    await _runCoreMatrixForLocale(
      tester,
      locale: const Locale('en'),
      labels: _enLabels,
    );
  });

  testWidgets('core screens matrix KO (persisted theme compatibility)', (
    tester,
  ) async {
    addTearDown(() => _resetTestSurface(tester));
    await _runCoreMatrixForLocale(
      tester,
      locale: const Locale('ko'),
      labels: _koLabels,
    );
  });

  testWidgets('onboarding matrix EN (light/dark preview)', (tester) async {
    addTearDown(() => _resetTestSurface(tester));
    await _runOnboardingMatrixForLocale(
      tester,
      locale: const Locale('en'),
      labels: _enLabels,
    );
  });

  testWidgets('onboarding matrix KO (light/dark preview)', (tester) async {
    addTearDown(() => _resetTestSurface(tester));
    await _runOnboardingMatrixForLocale(
      tester,
      locale: const Locale('ko'),
      labels: _koLabels,
    );
  });

  testWidgets('app stays dark across platform brightness EN', (tester) async {
    addTearDown(() => _resetTestSurface(tester));
    await _runForcedDarkThemeMatrixForLocale(
      tester,
      locale: const Locale('en'),
    );
  });

  testWidgets('app stays dark across platform brightness KO', (tester) async {
    addTearDown(() => _resetTestSurface(tester));
    await _runForcedDarkThemeMatrixForLocale(
      tester,
      locale: const Locale('ko'),
    );
  });

  testWidgets('screenshot smoke EN (compact+large, x1.0/x1.6)', (tester) async {
    addTearDown(() => _resetTestSurface(tester));
    await _runScreenshotSmokeForLocale(
      tester,
      locale: const Locale('en'),
      labels: _enLabels,
    );
  }, skip: true);

  testWidgets('screenshot smoke KO (compact+large, x1.0/x1.6)', (tester) async {
    addTearDown(() => _resetTestSurface(tester));
    await _runScreenshotSmokeForLocale(
      tester,
      locale: const Locale('ko'),
      labels: _koLabels,
    );
  }, skip: true);
}
