import 'package:flutter_test/flutter_test.dart';
import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/core/models/user_preferences.dart';
import 'package:project_gtg/features/coaching/gtg_coach_policy.dart';
import 'package:project_gtg/features/coaching/gtg_insight_engine.dart';

void main() {
  const engine = GtgInsightEngine();

  test('build returns baseline and local rhythm insights for primary move', () {
    final now = DateTime(2026, 4, 27, 18);
    final preferences = UserPreferences(
      hasCompletedOnboarding: true,
      primaryExercise: ExerciseType.pullUp,
      primaryExerciseMaxReps: 0,
      primaryExerciseDailySetTarget: 5,
    );
    final logs = <ExerciseLog>[
      _log('1', ExerciseType.pullUp, DateTime(2026, 4, 26, 9)),
      _log('2', ExerciseType.pullUp, DateTime(2026, 4, 27, 9)),
      _log('3', ExerciseType.pushUp, DateTime(2026, 4, 27, 9)),
    ];

    final insights = engine.build(
      logs: logs,
      summary: GtgCoachPolicy.summarize(
        preferences: preferences,
        logs: logs,
        now: now,
      ),
      now: now,
    );

    expect(insights.map((insight) => insight.kind), <GtgInsightKind>[
      GtgInsightKind.baselineMissing,
      GtgInsightKind.consistency,
      GtgInsightKind.trainingWindow,
    ]);
    expect(insights[1].count, 2);
    expect(insights[2].hour, 9);
  });

  test(
    'build caps visible insights and includes retest when highest priority fits',
    () {
      final now = DateTime(2026, 4, 27, 18);
      final preferences = UserPreferences(
        hasCompletedOnboarding: true,
        primaryExercise: ExerciseType.dips,
        primaryExerciseMaxReps: 12,
        primaryExerciseDailySetTarget: 4,
        primaryExerciseLastMaxTestedAt: DateTime(2026, 4, 1),
      );
      final logs = <ExerciseLog>[
        _log('1', ExerciseType.dips, DateTime(2026, 4, 26, 11)),
        _log('2', ExerciseType.dips, DateTime(2026, 4, 27, 11)),
      ];

      final insights = engine.build(
        logs: logs,
        summary: GtgCoachPolicy.summarize(
          preferences: preferences,
          logs: logs,
          now: now,
        ),
        now: now,
      );

      expect(insights.length, lessThanOrEqualTo(GtgInsightEngine.maxInsights));
      expect(
        insights.map((insight) => insight.kind),
        contains(GtgInsightKind.retestDue),
      );
    },
  );
}

ExerciseLog _log(String id, ExerciseType type, DateTime timestamp) {
  return ExerciseLog(id: id, type: type, reps: 5, timestamp: timestamp);
}
