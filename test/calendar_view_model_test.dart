import 'package:flutter_test/flutter_test.dart';

import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/features/calendar/calendar_view_model.dart';
import 'package:project_gtg/features/workout/services/workout_analytics_service.dart';

void main() {
  test('create clamps selected day into the visible month', () {
    final service = const WorkoutAnalyticsService();
    final visibleMonth = DateTime(2026, 2, 18);

    final viewModel = CalendarViewModel.create(
      logs: const <ExerciseLog>[],
      analyticsService: service,
      visibleMonth: visibleMonth,
      selectedDay: DateTime(2026, 3, 2),
      now: DateTime(2026, 2, 18, 12),
    );

    expect(viewModel.visibleMonth, DateTime(2026, 2, 1));
    expect(viewModel.monthStart, DateTime(2026, 2, 1));
    expect(viewModel.monthEnd, DateTime(2026, 3, 1));
    expect(viewModel.selectedDay, DateTime(2026, 2, 1));
    expect(viewModel.today, DateTime(2026, 2, 18));
  });

  test('create builds month and selected-day summaries from logs', () {
    final service = const WorkoutAnalyticsService();
    final logs = <ExerciseLog>[
      ExerciseLog(
        id: 'a',
        type: ExerciseType.pushUp,
        reps: 10,
        timestamp: DateTime(2026, 2, 14, 9, 0),
      ),
      ExerciseLog(
        id: 'b',
        type: ExerciseType.pullUp,
        reps: 3,
        timestamp: DateTime(2026, 2, 14, 10, 0),
      ),
      ExerciseLog(
        id: 'c',
        type: ExerciseType.dips,
        reps: 8,
        timestamp: DateTime(2026, 2, 3, 12, 0),
      ),
      ExerciseLog(
        id: 'd',
        type: ExerciseType.pushUp,
        reps: 5,
        timestamp: DateTime(2026, 3, 1, 8, 0),
      ),
    ];

    final viewModel = CalendarViewModel.create(
      logs: logs,
      analyticsService: service,
      visibleMonth: DateTime(2026, 2, 18),
      selectedDay: DateTime(2026, 2, 14, 23, 59),
      now: DateTime(2026, 2, 18, 12),
    );

    expect(viewModel.monthSummary.monthSum, 21);
    expect(viewModel.monthSummary.activeDays, 2);
    expect(viewModel.monthSummary.maxTotal, 13);
    expect(viewModel.monthSummary.dayTotals[DateTime(2026, 2, 14)], 13);
    expect(viewModel.selectedSummary.totalReps, 13);
    expect(viewModel.selectedSummary.totals[ExerciseType.pushUp], 10);
    expect(viewModel.selectedSummary.totals[ExerciseType.pullUp], 3);
    expect(viewModel.selectedSummary.logs, hasLength(2));
    expect(viewModel.selectedSummary.logs.first.id, 'b');
  });
}
