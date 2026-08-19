import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_gtg/core/clock.dart';
import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/core/models/user_preferences.dart';
import 'package:project_gtg/features/coaching/state/gtg_coach_providers.dart';
import 'package:project_gtg/features/coaching/models/gtg_coach_recommendation.dart';
import 'package:project_gtg/features/workout/state/workout_stats_providers.dart';

void main() {
  test('adaptive recommendation provider uses local rules', () {
    final container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(_FixedClock(DateTime(2026, 5, 3, 10))),
        userPreferencesValueProvider.overrideWithValue(
          const UserPreferences(
            hasCompletedOnboarding: true,
            primaryExercise: ExerciseType.pushUp,
            primaryExerciseMaxReps: 20,
            primaryExerciseDailySetTarget: 8,
          ),
        ),
        workoutLogsProvider.overrideWithValue(<ExerciseLog>[
          ExerciseLog(
            id: 'a',
            type: ExerciseType.pushUp,
            reps: 10,
            timestamp: DateTime(2026, 5, 2),
          ),
        ]),
      ],
    );
    addTearDown(container.dispose);

    final recommendation = container.read(
      adaptiveGtgCoachRecommendationProvider,
    );

    expect(recommendation.isRemote, isFalse);
    expect(recommendation.intensity, GtgCoachIntensity.progress);
    expect(recommendation.recommendedSets, 9);
  });
}

final class _FixedClock implements Clock {
  const _FixedClock(this._now);

  final DateTime _now;

  @override
  DateTime now() => _now;
}
