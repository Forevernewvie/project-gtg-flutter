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
import 'package:project_gtg/features/onboarding/onboarding_screen.dart';
import 'package:project_gtg/features/reminders/reminder_settings_screen.dart';
import 'package:project_gtg/features/settings/all_logs_screen.dart';
import 'package:project_gtg/l10n/app_localizations.dart';

class _DummyDirectoryProvider implements DirectoryProvider {
  @override
  Future<Directory> getApplicationSupportDirectory() async {
    return Directory('/tmp');
  }
}

class _MemoryPersistence extends GtgPersistence {
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
    required this.remindersTitle,
    required this.allLogsTitle,
    required this.onboardingNext,
    required this.onboardingLater,
    required this.today,
  });

  final String calendarTitle;
  final String remindersTitle;
  final String allLogsTitle;
  final String onboardingNext;
  final String onboardingLater;
  final String today;
}

const _enLabels = _LocalizedLabels(
  calendarTitle: 'Rhythm Calendar',
  remindersTitle: 'Reminders',
  allLogsTitle: 'All Logs',
  onboardingNext: 'Next',
  onboardingLater: 'Later',
  today: 'Today',
);

const _koLabels = _LocalizedLabels(
  calendarTitle: '리듬 캘린더',
  remindersTitle: '리마인더',
  allLogsTitle: '전체 기록',
  onboardingNext: '다음',
  onboardingLater: '나중에',
  today: '오늘',
);

const _viewports = <Size>[
  Size(320, 568),
  Size(360, 640),
  Size(390, 844),
  Size(412, 915),
  Size(768, 1024),
];

const _textScales = <double>[0.85, 1.0, 1.3, 1.6, 2.0];
const _locales = <Locale>[Locale('en'), Locale('ko')];
const _themePreferences = <AppThemePreference>[
  AppThemePreference.light,
  AppThemePreference.dark,
];

bool _isLayoutFailureMessage(String message) {
  final lower = message.toLowerCase();
  return lower.contains('a renderflex overflowed') ||
      lower.contains('overflowed by') ||
      lower.contains('was given an infinite size') ||
      lower.contains('renderbox was not laid out') ||
      lower.contains('pixel overflow') ||
      lower.contains('clipped');
}

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

Future<void> _expectNoOverflowErrors(
  WidgetTester tester,
  Future<void> Function() action, {
  required String stage,
}) async {
  final previousOnError = FlutterError.onError;
  final layoutErrors = <String>[];

  FlutterError.onError = (details) {
    final message = details.exceptionAsString();
    if (_isLayoutFailureMessage(message)) {
      layoutErrors.add(message);
    }
  };

  try {
    await action();
    await tester.pump();

    final exception = tester.takeException();
    if (exception != null) {
      final message = exception.toString();
      if (_isLayoutFailureMessage(message)) {
        fail('Layout failure at $stage: $message');
      }
      fail('Unexpected framework exception at $stage: $message');
    }

    expect(layoutErrors, isEmpty, reason: 'Layout errors at $stage');
  } finally {
    FlutterError.onError = previousOnError;
  }
}

Future<void> _captureAndAssertScreenshot(
  WidgetTester tester,
  Key boundaryKey,
) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(boundaryKey),
  );
  final image = await boundary.toImage(pixelRatio: 1.0);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  expect(data, isNotNull);
  expect(data!.lengthInBytes, greaterThan(0));
}

