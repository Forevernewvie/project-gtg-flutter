import 'package:flutter_test/flutter_test.dart';

import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/core/models/user_preferences.dart';
import 'package:project_gtg/features/coaching/gtg_coach_policy.dart';

void main() {
  test('summarize derives recommendation, progress, and retest state', () {
    final summary = GtgCoachPolicy.summarize(
      preferences: UserPreferences(
        hasCompletedOnboarding: true,
        primaryExercise: ExerciseType.pullUp,
        primaryExerciseMaxReps: 11,
        primaryExerciseDailySetTarget: 8,
        primaryExerciseLastMaxTestedAt: DateTime(2026, 4, 1),
      ),
      logs: <ExerciseLog>[
        ExerciseLog(
          id: '1',
          type: ExerciseType.pullUp,
          reps: 5,
          timestamp: DateTime(2026, 4, 22, 8),
        ),
        ExerciseLog(
          id: '2',
          type: ExerciseType.pullUp,
          reps: 5,
          timestamp: DateTime(2026, 4, 22, 12),
        ),
      ],
      now: DateTime(2026, 4, 22, 18),
    );

    expect(summary.recommendedReps, 5);
    expect(summary.completedSetsToday, 2);
    expect(summary.completedRepsToday, 10);
    expect(summary.remainingSetsToday, 6);
    expect(summary.progress, 0.25);
    expect(summary.retestDue, isTrue);
  });
}
