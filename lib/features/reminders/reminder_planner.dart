import '../../core/models/reminder_settings.dart';

class ReminderPlanner {
  const ReminderPlanner();

  /// Plans notification times across multiple days (up to [maxDays] or [maxTotalCount]).
  ///
  /// Guarantees that reminders continue firing daily even if the user
  /// does not open the app every day, capped to safe OS limits (64 items).
  List<DateTime> planSchedule({
    required DateTime now,
    required ReminderSettings settings,
    int maxDays = 7,
    int maxTotalCount = 64,
  }) {
    if (!settings.enabled) return const <DateTime>[];

    final interval = settings.intervalMinutes.clamp(1, 24 * 60);
    final maxPerDay = settings.maxPerDay.clamp(1, 64);
    final totalLimit = maxTotalCount.clamp(1, 64);

    final startOfToday = DateTime(now.year, now.month, now.day);
    final nowMinutes = now.hour * 60 + now.minute;

    final allPlanned = <DateTime>[];

    for (var dayOffset = 0; dayOffset < maxDays; dayOffset++) {
      if (allPlanned.length >= totalLimit) break;

      final dayStart = startOfToday.add(Duration(days: dayOffset));
      final startMinutes = dayOffset == 0 ? nowMinutes : -1;
      final remainingSlots = totalLimit - allPlanned.length;
      final dayMax = remainingSlots < maxPerDay ? remainingSlots : maxPerDay;

      final dayPlanned = _planForDay(
        dayStart: dayStart,
        startMinutesExclusive: startMinutes,
        intervalMinutes: interval,
        maxCount: dayMax,
        settings: settings,
      );

      allPlanned.addAll(dayPlanned);
    }

    return List<DateTime>.unmodifiable(allPlanned);
  }

  /// Plans notification times starting from "now".
  ///
  /// Rules:
  /// - no infinite schedules
  /// - respects quiet time + skip weekends
  /// - caps to maxPerDay (and iOS pending limit 64)
  ///
  /// Notes:
  /// - Plans for the remainder of "today".
  /// - If there are no remaining valid slots, it will plan for "tomorrow"
  ///   instead (prevents the "enabled but 0 scheduled" confusion late at night).
  List<DateTime> planForToday({
    required DateTime now,
    required ReminderSettings settings,
  }) {
    if (!settings.enabled) return const <DateTime>[];

    final interval = settings.intervalMinutes.clamp(1, 24 * 60);
    final maxPerDay = settings.maxPerDay.clamp(1, 64);

    final startOfToday = DateTime(now.year, now.month, now.day);
    final nowMinutes = now.hour * 60 + now.minute;

    final plannedToday = _planForDay(
      dayStart: startOfToday,
      startMinutesExclusive: nowMinutes,
      intervalMinutes: interval,
      maxCount: maxPerDay,
      settings: settings,
    );
    if (plannedToday.isNotEmpty) {
      return List<DateTime>.unmodifiable(plannedToday);
    }

    final plannedTomorrow = _planForDay(
      dayStart: startOfToday.add(const Duration(days: 1)),
      startMinutesExclusive: -1, // start from midnight boundary
      intervalMinutes: interval,
      maxCount: maxPerDay,
      settings: settings,
    );
    return List<DateTime>.unmodifiable(plannedTomorrow);
  }

  List<DateTime> _planForDay({
    required DateTime dayStart,
    required int startMinutesExclusive,
    required int intervalMinutes,
    required int maxCount,
    required ReminderSettings settings,
  }) {
    if (settings.skipWeekends && _isWeekend(dayStart)) {
      return const <DateTime>[];
    }

    var nextMinutes = _alignNextBoundary(
      minutesExclusive: startMinutesExclusive,
      interval: intervalMinutes,
    );

    final planned = <DateTime>[];
    while (nextMinutes < 24 * 60 && planned.length < maxCount) {
      final candidate = dayStart.add(Duration(minutes: nextMinutes));
      if (!_isInQuietTime(candidate, settings)) {
        planned.add(candidate);
      }
      nextMinutes += intervalMinutes;
    }

    return planned;
  }

  int _alignNextBoundary({
    required int minutesExclusive,
    required int interval,
  }) {
    final q = (minutesExclusive / interval).floor();
    return (q + 1) * interval;
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
