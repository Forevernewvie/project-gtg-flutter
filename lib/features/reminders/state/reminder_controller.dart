import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/logging/logger_provider.dart';
import '../../../core/models/reminder_settings.dart';
import '../../../data/persistence/persistence_provider.dart';
import '../services/reminder_notification_client.dart';
import '../services/reminder_permission_client.dart';
import 'reminder_dependencies.dart';

final reminderControllerProvider =
    AsyncNotifierProvider<ReminderController, ReminderSettings>(
      ReminderController.new,
    );

class ReminderController extends AsyncNotifier<ReminderSettings> {
  /// Loads persisted settings and normalizes schedule state at startup.
  @override
  Future<ReminderSettings> build() async {
    final settings = await ref.read(persistenceProvider).loadReminderSettings();
    if (!settings.enabled) return settings;

    final hasPermission = await _permissionClient.hasPermission();
    if (!hasPermission) {
      return _disableAndClearSchedule(settings, reason: 'permission-revoked');
    }

    await _reschedule(settings);
    return settings;
  }

  /// Re-syncs reminder state when app returns to foreground.
  Future<void> onAppForeground() async {
    final current = state.asData?.value;
    if (current == null || !current.enabled) return;

    final hasPermission = await _permissionClient.hasPermission();
    if (!hasPermission) {
      await _disableAndClearSchedule(current, reason: 'permission-revoked');
      return;
    }

    await _reschedule(current);
  }

  /// Toggles reminder scheduling and handles permission workflow.
  Future<bool> setEnabled(bool enabled) async {
    final current = state.asData?.value ?? ReminderSettings.defaults;

    if (!enabled) {
      await _disableAndClearSchedule(current, reason: 'user-disabled');
      return true;
    }

    final granted = await _permissionClient.requestPermission();
    if (!granted) {
      await _disableAndClearSchedule(current, reason: 'permission-denied');
      return false;
    }

    final updated = current.copyWith(enabled: true);
    state = AsyncData(updated);
    await _persist(updated);
    await _reschedule(updated);
    return true;
  }

  /// Persists settings updates and refreshes/cancels schedules accordingly.
  Future<void> updateSettings(ReminderSettings updated) async {
    state = AsyncData(updated);
    await _persist(updated);

    if (updated.enabled) {
      await _reschedule(updated);
    } else {
      await _notificationClient.cancelAll();
    }
  }

  /// Plans and schedules the next batch of reminders.
  Future<void> _reschedule(ReminderSettings settings) async {
    try {
      final planner = ref.read(reminderPlannerProvider);
      final now = ref.read(clockProvider).now();
      final times = planner.planForToday(now: now, settings: settings);

      final message = await ref.read(reminderMessageProvider).load();

      await _notificationClient.scheduleBatch(
        times: times,
        title: message.title,
        body: message.body,
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to schedule reminder notifications.',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Applies a disabled state, persists it, and clears all pending reminders.
  Future<ReminderSettings> _disableAndClearSchedule(
    ReminderSettings current, {
    required String reason,
  }) async {
    final updated = current.copyWith(enabled: false);
    state = AsyncData(updated);
    await _persist(updated);
    await _notificationClient.cancelAll();
    _logger.info('Reminders disabled: $reason');
    return updated;
  }

  /// Persists settings and logs failures to aid debugging.
  Future<void> _persist(ReminderSettings settings) async {
    try {
      await ref.read(persistenceProvider).saveReminderSettings(settings);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to persist reminder settings.',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  ReminderNotificationClient get _notificationClient =>
      ref.read(reminderNotificationClientProvider);

  ReminderPermissionClient get _permissionClient =>
      ref.read(reminderPermissionClientProvider);

  AppLogger get _logger => ref.read(appLoggerProvider);
}
