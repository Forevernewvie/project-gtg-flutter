import 'package:flutter_test/flutter_test.dart';
import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/core/models/user_preferences.dart';
import 'package:project_gtg/features/coaching/gtg_coach_policy.dart';
import 'package:project_gtg/features/coaching/gtg_retention_policy.dart';

void main() {
  const policy = GtgRetentionPolicy();

  test('buildMission creates a default mission without a max baseline', () {
    final now = DateTime(2026, 5, 1, 10);
    final summary = GtgCoachPolicy.summarize(
      preferences: UserPreferences.defaults.copyWith(
        primaryExercise: ExerciseType.pullUp,
      ),
      logs: const <ExerciseLog>[],
      now: now,
    );

    final mission = policy.buildMission(
      summary: summary,
      logs: const <ExerciseLog>[],
      now: now,
    );

    expect(mission.exercise, ExerciseType.pullUp);
    expect(mission.recommendedReps, 5);
    expect(
      mission.targetSets,
      UserPreferences.defaults.primaryExerciseDailySetTarget,
    );
    expect(mission.completedSets, 0);
    expect(mission.isRecovery, isFalse);
  });

  test('buildMission counts today progress for the primary exercise only', () {
    final now = DateTime(2026, 5, 1, 12);
    final logs = <ExerciseLog>[
      _log('1', ExerciseType.pushUp, 5, DateTime(2026, 5, 1, 8)),
      _log('2', ExerciseType.pushUp, 6, DateTime(2026, 5, 1, 11)),
      _log('3', ExerciseType.pullUp, 4, DateTime(2026, 5, 1, 9)),
    ];
    final summary = GtgCoachPolicy.summarize(
      preferences: UserPreferences.defaults.copyWith(
        primaryExerciseMaxReps: 12,
        primaryExerciseDailySetTarget: 4,
      ),
      logs: logs,
      now: now,
    );

    final mission = policy.buildMission(summary: summary, logs: logs, now: now);

    expect(mission.recommendedReps, 6);
    expect(mission.completedSets, 2);
    expect(mission.completedReps, 11);
    expect(mission.remainingSets, 2);
    expect(mission.progress, 0.5);
  });

  test('buildMission switches to one-set recovery after a missed day', () {
    final now = DateTime(2026, 5, 4, 12);
    final logs = <ExerciseLog>[
      _log('1', ExerciseType.pushUp, 8, DateTime(2026, 5, 2, 10)),
    ];
    final summary = GtgCoachPolicy.summarize(
      preferences: UserPreferences.defaults.copyWith(
        primaryExerciseMaxReps: 16,
        primaryExerciseDailySetTarget: 6,
      ),
      logs: logs,
      now: now,
    );

    final mission = policy.buildMission(summary: summary, logs: logs, now: now);

    expect(mission.isRecovery, isTrue);
    expect(mission.missedDaysSinceLastLog, 1);
    expect(mission.targetSets, GtgRetentionPolicy.recoverySetTarget);
  });
}

ExerciseLog _log(String id, ExerciseType type, int reps, DateTime timestamp) {
  return ExerciseLog(id: id, type: type, reps: reps, timestamp: timestamp);
}
