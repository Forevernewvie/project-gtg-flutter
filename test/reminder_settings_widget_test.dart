import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:project_gtg/core/clock.dart';
import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/core/models/reminder_settings.dart';
import 'package:project_gtg/data/persistence/gtg_persistence.dart';
import 'package:project_gtg/data/persistence/persistence_provider.dart';
import 'package:project_gtg/features/reminders/presentation/screens/reminder_settings_screen.dart';
import 'package:project_gtg/features/reminders/services/reminder_notification_client.dart';
import 'package:project_gtg/features/reminders/services/reminder_permission_client.dart';
import 'package:project_gtg/features/reminders/state/reminder_dependencies.dart';

import 'test_app.dart';

void main() {
  void configureCompactAccessibleSurface(WidgetTester tester) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
  }

  void resetSurface(WidgetTester tester) {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  }

  testWidgets('enabling reminders requests permission and schedules', (
    tester,
  ) async {
    final persistence = _MemoryPersistence(
      reminderSettings: ReminderSettings.defaults,
    );
    final permission = _SpyPermissionClient(granted: true);
    final notifications = _SpyNotificationClient();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          persistenceProvider.overrideWithValue(persistence),
          reminderPermissionClientProvider.overrideWithValue(permission),
          reminderNotificationClientProvider.overrideWithValue(notifications),
          clockProvider.overrideWithValue(
            _FixedClock(DateTime(2026, 2, 15, 10, 0)),
          ),
        ],
        child: testApp(const ReminderSettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(permission.calls, 0);
    expect(notifications.scheduleCalls, 0);
    expect(notifications.cancelCalls, 0);

    await tester.tap(find.byKey(const Key('reminders.enabledSwitch')));
    await tester.pumpAndSettle();

    expect(permission.calls, 1);
    expect(notifications.scheduleCalls, 1);

    await tester.tap(find.byKey(const Key('reminders.enabledSwitch')));
    await tester.pumpAndSettle();

    expect(notifications.cancelCalls, 1);
  });

  testWidgets('permission denied keeps reminders off and shows snackbar', (
    tester,
  ) async {
    final persistence = _MemoryPersistence(
      reminderSettings: ReminderSettings.defaults,
    );
    final permission = _SpyPermissionClient(granted: false);
    final notifications = _SpyNotificationClient();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          persistenceProvider.overrideWithValue(persistence),
          reminderPermissionClientProvider.overrideWithValue(permission),
          reminderNotificationClientProvider.overrideWithValue(notifications),
          clockProvider.overrideWithValue(
            _FixedClock(DateTime(2026, 2, 15, 10, 0)),
          ),
        ],
        child: testApp(const ReminderSettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('reminders.enabledSwitch')));
    await tester.pumpAndSettle();

    expect(permission.calls, 1);
    expect(notifications.scheduleCalls, 0);
    expect(notifications.cancelCalls, 1);
    expect(find.text('알림 권한이 필요합니다. 설정에서 허용해주세요.'), findsOneWidget);
  });

  testWidgets('revoked permission disables reminders on load', (tester) async {
    final persistence = _MemoryPersistence(
      reminderSettings: ReminderSettings.defaults.copyWith(enabled: true),
    );
    final permission = _SpyPermissionClient(granted: false);
    final notifications = _SpyNotificationClient();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          persistenceProvider.overrideWithValue(persistence),
          reminderPermissionClientProvider.overrideWithValue(permission),
          reminderNotificationClientProvider.overrideWithValue(notifications),
          clockProvider.overrideWithValue(
            _FixedClock(DateTime(2026, 2, 15, 10, 0)),
          ),
        ],
        child: testApp(const ReminderSettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(permission.hasCalls, 1);
    expect(notifications.cancelCalls, 1);
  });

  testWidgets('enable suggestion uses permission-gated switch path', (
    tester,
  ) async {
    final persistence = _MemoryPersistence(
      reminderSettings: ReminderSettings.defaults,
    );
    final permission = _SpyPermissionClient(granted: false);
    final notifications = _SpyNotificationClient();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          persistenceProvider.overrideWithValue(persistence),
          reminderPermissionClientProvider.overrideWithValue(permission),
          reminderNotificationClientProvider.overrideWithValue(notifications),
          clockProvider.overrideWithValue(
            _FixedClock(DateTime(2026, 4, 27, 14, 0)),
          ),
        ],
        child: testApp(const ReminderSettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('reminders.optimizationCard')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('reminders.optimizationApply')));
    await tester.pumpAndSettle();

    expect(permission.calls, 1);
    expect(persistence.reminderSettings.enabled, isFalse);
    expect(notifications.scheduleCalls, 0);
    expect(notifications.cancelCalls, 1);
  });

  testWidgets('shows log-based suggestion and applies it only when tapped', (
    tester,
  ) async {
    final persistence = _MemoryPersistence(
      reminderSettings: ReminderSettings.defaults.copyWith(
        enabled: true,
        intervalMinutes: 30,
        skipWeekends: true,
      ),
      logs: <ExerciseLog>[
        _log('a', DateTime(2026, 4, 24, 9)),
        _log('b', DateTime(2026, 4, 27, 12)),
      ],
    );
    final permission = _SpyPermissionClient(granted: true);
    final notifications = _SpyNotificationClient();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          persistenceProvider.overrideWithValue(persistence),
          reminderPermissionClientProvider.overrideWithValue(permission),
          reminderNotificationClientProvider.overrideWithValue(notifications),
          clockProvider.overrideWithValue(
            _FixedClock(DateTime(2026, 4, 27, 14, 0)),
          ),
        ],
        child: testApp(const ReminderSettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('reminders.optimizationCard')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('기록 기반 제안'), findsOneWidget);
    expect(find.textContaining('60분'), findsOneWidget);
    expect(persistence.reminderSettings.intervalMinutes, 30);

    await tester.tap(find.byKey(const Key('reminders.optimizationApply')));
    await tester.pumpAndSettle();

    expect(persistence.reminderSettings.intervalMinutes, 60);
  });

  testWidgets(
    'reminder settings stays usable on compact screens with large text',
    (tester) async {
      addTearDown(() => resetSurface(tester));
      configureCompactAccessibleSurface(tester);

      final persistence = _MemoryPersistence(
        reminderSettings: ReminderSettings.defaults.copyWith(enabled: true),
      );
      final permission = _SpyPermissionClient(granted: true);
      final notifications = _SpyNotificationClient();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            persistenceProvider.overrideWithValue(persistence),
            reminderPermissionClientProvider.overrideWithValue(permission),
            reminderNotificationClientProvider.overrideWithValue(notifications),
            clockProvider.overrideWithValue(
              _FixedClock(DateTime(2026, 2, 15, 10, 0)),
            ),
          ],
          child: testApp(const ReminderSettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('reminders.enabledSwitch')), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('조용한 시간'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('조용한 시간'), findsOneWidget);
      expect(find.text('주말 쉬기'), findsOneWidget);
    },
  );
}

