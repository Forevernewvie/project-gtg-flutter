import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:project_gtg/core/clock.dart';
import 'package:project_gtg/core/models/reminder_settings.dart';
import 'package:project_gtg/data/persistence/gtg_persistence.dart';
import 'package:project_gtg/data/persistence/persistence_provider.dart';
import 'package:project_gtg/features/reminders/reminder_settings_screen.dart';
import 'package:project_gtg/features/reminders/services/reminder_notification_client.dart';
import 'package:project_gtg/features/reminders/services/reminder_permission_client.dart';
import 'package:project_gtg/features/reminders/state/reminder_dependencies.dart';

import 'test_app.dart';

void main() {
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
}

class _FixedClock implements Clock {
  const _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

class _MemoryPersistence extends GtgPersistence {
  _MemoryPersistence({required ReminderSettings reminderSettings})
    : _reminderSettings = reminderSettings;

  ReminderSettings _reminderSettings;

  @override
  Future<ReminderSettings> loadReminderSettings() async => _reminderSettings;

  @override
  Future<void> saveReminderSettings(ReminderSettings settings) async {
    _reminderSettings = settings;
  }
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
