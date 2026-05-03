import 'package:flutter_test/flutter_test.dart';
import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/core/models/user_preferences.dart';
import 'package:project_gtg/data/remote/pocketbase_models.dart';
import 'package:project_gtg/features/coaching/adaptive_gtg_coach.dart';

void main() {
  const policy = AdaptiveGtgCoachPolicy();

  test('progresses by one set when recent rhythm is stable', () {
    final now = DateTime(2026, 5, 3, 10);
    final recommendation = policy.recommend(
      preferences: const UserPreferences(
        hasCompletedOnboarding: true,
        primaryExercise: ExerciseType.pushUp,
        primaryExerciseMaxReps: 20,
        primaryExerciseDailySetTarget: 8,
      ),
      logs: <ExerciseLog>[
        _log('a', 10, now.subtract(const Duration(days: 1))),
        _log('b', 10, now.subtract(const Duration(days: 2))),
      ],
      now: now,
    );

    expect(recommendation.intensity, GtgCoachIntensity.progress);
    expect(recommendation.recommendedSets, 9);
    expect(recommendation.recommendedRepsPerSet, 10);
    expect(recommendation.reasonCode, 'progress_volume');
  });

  test('recovers after a long gap', () {
    final now = DateTime(2026, 5, 3, 10);
    final recommendation = policy.recommend(
      preferences: const UserPreferences(
        hasCompletedOnboarding: true,
        primaryExercise: ExerciseType.pushUp,
        primaryExerciseMaxReps: 20,
        primaryExerciseDailySetTarget: 8,
      ),
      logs: <ExerciseLog>[_log('a', 10, now.subtract(const Duration(days: 5)))],
      now: now,
    );

    expect(recommendation.intensity, GtgCoachIntensity.recover);
    expect(recommendation.recommendedSets, 4);
    expect(recommendation.reasonCode, 'restart_after_gap');
  });
}

ExerciseLog _log(String id, int reps, DateTime timestamp) {
  return ExerciseLog(
    id: id,
    type: ExerciseType.pushUp,
    reps: reps,
    timestamp: timestamp,
  );
}
