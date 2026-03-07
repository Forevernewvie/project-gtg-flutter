import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_gtg/features/reminders/reminder_ui_policy.dart';
import 'package:project_gtg/l10n/app_localizations.dart';

void main() {
  test('buildEnabledSubtitle returns off copy when reminders are disabled', () {
    final l10n = lookupAppLocalizations(const Locale('ko'));

    final subtitle = ReminderUiPolicy.buildEnabledSubtitle(
      l10n: l10n,
      now: DateTime(2026, 2, 15, 10),
      enabled: false,
      nextTime: null,
      plannedCount: 0,
    );

    expect(subtitle, l10n.enableRemindersOffSubtitle);
  });

  test('buildEnabledSubtitle uses tomorrow wording for next-day reminders', () {
    final l10n = lookupAppLocalizations(const Locale('ko'));

    final subtitle = ReminderUiPolicy.buildEnabledSubtitle(
      l10n: l10n,
      now: DateTime(2026, 2, 15, 22),
      enabled: true,
      nextTime: DateTime(2026, 2, 16, 9, 30),
      plannedCount: 4,
    );

    expect(subtitle, contains(l10n.tomorrowAt('09:30')));
    expect(subtitle, contains('4'));
  });

  test('formatNextTime falls back to month and day for later dates', () {
    final l10n = lookupAppLocalizations(const Locale('en'));

    final label = ReminderUiPolicy.formatNextTime(
      l10n: l10n,
      now: DateTime(2026, 2, 15, 10),
      next: DateTime(2026, 2, 20, 8, 5),
    );

    expect(label, '2/20 08:05');
  });
}
