import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/date_utils.dart';
import '../../../core/models/exercise_log.dart';
import '../../../core/models/exercise_type.dart';
import '../services/workout_analytics_service.dart';
import 'workout_controller.dart';

final workoutAnalyticsServiceProvider = Provider<WorkoutAnalyticsService>((
  ref,
) {
  return const WorkoutAnalyticsService();
});

final workoutLogsProvider = Provider<List<ExerciseLog>>((ref) {
  return ref.watch(workoutControllerProvider).asData?.value.logs ??
      const <ExerciseLog>[];
});

final todayTotalsProvider = Provider<Map<ExerciseType, int>>((ref) {
  final logs = ref.watch(workoutLogsProvider);
  final service = ref.watch(workoutAnalyticsServiceProvider);
  return service.totalsForDay(logs, DateTime.now());
});

final todayTotalSumProvider = Provider<int>((ref) {
  final service = ref.watch(workoutAnalyticsServiceProvider);
  return service.sumTotals(ref.watch(todayTotalsProvider));
});

final activeDaysLast14Provider = Provider<int>((ref) {
  final logs = ref.watch(workoutLogsProvider);
  if (logs.isEmpty) return 0;

  final now = DateTime.now();
  final start = startOfDay(now).subtract(const Duration(days: 13));
  final days = <int>{};

  for (final log in logs) {
    if (!log.timestamp.isBefore(start) && !log.timestamp.isAfter(now)) {
      days.add(startOfDay(log.timestamp).millisecondsSinceEpoch);
    }
  }

  return days.length;
});
