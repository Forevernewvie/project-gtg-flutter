import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_gtg/core/clock.dart';
import 'package:project_gtg/core/models/reminder_settings.dart';
import 'package:project_gtg/data/persistence/persistence_repositories.dart';
import 'package:project_gtg/features/reminders/reminder_planner.dart';
import 'package:project_gtg/features/reminders/services/reminder_message_provider.dart';
import 'package:project_gtg/features/reminders/services/reminder_notification_client.dart';
import 'package:project_gtg/features/reminders/services/reminder_permission_client.dart';
import 'package:project_gtg/features/reminders/state/reminder_controller.dart';
import 'package:project_gtg/features/reminders/state/reminder_dependencies.dart';

class _FixedClock implements Clock {
  const _FixedClock(this._now);

  final DateTime _now;

  @override
  DateTime now() => _now;
}

class _MemoryReminderSettingsRepository implements ReminderSettingsRepository {
  _MemoryReminderSettingsRepository(this._settings);

  ReminderSettings _settings;

  @override
  Future<ReminderSettings> loadReminderSettings() async => _settings;

  @override
  Future<void> saveReminderSettings(ReminderSettings settings) async {
    _settings = settings;
  }
}

class _StubReminderMessageProvider implements ReminderMessageProvider {
  const _StubReminderMessageProvider();

  @override
  Future<ReminderNotificationMessage> load() async {
    return const ReminderNotificationMessage(
      title: 'Time for a set',
      body: 'Log one set to keep your rhythm today.',
    );
  }
}

class _DelayedPermissionClient implements ReminderPermissionClient {
  _DelayedPermissionClient({required this.granted, required this.delay});

  final bool granted;
  final Duration delay;
  int hasPermissionCalls = 0;

  @override
  Future<bool> hasPermission() async {
    hasPermissionCalls += 1;
    await Future<void>.delayed(delay);
    return granted;
  }

  @override
  Future<bool> requestPermission() async {
    await Future<void>.delayed(delay);
    return granted;
  }
}

class _RecordingNotificationClient implements ReminderNotificationClient {
  _RecordingNotificationClient({required this.delay});

  final Duration delay;
  int cancelAllCalls = 0;
  int scheduleBatchCalls = 0;

  @override
  Future<void> cancelAll() async {
    cancelAllCalls += 1;
    await Future<void>.delayed(delay);
  }

  @override
  Future<void> scheduleBatch({
    required List<DateTime> times,
    required String title,
    required String body,
  }) async {
    scheduleBatchCalls += 1;
    await Future<void>.delayed(delay);
  }
}

void main() {
  test(
    'onAppForeground coalesces overlapping sync work to avoid duplicate scheduling',
    () async {
      final repository = _MemoryReminderSettingsRepository(
        const ReminderSettings(
          enabled: true,
          intervalMinutes: 60,
          quietStartMinutes: 23 * 60,
          quietEndMinutes: 7 * 60,
          skipWeekends: false,
          maxPerDay: 4,
        ),
      );
      final permissionClient = _DelayedPermissionClient(
        granted: true,
        delay: const Duration(milliseconds: 20),
      );
      final notificationClient = _RecordingNotificationClient(
        delay: const Duration(milliseconds: 20),
      );

      final container = ProviderContainer(
        overrides: [
          reminderSettingsRepositoryProvider.overrideWithValue(repository),
          reminderPermissionClientProvider.overrideWithValue(permissionClient),
          reminderNotificationClientProvider.overrideWithValue(
            notificationClient,
          ),
          reminderMessageProvider.overrideWithValue(
            const _StubReminderMessageProvider(),
          ),
          reminderPlannerProvider.overrideWithValue(const ReminderPlanner()),
          clockProvider.overrideWithValue(
            _FixedClock(DateTime(2026, 4, 20, 8)),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(reminderControllerProvider.future);
      expect(permissionClient.hasPermissionCalls, 1);
      expect(notificationClient.scheduleBatchCalls, 1);

      await Future.wait<void>([
        container.read(reminderControllerProvider.notifier).onAppForeground(),
        container.read(reminderControllerProvider.notifier).onAppForeground(),
      ]);

      expect(
        permissionClient.hasPermissionCalls,
        2,
        reason: 'foreground sync should reuse the in-flight permission check',
      );
      expect(
        notificationClient.scheduleBatchCalls,
        2,
        reason: 'foreground sync should only schedule once per resume burst',
      );
    },
  );
}
