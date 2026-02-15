import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';

import '../../../core/clock.dart';
import '../../../core/models/reminder_settings.dart';
import '../../../data/persistence/persistence_provider.dart';
import '../../../l10n/app_localizations.dart';
import 'reminder_dependencies.dart';

final reminderControllerProvider =
    AsyncNotifierProvider<ReminderController, ReminderSettings>(
      ReminderController.new,
    );

class ReminderController extends AsyncNotifier<ReminderSettings> {
  @override
  Future<ReminderSettings> build() async {
    final persistence = ref.read(persistenceProvider);
    final settings = await persistence.loadReminderSettings();

    // If reminders are enabled, refresh today's schedule on app load.
    if (settings.enabled) {
      final hasPermission = await ref
          .read(reminderPermissionClientProvider)
          .hasPermission();
      if (!hasPermission) {
        final updated = settings.copyWith(enabled: false);
        await persistence.saveReminderSettings(updated);
        await ref.read(reminderNotificationClientProvider).cancelAll();
        return updated;
      }

      await _reschedule(settings);
    }

    return settings;
  }

  /// Called when the app returns to foreground.
  ///
  /// Keeps reminder state in sync when users toggle permissions in iOS Settings.
  Future<void> onAppForeground() async {
    final current = state.asData?.value;
    if (current == null || !current.enabled) return;

    final hasPermission = await ref
        .read(reminderPermissionClientProvider)
        .hasPermission();
    if (!hasPermission) {
      final updated = current.copyWith(enabled: false);
      state = AsyncData(updated);
      await ref.read(persistenceProvider).saveReminderSettings(updated);
      await ref.read(reminderNotificationClientProvider).cancelAll();
      return;
    }

    await _reschedule(current);
  }

  Future<bool> setEnabled(bool enabled) async {
    final current = state.asData?.value ?? ReminderSettings.defaults;

    if (!enabled) {
      final updated = current.copyWith(enabled: false);
      state = AsyncData(updated);
      await ref.read(persistenceProvider).saveReminderSettings(updated);
      await ref.read(reminderNotificationClientProvider).cancelAll();
      return true;
    }

    final granted = await ref
        .read(reminderPermissionClientProvider)
        .requestPermission();
    if (!granted) {
      final updated = current.copyWith(enabled: false);
      state = AsyncData(updated);
      await ref.read(persistenceProvider).saveReminderSettings(updated);
      await ref.read(reminderNotificationClientProvider).cancelAll();
      return false;
    }

    final updated = current.copyWith(enabled: true);
    state = AsyncData(updated);
    await ref.read(persistenceProvider).saveReminderSettings(updated);
    await _reschedule(updated);
    return true;
  }

  Future<void> updateSettings(ReminderSettings updated) async {
    state = AsyncData(updated);
    await ref.read(persistenceProvider).saveReminderSettings(updated);

    if (updated.enabled) {
      await _reschedule(updated);
    }
  }

  Future<void> _reschedule(ReminderSettings settings) async {
    final planner = ref.read(reminderPlannerProvider);
    final now = ref.read(clockProvider).now();
    final times = planner.planForToday(now: now, settings: settings);

    final (title, body) = await _loadNotificationStrings();

    await ref
        .read(reminderNotificationClientProvider)
        .scheduleBatch(times: times, title: title, body: body);
  }

  Future<(String, String)> _loadNotificationStrings() async {
    try {
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      final l10n = await AppLocalizations.delegate.load(locale);
      return (l10n.notifTitle, l10n.notifBody);
    } catch (_) {
      try {
        final l10n = await AppLocalizations.delegate.load(const Locale('en'));
        return (l10n.notifTitle, l10n.notifBody);
      } catch (_) {
        // Best-effort fallback.
        return ('Time for a set', 'Log one set to keep your rhythm today.');
      }
    }
  }
}
