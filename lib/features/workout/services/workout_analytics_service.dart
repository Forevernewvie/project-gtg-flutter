import '../../../core/date_utils.dart';
import '../../../core/models/exercise_log.dart';
import '../../../core/models/exercise_type.dart';

class WorkoutAnalyticsService {
  const WorkoutAnalyticsService();

  Map<ExerciseType, int> totalsForDay(List<ExerciseLog> logs, DateTime day) {
    final start = startOfDay(day);
    final end = start.add(const Duration(days: 1));
    return _totalsInRange(logs, start, end);
  }

  Map<ExerciseType, int> totalsForWeek(
    List<ExerciseLog> logs,
    DateTime dayInWeek,
  ) {
    final start = startOfWeek(dayInWeek);
    final end = start.add(const Duration(days: 7));
    return _totalsInRange(logs, start, end);
  }

  Map<ExerciseType, int> totalsForMonth(
    List<ExerciseLog> logs,
    DateTime dayInMonth,
  ) {
    final start = startOfMonth(dayInMonth);
    final end = DateTime(start.year, start.month + 1, 1);
    return _totalsInRange(logs, start, end);
  }

  int sumTotals(Map<ExerciseType, int> totals) {
    return totals.values.fold<int>(0, (acc, v) => acc + v);
  }

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
