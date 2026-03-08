import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:project_gtg/core/clock.dart';
import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/data/persistence/persistence_repositories.dart';
import 'package:project_gtg/features/workout/state/workout_controller.dart';

class _FixedClock implements Clock {
  /// Creates a deterministic clock for controller tests.
  const _FixedClock(this._now);

  final DateTime _now;

  @override
  /// Returns the fixed instant so controller tests stay deterministic.
  DateTime now() => _now;
}

class _MemoryWorkoutLogRepository implements WorkoutLogRepository {
  /// Creates an in-memory workout repository for isolated controller tests.
  _MemoryWorkoutLogRepository(this._logs);

  List<ExerciseLog> _logs;

  @override
  /// Returns the current in-memory workout logs for assertions.
  Future<List<ExerciseLog>> loadLogs() async {
    return List<ExerciseLog>.unmodifiable(_logs);
  }

  @override
  /// Stores workout logs in memory without relying on concrete persistence.
  Future<void> saveLogs(List<ExerciseLog> logs) async {
    _logs = List<ExerciseLog>.unmodifiable(logs);
  }
}

void main() {
  test(
    'addLog uses injected clock and normalizes reps before persisting',
    () async {
      final fixedNow = DateTime(2026, 3, 8, 7, 30, 45, 123);
      final repository = _MemoryWorkoutLogRepository(const <ExerciseLog>[]);

      final container = ProviderContainer(
        overrides: [
          workoutLogRepositoryProvider.overrideWithValue(repository),
          clockProvider.overrideWithValue(_FixedClock(fixedNow)),
        ],
      );
      addTearDown(container.dispose);

      final before = await container.read(workoutControllerProvider.future);
      expect(before.logs, isEmpty);

      await container
          .read(workoutControllerProvider.notifier)
          .addLog(ExerciseType.pushUp, 0);

      final after = container.read(workoutControllerProvider).asData!.value;
      expect(after.logs, hasLength(1));
      expect(after.logs.single.type, ExerciseType.pushUp);
      expect(after.logs.single.reps, 1);
      expect(after.logs.single.timestamp, fixedNow);
      expect(after.logs.single.id, fixedNow.microsecondsSinceEpoch.toString());

      final persisted = await repository.loadLogs();
      expect(persisted, hasLength(1));
      expect(persisted.single.reps, 1);
      expect(persisted.single.timestamp, fixedNow);
    },
  );

  test('clearAll persists an empty workout history', () async {
    final repository = _MemoryWorkoutLogRepository(<ExerciseLog>[
      ExerciseLog(
        id: 'seed',
        type: ExerciseType.pullUp,
        reps: 5,
        timestamp: DateTime(2026, 3, 8, 9, 0),
      ),
    ]);

    final container = ProviderContainer(
      overrides: [
        workoutLogRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(
          _FixedClock(DateTime(2026, 3, 8, 7, 30)),
        ),
      ],
    );
    addTearDown(container.dispose);

    final before = await container.read(workoutControllerProvider.future);
    expect(before.logs, hasLength(1));

    await container.read(workoutControllerProvider.notifier).clearAll();

    final after = container.read(workoutControllerProvider).asData!.value;
    expect(after.logs, isEmpty);
    expect(await repository.loadLogs(), isEmpty);
  });
}
