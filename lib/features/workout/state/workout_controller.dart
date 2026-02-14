import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/exercise_log.dart';
import '../../../core/models/exercise_type.dart';
import '../../../data/persistence/gtg_persistence.dart';

final persistenceProvider = Provider<GtgPersistence>((ref) {
  return GtgPersistence();
});

final workoutControllerProvider =
    AsyncNotifierProvider<WorkoutController, WorkoutState>(
      WorkoutController.new,
    );

class WorkoutState {
  const WorkoutState({required this.logs});

  final List<ExerciseLog> logs;
}

class WorkoutController extends AsyncNotifier<WorkoutState> {
  @override
  Future<WorkoutState> build() async {
    final persistence = ref.read(persistenceProvider);
    final logs = await persistence.loadLogs();
    return WorkoutState(logs: logs);
  }

  Future<void> addLog(
    ExerciseType type,
    int reps, {
    DateTime? timestamp,
  }) async {
    final current = state.asData?.value;
    if (current == null) {
      return;
    }

    final clampedReps = reps < 1 ? 1 : reps;
    final log = ExerciseLog(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: type,
      reps: clampedReps,
      timestamp: timestamp ?? DateTime.now(),
    );

    final updated = List<ExerciseLog>.unmodifiable(<ExerciseLog>[
      ...current.logs,
      log,
    ]);
    state = AsyncData(WorkoutState(logs: updated));

    await ref.read(persistenceProvider).saveLogs(updated);
  }

  Future<void> clearAll() async {
    state = const AsyncData(WorkoutState(logs: <ExerciseLog>[]));
    await ref.read(persistenceProvider).saveLogs(<ExerciseLog>[]);
  }
}
