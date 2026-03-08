import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:project_gtg/app/gtg_app.dart';
import 'package:project_gtg/core/external_link_launcher.dart';
import 'package:project_gtg/core/models/app_theme_preference.dart';
import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/reminder_settings.dart';
import 'package:project_gtg/core/models/user_preferences.dart';
import 'package:project_gtg/data/persistence/directory_provider.dart';
import 'package:project_gtg/data/persistence/gtg_persistence.dart';
import 'package:project_gtg/data/persistence/persistence_provider.dart';
import 'package:project_gtg/features/settings/settings_screen.dart';

import 'test_app.dart';

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
  AppThemePreference _themePreference = AppThemePreference.system;

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
  Future<AppThemePreference> loadAppThemePreference() async => _themePreference;

  @override
  Future<void> saveAppThemePreference(AppThemePreference preference) async {
    _themePreference = preference;
  }
}

class _FakeExternalLinkLauncher implements ExternalLinkLauncher {
  _FakeExternalLinkLauncher({required this.shouldLaunchSucceed});

  final bool shouldLaunchSucceed;
  int launchCount = 0;

  @override
  Future<bool> launch(Uri uri) async {
    launchCount++;
    return shouldLaunchSucceed;
  }
}

void main() {
  group('Settings screen', () {
    testWidgets('navigates to reminders and all logs', (tester) async {
      final persistence = _MemoryPersistence();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [persistenceProvider.overrideWithValue(persistence)],
          child: const GtgApp(locale: Locale('ko')),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('설정'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, '리마인더'));
      await tester.pumpAndSettle();
      expect(find.text('조용하게, 꾸준히'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, '전체 기록'));
      await tester.pumpAndSettle();
      expect(find.text('전체 기록'), findsOneWidget);
    });

    testWidgets('shows snackbar when privacy policy launch fails', (
      tester,
    ) async {
      final fakeLauncher = _FakeExternalLinkLauncher(
        shouldLaunchSucceed: false,
      );

      final persistence = _MemoryPersistence();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            persistenceProvider.overrideWithValue(persistence),
            externalLinkLauncherProvider.overrideWithValue(fakeLauncher),
          ],
          child: testApp(const Scaffold(body: SettingsScreen())),
        ),
      );
      await tester.pumpAndSettle();

      final privacyPolicyText = find.text('개인정보 처리방침');
      await tester.scrollUntilVisible(
        privacyPolicyText,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(privacyPolicyText);
      await tester.pumpAndSettle();

      expect(fakeLauncher.launchCount, 1);
      expect(find.text('브라우저를 열 수 없습니다.'), findsOneWidget);
    });

    testWidgets('theme options persist selection through settings tiles', (
      tester,
    ) async {
      final persistence = _MemoryPersistence();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [persistenceProvider.overrideWithValue(persistence)],
          child: testApp(const Scaffold(body: SettingsScreen())),
        ),
      );
      await tester.pumpAndSettle();

      expect(persistence._themePreference, AppThemePreference.system);
      expect(
        find.byKey(const Key('settings.theme.option.system')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('settings.theme.option.dark')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('settings.theme.option.dark')));
      await tester.pumpAndSettle();

      expect(persistence._themePreference, AppThemePreference.dark);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });
  });
}
