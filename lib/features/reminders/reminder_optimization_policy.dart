import '../../core/models/exercise_log.dart';
import '../../core/models/reminder_settings.dart';

/// Local-only reminder recommendation types.
enum ReminderOptimizationKind {
  enableReminders,
  reduceFrequency,
  skipWeekends,
  preferredTime,
}

/// A user-controlled reminder optimization suggestion.
final class ReminderOptimizationSuggestion {
  const ReminderOptimizationSuggestion({
    required this.kind,
    required this.recommendedSettings,
    this.hour,
  });

  final ReminderOptimizationKind kind;
  final ReminderSettings recommendedSettings;
  final int? hour;
}

/// Derives optional reminder tuning suggestions from local log timing.
class ReminderOptimizationPolicy {
  const ReminderOptimizationPolicy();

  static const int minimumLogsForTiming = 3;
  static const int highFrequencyIntervalMinutes = 30;
  static const int suggestedIntervalMinutes = 60;

  ReminderOptimizationSuggestion? suggest({
    required ReminderSettings settings,
    required List<ExerciseLog> logs,
    required DateTime now,
  }) {
    final recentLogs = _recentLogs(logs, now);
    if (recentLogs.isEmpty) {
      return settings.enabled
          ? null
          : ReminderOptimizationSuggestion(
              kind: ReminderOptimizationKind.enableReminders,
              recommendedSettings: settings.copyWith(enabled: true),
            );
    }

    final weekendLogs = recentLogs.where((log) {
      return log.timestamp.weekday == DateTime.saturday ||
          log.timestamp.weekday == DateTime.sunday;
    }).length;
    if (!settings.skipWeekends && recentLogs.length >= 4 && weekendLogs == 0) {
      return ReminderOptimizationSuggestion(
        kind: ReminderOptimizationKind.skipWeekends,
        recommendedSettings: settings.copyWith(skipWeekends: true),
      );
    }

    if (settings.enabled &&
        settings.intervalMinutes <= highFrequencyIntervalMinutes &&
        recentLogs.length < 7) {
      return ReminderOptimizationSuggestion(
        kind: ReminderOptimizationKind.reduceFrequency,
        recommendedSettings: settings.copyWith(
          intervalMinutes: suggestedIntervalMinutes,
        ),
      );
    }

    final preferredHour = _mostCommonHour(recentLogs);
    if (settings.enabled &&
        preferredHour != null &&
        !_quietHoursContain(settings, preferredHour)) {
      final start = (preferredHour * 60 - 60).clamp(0, 23 * 60);
      final end = (preferredHour * 60 + 120).clamp(60, 24 * 60 - 1);
      return ReminderOptimizationSuggestion(
        kind: ReminderOptimizationKind.preferredTime,
        hour: preferredHour,
        recommendedSettings: settings.copyWith(
          quietStartMinutes: end,
          quietEndMinutes: start,
        ),
      );
    }

    return null;
  }

  List<ExerciseLog> _recentLogs(List<ExerciseLog> logs, DateTime now) {
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 13));
    return <ExerciseLog>[
      for (final log in logs)
        if (!log.timestamp.isBefore(start) && !log.timestamp.isAfter(now)) log,
    ];
  }

  int? _mostCommonHour(List<ExerciseLog> logs) {
    if (logs.length < minimumLogsForTiming) return null;

    final counts = <int, int>{};
    for (final log in logs) {
      counts.update(
        log.timestamp.hour,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    MapEntry<int, int>? best;
    for (final entry in counts.entries) {
      if (best == null ||
          entry.value > best.value ||
          entry.value == best.value && entry.key < best.key) {
        best = entry;
      }
    }

    return best?.value == 1 ? null : best?.key;
  }

  bool _quietHoursContain(ReminderSettings settings, int hour) {
    final minute = hour * 60;
    final start = settings.quietStartMinutes;
    final end = settings.quietEndMinutes;
    if (start == end) return false;
    if (start < end) return minute >= start && minute < end;
    return minute >= start || minute < end;
  }
}
