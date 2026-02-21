import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/logging/logger_provider.dart';
import '../../../core/models/exercise_log.dart';
import '../../../core/models/exercise_type.dart';
import '../../../data/persistence/persistence_provider.dart';

final workoutControllerProvider =
    AsyncNotifierProvider<WorkoutController, WorkoutState>(
      WorkoutController.new,
    );

class WorkoutState {
  const WorkoutState({required this.logs});

  final List<ExerciseLog> logs;
}

class WorkoutController extends AsyncNotifier<WorkoutState> {
  static const int _minReps = 1;

  /// Loads workout logs from persistence.
  @override
  Future<WorkoutState> build() async {
    final persistence = ref.read(persistenceProvider);
    final logs = await persistence.loadLogs();
    return WorkoutState(logs: logs);
  }

  /// Appends one new log and persists it atomically.
  Future<void> addLog(
    ExerciseType type,
    int reps, {
    DateTime? timestamp,
  }) async {
    final current = state.asData?.value;
    if (current == null) {
      return;
    }

    final log = _buildLog(type: type, reps: reps, timestamp: timestamp);

    final updated = List<ExerciseLog>.unmodifiable(<ExerciseLog>[
      ...current.logs,
      log,
    ]);
    state = AsyncData(WorkoutState(logs: updated));

    try {
      await ref.read(persistenceProvider).saveLogs(updated);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to persist workout logs.',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Clears all logs and persists the empty state.
  Future<void> clearAll() async {
    state = const AsyncData(WorkoutState(logs: <ExerciseLog>[]));
    try {
      await ref.read(persistenceProvider).saveLogs(<ExerciseLog>[]);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to clear workout logs.',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Builds a valid immutable log object from UI input.
  ExerciseLog _buildLog({
    required ExerciseType type,
    required int reps,
    DateTime? timestamp,
  }) {
    final now = timestamp ?? DateTime.now();
    final normalizedReps = reps < _minReps ? _minReps : reps;

    return ExerciseLog(
      id: now.microsecondsSinceEpoch.toString(),
      type: type,
      reps: normalizedReps,
      timestamp: now,
    );
  }

  AppLogger get _logger => ref.read(appLoggerProvider);
}