Widget _standaloneScreen({
  required Locale locale,
  required AppThemePreference themePreference,
  required GtgPersistence persistence,
  required Widget screen,
}) {
  return ProviderScope(
    overrides: [persistenceProvider.overrideWithValue(persistence)],
    child: MaterialApp(
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

void main() {
  testWidgets(
    'core screens stay layout-safe across viewport/text/locale/theme matrix',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
        tester.platformDispatcher.clearPlatformBrightnessTestValue();
      });

      var caseIndex = 0;
      for (final locale in _locales) {
        final labels = locale.languageCode == 'ko' ? _koLabels : _enLabels;

        for (final themePreference in _themePreferences) {
          for (final viewport in _viewports) {
            for (final textScale in _textScales) {
              caseIndex += 1;
              final caseTag =
                  'case-$caseIndex-${locale.languageCode}-${themePreference.name}-${viewport.width}x${viewport.height}-x$textScale';

              tester.view.devicePixelRatio = 1.0;
              tester.view.physicalSize = viewport;
              tester.platformDispatcher.textScaleFactorTestValue = textScale;
              tester.platformDispatcher.platformBrightnessTestValue =
                  themePreference == AppThemePreference.dark
                  ? Brightness.dark
                  : Brightness.light;

              final persistence = _MemoryPersistence(
                themePreference: themePreference,
                onboardingCompleted: true,
              );

              await _expectNoOverflowErrors(tester, () async {
                await tester.pumpWidget(
                  ProviderScope(
                    overrides: [
                      persistenceProvider.overrideWithValue(persistence),
                    ],
                    child: GtgApp(key: ValueKey(caseTag), locale: locale),
                  ),
                );
              }, stage: '$caseTag-home');
              expect(
                find.byKey(const Key('dashboard.todayTotalValue')),
                findsAtLeastNWidgets(1),
              );

              await _expectNoOverflowErrors(
                tester,
                () => _tapNavigationDestination(
                  tester,
                  Icons.calendar_month_rounded,
                ),
                stage: '$caseTag-calendar',
              );
              expect(find.text(labels.calendarTitle), findsAtLeastNWidgets(1));
              expect(find.text(labels.today), findsAtLeastNWidgets(1));

              await _expectNoOverflowErrors(tester, () async {
                await tester.pumpWidget(
                  _standaloneScreen(
                    locale: locale,
                    themePreference: themePreference,
                    persistence: persistence,
                    screen: const ReminderSettingsScreen(),
                  ),
                );
              }, stage: '$caseTag-reminders-screen');
              expect(
                find.byKey(const Key('reminders.enabledSwitch')),
                findsAtLeastNWidgets(1),
              );

              await _expectNoOverflowErrors(tester, () async {
                await tester.pumpWidget(
                  _standaloneScreen(
                    locale: locale,
                    themePreference: themePreference,
                    persistence: persistence,
                    screen: const AllLogsScreen(),
                  ),
                );
              }, stage: '$caseTag-all-logs-screen');
              expect(find.text(labels.allLogsTitle), findsAtLeastNWidgets(1));

              _assertNoUnexpectedException(tester, stage: '$caseTag-final');
            }
          }
        }
      }
    },
  );

  testWidgets(
    'onboarding stays layout-safe across viewport/text/locale/theme matrix',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
        tester.platformDispatcher.clearPlatformBrightnessTestValue();
      });

      var caseIndex = 0;
      for (final locale in _locales) {
        final labels = locale.languageCode == 'ko' ? _koLabels : _enLabels;

        for (final themePreference in _themePreferences) {
          for (final viewport in _viewports) {
            for (final textScale in _textScales) {
              caseIndex += 1;
              final caseTag =
                  'onboarding-$caseIndex-${locale.languageCode}-${themePreference.name}-${viewport.width}x${viewport.height}-x$textScale';

              tester.view.devicePixelRatio = 1.0;
              tester.view.physicalSize = viewport;
              tester.platformDispatcher.textScaleFactorTestValue = textScale;
              tester.platformDispatcher.platformBrightnessTestValue =
                  themePreference == AppThemePreference.dark
                  ? Brightness.dark
                  : Brightness.light;

              var completeCalls = 0;
              var skipCalls = 0;

              await _expectNoOverflowErrors(tester, () async {
                await tester.pumpWidget(
                  MaterialApp(
                    locale: locale,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    theme: ThemeData.light(),
                    darkTheme: ThemeData.dark(),
                    themeMode: themePreference == AppThemePreference.dark
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
    },
  );

  testWidgets('critical scales produce valid screenshots for key screens', (
    tester,
  ) async {
    const screenshotBoundaryKey = Key('qa.screenshotBoundary');

    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    tester.platformDispatcher.textScaleFactorTestValue = 1.0;
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
      tester.platformDispatcher.clearPlatformBrightnessTestValue();
    });

    final persistence = _MemoryPersistence(
      themePreference: AppThemePreference.dark,
      onboardingCompleted: true,
    );

    await tester.pumpWidget(
      RepaintBoundary(
        key: screenshotBoundaryKey,
        child: ProviderScope(
          overrides: [persistenceProvider.overrideWithValue(persistence)],
          child: const GtgApp(locale: Locale('en')),
        ),
      ),
    );
    await tester.pump();

    _assertNoUnexpectedException(tester, stage: 'screenshot-home-dark-x1.0');
    await _captureAndAssertScreenshot(tester, screenshotBoundaryKey);
  }, skip: true);
}
