import 'dart:collection';

import '../../../core/date_utils.dart';
import '../../../core/models/exercise_log.dart';
import '../../../core/models/exercise_type.dart';

/// Immutable month summary used by the calendar heatmap UI.
final class MonthWorkoutSummary {
  const MonthWorkoutSummary({
    required this.dayTotals,
    required this.maxTotal,
    required this.monthSum,
    required this.activeDays,
  });

  final Map<DateTime, int> dayTotals;
  final int maxTotal;
  final int monthSum;
  final int activeDays;
}

/// Immutable day summary used by the selected-day detail panel.
final class DayWorkoutSummary {
  const DayWorkoutSummary({
    required this.totals,
    required this.totalReps,
    required this.logs,
  });

  final Map<ExerciseType, int> totals;
  final int totalReps;
  final List<ExerciseLog> logs;
}

/// Aggregates workout logs into reusable summaries for dashboard and calendar UI.
class WorkoutAnalyticsService {
  const WorkoutAnalyticsService();

  /// Aggregates totals for a single day keyed by exercise.
  Map<ExerciseType, int> totalsForDay(List<ExerciseLog> logs, DateTime day) {
    final start = startOfDay(day);
    final end = start.add(const Duration(days: 1));
    return _totalsInRange(logs, start, end);
  }

  /// Aggregates totals for a Monday-start week keyed by exercise.
  Map<ExerciseType, int> totalsForWeek(
    List<ExerciseLog> logs,
    DateTime dayInWeek,
  ) {
    final start = startOfWeek(dayInWeek);
    final end = start.add(const Duration(days: 7));
    return _totalsInRange(logs, start, end);
  }

  /// Aggregates totals for one calendar month keyed by exercise.
  Map<ExerciseType, int> totalsForMonth(
    List<ExerciseLog> logs,
    DateTime dayInMonth,
  ) {
    final start = startOfMonth(dayInMonth);
    final end = DateTime(start.year, start.month + 1, 1);
    return _totalsInRange(logs, start, end);
  }

  /// Returns the sum of all reps contained in an exercise total map.
  int sumTotals(Map<ExerciseType, int> totals) {
    return totals.values.fold<int>(0, (acc, v) => acc + v);
  }

  /// Builds the heatmap summary for a visible calendar month.
  MonthWorkoutSummary summarizeMonth(
    List<ExerciseLog> logs,
    DateTime dayInMonth,
  ) {
    final monthStart = startOfMonth(dayInMonth);
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 1);
    final dayTotals = <DateTime, int>{};

    for (final log in logs) {
      if (!isInRange(log.timestamp, monthStart, monthEnd)) continue;
      final dayKey = startOfDay(log.timestamp);
      dayTotals[dayKey] = (dayTotals[dayKey] ?? 0) + log.reps;
    }

    final maxTotal = dayTotals.values.fold<int>(0, (max, value) {
      return value > max ? value : max;
    });
    final monthSum = dayTotals.values.fold<int>(0, (sum, value) {
      return sum + (value > 0 ? value : 0);
    });
    final activeDays = dayTotals.values.where((value) => value > 0).length;

    return MonthWorkoutSummary(
      dayTotals: UnmodifiableMapView<DateTime, int>(dayTotals),
      maxTotal: maxTotal,
      monthSum: monthSum,
      activeDays: activeDays,
    );
  }

  /// Builds the selected-day summary including totals and chronologically sorted logs.
  DayWorkoutSummary summarizeDay(List<ExerciseLog> logs, DateTime day) {
    final totals = totalsForDay(logs, day);
    final dayLogs = <ExerciseLog>[
      for (final log in logs)
        if (isSameDay(log.timestamp, day)) log,
    ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return DayWorkoutSummary(
      totals: UnmodifiableMapView<ExerciseType, int>(totals),
      totalReps: sumTotals(totals),
      logs: UnmodifiableListView<ExerciseLog>(dayLogs),
    );
  }

  /// Aggregates totals in a closed-open date range to keep boundary logic consistent.
  Map<ExerciseType, int> _totalsInRange(
    List<ExerciseLog> logs,
    DateTime start,
    DateTime end,
  ) {
    final out = <ExerciseType, int>{
      ExerciseType.pushUp: 0,
      ExerciseType.pullUp: 0,
      ExerciseType.dips: 0,
    };

    for (final log in logs) {
      if (isInRange(log.timestamp, start, end)) {
        out.update(log.type, (v) => v + log.reps);
      }
    }

    return out;
  }
}
