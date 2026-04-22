import '../../core/date_utils.dart';
import '../../core/models/exercise_log.dart';
import '../../core/models/exercise_type.dart';
import '../../core/models/user_preferences.dart';

/// Derived GTG coaching state for the primary movement.
final class GtgCoachSummary {
  const GtgCoachSummary({
    required this.primaryExercise,
    required this.maxReps,
    required this.recommendedReps,
    required this.dailySetTarget,
    required this.completedSetsToday,
    required this.completedRepsToday,
    required this.lastMaxTestedAt,
    required this.retestDue,
  });

  final ExerciseType primaryExercise;
  final int maxReps;
  final int recommendedReps;
  final int dailySetTarget;
  final int completedSetsToday;
  final int completedRepsToday;
  final DateTime? lastMaxTestedAt;
  final bool retestDue;

  bool get hasBaseline => maxReps > 0;
  int get remainingSetsToday =>
      (dailySetTarget - completedSetsToday).clamp(0, dailySetTarget);
  double get progress => dailySetTarget <= 0
      ? 0
      : (completedSetsToday / dailySetTarget).clamp(0, 1).toDouble();
}

/// Pure GTG coaching rules used by settings and dashboard UI.
abstract final class GtgCoachPolicy {
  static const int minMaxReps = 0;
  static const int maxMaxReps = 200;
  static const int minDailySetTarget = 1;
  static const int maxDailySetTarget = 20;
  static const int retestDueDays = 14;

  static bool hasPrimaryBaseline(UserPreferences preferences) {
    return preferences.primaryExerciseMaxReps > 0;
  }

  static int recommendedRepsFromMax(int maxReps) {
    if (maxReps <= 0) return 0;
    final conservativeHalf = (maxReps * 0.5).floor().clamp(1, maxReps);
    return conservativeHalf;
  }

  static GtgCoachSummary summarize({
    required UserPreferences preferences,
    required List<ExerciseLog> logs,
    required DateTime now,
  }) {
    final primaryExercise = preferences.primaryExercise;
    final maxReps = preferences.primaryExerciseMaxReps.clamp(
      minMaxReps,
      maxMaxReps,
    );
    final dailySetTarget = preferences.primaryExerciseDailySetTarget.clamp(
      minDailySetTarget,
      maxDailySetTarget,
    );
    final recommendedReps = recommendedRepsFromMax(maxReps);
    final today = startOfDay(now);

    var completedSetsToday = 0;
    var completedRepsToday = 0;
    for (final log in logs) {
      if (log.type != primaryExercise || !isSameDay(log.timestamp, today)) {
        continue;
      }
      completedSetsToday++;
      completedRepsToday += log.reps;
    }

    final lastMaxTestedAt = preferences.primaryExerciseLastMaxTestedAt;
    final retestDue =
        lastMaxTestedAt != null &&
        startOfDay(now).difference(startOfDay(lastMaxTestedAt)).inDays >=
            retestDueDays;

    return GtgCoachSummary(
      primaryExercise: primaryExercise,
      maxReps: maxReps,
      recommendedReps: recommendedReps,
      dailySetTarget: dailySetTarget,
      completedSetsToday: completedSetsToday,
      completedRepsToday: completedRepsToday,
      lastMaxTestedAt: lastMaxTestedAt,
      retestDue: retestDue,
    );
  }
}
