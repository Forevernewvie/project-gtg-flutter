import 'package:flutter_test/flutter_test.dart';
import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/core/models/reminder_settings.dart';
import 'package:project_gtg/features/reminders/reminder_optimization_policy.dart';

void main() {
  const policy = ReminderOptimizationPolicy();

  test('suggest enables reminders when no recent rhythm exists', () {
    final suggestion = policy.suggest(
      settings: ReminderSettings.defaults,
      logs: const <ExerciseLog>[],
      now: DateTime(2026, 4, 27, 12),
    );

    expect(suggestion?.kind, ReminderOptimizationKind.enableReminders);
    expect(suggestion?.recommendedSettings.enabled, isTrue);
  });

  test('suggest skips weekends when recent logs are weekday-only', () {
    final suggestion = policy.suggest(
      settings: ReminderSettings.defaults.copyWith(enabled: true),
      logs: <ExerciseLog>[
        _log('1', DateTime(2026, 4, 20, 9)),
        _log('2', DateTime(2026, 4, 21, 9)),
        _log('3', DateTime(2026, 4, 22, 9)),
        _log('4', DateTime(2026, 4, 23, 9)),
      ],
      now: DateTime(2026, 4, 27, 12),
    );

    expect(suggestion?.kind, ReminderOptimizationKind.skipWeekends);
    expect(suggestion?.recommendedSettings.skipWeekends, isTrue);
  });

  test('suggest reduces high frequency when recent rhythm is sparse', () {
    final suggestion = policy.suggest(
      settings: ReminderSettings.defaults.copyWith(
        enabled: true,
        intervalMinutes: 30,
        skipWeekends: true,
      ),
      logs: <ExerciseLog>[
        _log('1', DateTime(2026, 4, 25, 9)),
        _log('2', DateTime(2026, 4, 27, 12)),
      ],
      now: DateTime(2026, 4, 27, 14),
    );

    expect(suggestion?.kind, ReminderOptimizationKind.reduceFrequency);
    expect(suggestion?.recommendedSettings.intervalMinutes, 60);
  });

  test('suggest focuses quiet hours around a preferred log time', () {
    final suggestion = policy.suggest(
      settings: ReminderSettings.defaults.copyWith(
        enabled: true,
        skipWeekends: true,
      ),
      logs: <ExerciseLog>[
        _log('1', DateTime(2026, 4, 24, 9)),
        _log('2', DateTime(2026, 4, 25, 9)),
        _log('3', DateTime(2026, 4, 26, 9)),
      ],
      now: DateTime(2026, 4, 27, 12),
    );

    expect(suggestion?.kind, ReminderOptimizationKind.preferredTime);
    expect(suggestion?.hour, 9);
    expect(suggestion?.recommendedSettings.quietStartMinutes, 11 * 60);
    expect(suggestion?.recommendedSettings.quietEndMinutes, 8 * 60);
  });
}

ExerciseLog _log(String id, DateTime timestamp) {
  return ExerciseLog(
    id: id,
    type: ExerciseType.pushUp,
    reps: 5,
    timestamp: timestamp,
  );
}
