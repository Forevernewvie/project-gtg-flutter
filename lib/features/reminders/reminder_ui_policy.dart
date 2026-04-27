import '../../l10n/app_localizations.dart';
import 'reminder_optimization_policy.dart';

/// Encapsulates reminder screen constants and localized copy rules.
abstract final class ReminderUiPolicy {
  static const List<int> intervalOptions = <int>[15, 30, 45, 60, 90, 120, 180];
  static const int minMaxPerDay = 1;
  static const int maxMaxPerDay = 64;

  /// Returns the reminder status subtitle for the enable switch section.
  static String buildEnabledSubtitle({
    required AppLocalizations l10n,
    required DateTime now,
    required bool enabled,
    required DateTime? nextTime,
    required int plannedCount,
  }) {
    if (!enabled) return l10n.enableRemindersOffSubtitle;
    if (nextTime == null) {
      return l10n.enableRemindersNoSlotsSubtitle;
    }

    final label = formatNextTime(l10n: l10n, now: now, next: nextTime);
    return l10n.enableRemindersNextScheduledSubtitle(label, plannedCount);
  }

  /// Returns localized copy for a reminder optimization suggestion.
  static String buildOptimizationMessage({
    required AppLocalizations l10n,
    required ReminderOptimizationSuggestion suggestion,
  }) {
    return switch (suggestion.kind) {
      ReminderOptimizationKind.enableReminders =>
        l10n.reminderOptimizationEnable,
      ReminderOptimizationKind.reduceFrequency =>
        l10n.reminderOptimizationReduceFrequency(
          suggestion.recommendedSettings.intervalMinutes,
        ),
      ReminderOptimizationKind.skipWeekends =>
        l10n.reminderOptimizationSkipWeekends,
      ReminderOptimizationKind.preferredTime =>
        l10n.reminderOptimizationPreferredTime(
          formatHourLabel(suggestion.hour ?? 0),
        ),
    };
  }

  /// Formats an hour as a stable 24-hour label for concise recommendation copy.
  static String formatHourLabel(int hour) {
    final normalized = hour.clamp(0, 23);
    return '${normalized.toString().padLeft(2, '0')}:00';
  }

  /// Formats the next reminder time using today/tomorrow-aware wording first.
  static String formatNextTime({
    required AppLocalizations l10n,
    required DateTime now,
    required DateTime next,
  }) {
    final hh = next.hour.toString().padLeft(2, '0');
    final mm = next.minute.toString().padLeft(2, '0');
    final timeLabel = '$hh:$mm';

    final sameDay =
        now.year == next.year && now.month == next.month && now.day == next.day;
    if (sameDay) return timeLabel;

    final tomorrow = now.add(const Duration(days: 1));
    final isTomorrow =
        tomorrow.year == next.year &&
        tomorrow.month == next.month &&
        tomorrow.day == next.day;

    if (isTomorrow) return l10n.tomorrowAt(timeLabel);
    return '${next.month}/${next.day} $timeLabel';
  }
}
