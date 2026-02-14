import '../../core/models/reminder_settings.dart';

class ReminderPlanner {
  const ReminderPlanner();

  /// Plans notification times for the remainder of "today" only.
  ///
  /// Rules:
  /// - no infinite schedules
  /// - respects quiet time + skip weekends
  /// - caps to maxPerDay (and iOS pending limit 64)
  List<DateTime> planForToday({
    required DateTime now,
    required ReminderSettings settings,
  }) {
    if (!settings.enabled) return const <DateTime>[];

    final interval = settings.intervalMinutes.clamp(1, 24 * 60);
    final maxPerDay = settings.maxPerDay.clamp(1, 64);

    if (settings.skipWeekends && _isWeekend(now)) return const <DateTime>[];

    final startOfToday = DateTime(now.year, now.month, now.day);
    final nowMinutes = now.hour * 60 + now.minute;

    // Align to the next interval boundary since midnight.
    var nextMinutes = ((nowMinutes ~/ interval) + 1) * interval;

    final planned = <DateTime>[];
    while (nextMinutes < 24 * 60 && planned.length < maxPerDay) {
      final candidate = startOfToday.add(Duration(minutes: nextMinutes));

      if (!_isInQuietTime(candidate, settings)) {
        planned.add(candidate);
      }

      nextMinutes += interval;
    }

    return List<DateTime>.unmodifiable(planned);
  }

  bool _isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  bool _isInQuietTime(DateTime dateTime, ReminderSettings settings) {
    final start = settings.quietStartMinutes;
    final end = settings.quietEndMinutes;

    if (start == end) return false; // Treat as "no quiet time".

    final minutes = dateTime.hour * 60 + dateTime.minute;

    if (start < end) {
      return minutes >= start && minutes < end;
    }

    // Quiet time spans midnight (e.g., 23:00 -> 07:00).
    return minutes >= start || minutes < end;
  }
}