class _FixedClock implements Clock {
  const _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

class _MemoryPersistence extends GtgPersistence {
  _MemoryPersistence({
    required ReminderSettings reminderSettings,
    List<ExerciseLog> logs = const <ExerciseLog>[],
  }) : _reminderSettings = reminderSettings,
       _logs = logs;

  ReminderSettings _reminderSettings;
  List<ExerciseLog> _logs;

  ReminderSettings get reminderSettings => _reminderSettings;

  @override
  Future<ReminderSettings> loadReminderSettings() async => _reminderSettings;

  @override
  Future<void> saveReminderSettings(ReminderSettings settings) async {
    _reminderSettings = settings;
  }

  @override
  Future<List<ExerciseLog>> loadLogs() async => _logs;

  @override
  Future<void> saveLogs(List<ExerciseLog> logs) async {
    _logs = logs;
  }
}

ExerciseLog _log(String id, DateTime timestamp) {
  return ExerciseLog(
    id: id,
    type: ExerciseType.pushUp,
    reps: 5,
    timestamp: timestamp,
  );
}

class _SpyPermissionClient implements ReminderPermissionClient {
  _SpyPermissionClient({required this.granted});

  final bool granted;
  int hasCalls = 0;
  int calls = 0;

  @override
  Future<bool> hasPermission() async {
    hasCalls++;
    return granted;
  }

  @override
  Future<bool> requestPermission() async {
    calls++;
    return granted;
  }
}

class _SpyNotificationClient implements ReminderNotificationClient {
  int cancelCalls = 0;
  int scheduleCalls = 0;

  @override
  Future<void> cancelAll() async {
    cancelCalls++;
  }

  @override
  Future<void> scheduleBatch({
    required List<DateTime> times,
    required String title,
    required String body,
  }) async {
    scheduleCalls++;
  }
}
