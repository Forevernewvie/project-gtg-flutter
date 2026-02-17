import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'package:project_gtg/app/gtg_app.dart';
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

class _FakeUrlLauncherPlatform extends UrlLauncherPlatform
    with MockPlatformInterfaceMixin {
  _FakeUrlLauncherPlatform({required this.shouldLaunchSucceed});

  final bool shouldLaunchSucceed;
  int launchCount = 0;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launch(
    String url, {
    required bool useSafariVC,
    required bool useWebView,
    required bool enableJavaScript,
    required bool enableDomStorage,
    required bool universalLinksOnly,
    required Map<String, String> headers,
    String? webOnlyWindowName,
  }) async {
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
      final originalLauncher = UrlLauncherPlatform.instance;
      final fakeLauncher = _FakeUrlLauncherPlatform(shouldLaunchSucceed: false);
      UrlLauncherPlatform.instance = fakeLauncher;
      addTearDown(() => UrlLauncherPlatform.instance = originalLauncher);

      await tester.pumpWidget(testApp(const Scaffold(body: SettingsScreen())));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, '개인정보 처리방침'));
      await tester.pumpAndSettle();

      expect(fakeLauncher.launchCount, 1);
      expect(find.text('브라우저를 열 수 없습니다.'), findsOneWidget);
    });
  });
}
