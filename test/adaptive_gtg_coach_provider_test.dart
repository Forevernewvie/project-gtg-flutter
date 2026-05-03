import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_gtg/core/clock.dart';
import 'package:project_gtg/core/logging/app_logger.dart';
import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/core/models/user_preferences.dart';
import 'package:project_gtg/data/remote/cloud_sync_service.dart';
import 'package:project_gtg/data/remote/pocketbase_client.dart';
import 'package:project_gtg/data/remote/pocketbase_models.dart';
import 'package:project_gtg/features/coaching/state/gtg_coach_providers.dart';
import 'package:project_gtg/features/workout/state/workout_stats_providers.dart';

void main() {
  test('adaptive recommendation provider falls back to local rules', () async {
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
        cloudSyncServiceProvider.overrideWithValue(
          CloudSyncService(
            client: _ThrowingRecommendationClient(),
            logger: const _NoopLogger(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final recommendation = await container.read(
      adaptiveGtgCoachRecommendationProvider.future,
    );

    expect(recommendation.isRemote, isFalse);
    expect(recommendation.intensity, GtgCoachIntensity.progress);
    expect(recommendation.recommendedSets, 9);
  });
}

final class _ThrowingRecommendationClient implements RemoteSyncClient {
  @override
  bool get isConfigured => true;

  @override
  Future<GtgCoachRecommendation?> fetchLatestCoachRecommendation() async {
    throw StateError('remote-down');
  }

  @override
  Future<List<ExerciseLog>> fetchWorkoutLogs() async => const <ExerciseLog>[];

  @override
  Future<UserPreferences?> fetchUserPreferences() async => null;

  @override
  Future<void> upsertUserPreferences(UserPreferences preferences) async {}

  @override
  Future<void> upsertWorkoutLogs(List<ExerciseLog> logs) async {}
}

final class _NoopLogger implements AppLogger {
  const _NoopLogger();

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}

  @override
  void info(String message) {}

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) {}
}

final class _FixedClock implements Clock {
  const _FixedClock(this._now);

  final DateTime _now;

  @override
  DateTime now() => _now;
}
