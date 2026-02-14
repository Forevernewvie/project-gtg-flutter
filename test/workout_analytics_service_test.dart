import 'package:flutter_test/flutter_test.dart';
import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/features/workout/services/workout_analytics_service.dart';

void main() {
  test('totalsForDay aggregates by exercise', () {
    final service = WorkoutAnalyticsService();
    final day = DateTime(2026, 2, 14, 10);

    final logs = <ExerciseLog>[
      ExerciseLog(
        id: 'a',
        type: ExerciseType.pushUp,
        reps: 10,
        timestamp: DateTime(2026, 2, 14, 9, 0),
      ),
      ExerciseLog(
        id: 'b',
        type: ExerciseType.pushUp,
        reps: 5,
        timestamp: DateTime(2026, 2, 14, 23, 59),
      ),
      ExerciseLog(
        id: 'c',
        type: ExerciseType.pullUp,
        reps: 3,
        timestamp: DateTime(2026, 2, 13, 23, 59),
      ),
    ];

    final totals = service.totalsForDay(logs, day);
    expect(totals[ExerciseType.pushUp], 15);
    expect(totals[ExerciseType.pullUp], 0);
    expect(totals[ExerciseType.dips], 0);
    expect(service.sumTotals(totals), 15);
  });

  test('totalsForWeek uses Monday-start week boundaries', () {
    final service = WorkoutAnalyticsService();

    // 2026-02-18 is Wed.
    final dayInWeek = DateTime(2026, 2, 18, 12);

    // Week starts Mon 2026-02-16.
    final logs = <ExerciseLog>[
      ExerciseLog(
        id: 'a',
        type: ExerciseType.dips,
        reps: 8,
        timestamp: DateTime(2026, 2, 15, 10),
      ),
      ExerciseLog(
        id: 'b',
        type: ExerciseType.dips,
        reps: 12,
        timestamp: DateTime(2026, 2, 16, 10),
      ),
      ExerciseLog(
        id: 'c',
        type: ExerciseType.pullUp,
        reps: 4,
        timestamp: DateTime(2026, 2, 22, 23),
      ),
      ExerciseLog(
        id: 'd',
        type: ExerciseType.pullUp,
        reps: 100,
        timestamp: DateTime(2026, 2, 23, 0),
      ),
    ];

    final totals = service.totalsForWeek(logs, dayInWeek);
    expect(totals[ExerciseType.dips], 12);
    expect(totals[ExerciseType.pullUp], 4);
    expect(service.sumTotals(totals), 16);
  });

  test('totalsForMonth aggregates within current month', () {
    final service = WorkoutAnalyticsService();
    final dayInMonth = DateTime(2026, 2, 1);

    final logs = <ExerciseLog>[
      ExerciseLog(
        id: 'a',
        type: ExerciseType.pushUp,
        reps: 10,
        timestamp: DateTime(2026, 2, 1, 9),
      ),
      ExerciseLog(
        id: 'b',
        type: ExerciseType.pushUp,
        reps: 10,
        timestamp: DateTime(2026, 3, 1, 0),
      ),
    ];

    final totals = service.totalsForMonth(logs, dayInMonth);
    expect(totals[ExerciseType.pushUp], 10);
    expect(service.sumTotals(totals), 10);
  });
}
