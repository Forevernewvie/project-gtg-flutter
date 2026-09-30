import 'package:flutter_test/flutter_test.dart';
import 'package:project_gtg/core/models/reminder_settings.dart';
import 'package:project_gtg/features/reminders/reminder_planner.dart';

void main() {
  test('plans on the next interval boundary', () {
    const planner = ReminderPlanner();
    const settings = ReminderSettings(
      enabled: true,
      intervalMinutes: 60,
      quietStartMinutes: 0,
      quietEndMinutes: 0,
      skipWeekends: false,
      maxPerDay: 64,
    );

    final now = DateTime(2026, 2, 14, 10, 7);
    final times = planner.planForToday(now: now, settings: settings);

    expect(times.first, DateTime(2026, 2, 14, 11, 0));
    expect(times[1], DateTime(2026, 2, 14, 12, 0));
  });

  test('quiet time spanning midnight rolls over to tomorrow when needed', () {
    const planner = ReminderPlanner();
    const settings = ReminderSettings(
      enabled: true,
      intervalMinutes: 30,
      quietStartMinutes: 23 * 60,
      quietEndMinutes: 7 * 60,
      skipWeekends: false,
      maxPerDay: 64,
    );

    final now = DateTime(2026, 2, 14, 22, 30);
    final times = planner.planForToday(now: now, settings: settings);

    expect(times, isNotEmpty);
    expect(times.first, DateTime(2026, 2, 15, 7, 0));
  });

  test('skipWeekends returns empty on Saturday', () {
    const planner = ReminderPlanner();
    const settings = ReminderSettings(
      enabled: true,
      intervalMinutes: 60,
      quietStartMinutes: 0,
      quietEndMinutes: 0,
      skipWeekends: true,
      maxPerDay: 64,
    );

    // 2026-02-14 is Saturday.
    final now = DateTime(2026, 2, 14, 12, 0);
    final times = planner.planForToday(now: now, settings: settings);
    expect(times, isEmpty);
  });

  test('maxPerDay caps planned times', () {
    const planner = ReminderPlanner();
    const settings = ReminderSettings(
      enabled: true,
      intervalMinutes: 15,
      quietStartMinutes: 0,
      quietEndMinutes: 0,
      skipWeekends: false,
      maxPerDay: 3,
    );

    final now = DateTime(2026, 2, 16, 10, 0); // Monday
    final times = planner.planForToday(now: now, settings: settings);
    expect(times.length, 3);
    expect(times.first, DateTime(2026, 2, 16, 10, 15));
  });

  test('quietStart == quietEnd means "no quiet time"', () {
    const planner = ReminderPlanner();
    const settings = ReminderSettings(
      enabled: true,
      intervalMinutes: 30,
      quietStartMinutes: 23 * 60,
      quietEndMinutes: 23 * 60,
      skipWeekends: false,
      maxPerDay: 64,
    );

    final now = DateTime(2026, 2, 17, 22, 30);
    final times = planner.planForToday(now: now, settings: settings);

    expect(times.first, DateTime(2026, 2, 17, 23, 0));
  });

  group('planSchedule multi-day scheduling', () {
    test(
      'plans across multiple days to ensure notifications continue without daily app opens',
      () {
        const planner = ReminderPlanner();
        const settings = ReminderSettings(
          enabled: true,
          intervalMinutes: 60,
          quietStartMinutes: 22 * 60,
          quietEndMinutes: 8 * 60,
          skipWeekends: false,
          maxPerDay: 4,
        );

        // Wednesday 2026-02-18 at 18:00
        final now = DateTime(2026, 2, 18, 18, 0);
        final times = planner.planSchedule(
          now: now,
          settings: settings,
          maxDays: 3,
          maxTotalCount: 64,
        );

        // Day 1 (Wednesday): 19:00, 20:00, 21:00 (3 items, 22:00 is quiet)
        // Day 2 (Thursday): 08:00, 09:00, 10:00, 11:00 (4 items)
        // Day 3 (Friday): 08:00, 09:00, 10:00, 11:00 (4 items)
        expect(times.length, 11);
        expect(times.first, DateTime(2026, 2, 18, 19, 0));
        expect(times[3], DateTime(2026, 2, 19, 8, 0));
        expect(times[7], DateTime(2026, 2, 20, 8, 0));
      },
    );

    test('respects maxTotalCount cap (64 items) across many days', () {
      const planner = ReminderPlanner();
      const settings = ReminderSettings(
        enabled: true,
        intervalMinutes: 15,
        quietStartMinutes: 0,
        quietEndMinutes: 0,
        skipWeekends: false,
        maxPerDay: 64,
      );

      final now = DateTime(2026, 2, 16, 8, 0);
      final times = planner.planSchedule(
        now: now,
        settings: settings,
        maxDays: 7,
        maxTotalCount: 64,
      );

      expect(times.length, 64);
    });

    test('skips weekends across multi-day span', () {
      const planner = ReminderPlanner();
      const settings = ReminderSettings(
        enabled: true,
        intervalMinutes: 60,
        quietStartMinutes: 20 * 60,
        quietEndMinutes: 8 * 60,
        skipWeekends: true,
        maxPerDay: 2,
      );

      // Friday 2026-02-20 at 17:00
      final now = DateTime(2026, 2, 20, 17, 0);
      final times = planner.planSchedule(
        now: now,
        settings: settings,
        maxDays: 4, // Fri, Sat, Sun, Mon
        maxTotalCount: 64,
      );

      // Friday has 2 slots: 18:00, 19:00
      // Sat & Sun: skipped!
      // Monday has 2 slots: 08:00, 09:00
      expect(times.length, 4);
      expect(times[0].weekday, DateTime.friday);
      expect(times[1].weekday, DateTime.friday);
      expect(times[2].weekday, DateTime.monday);
      expect(times[3].weekday, DateTime.monday);
    });
  });
}
