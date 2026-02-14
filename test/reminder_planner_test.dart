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

  test('quiet time spanning midnight filters out late-night times', () {
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

    expect(times, isEmpty);
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
}
