import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/logging/logger_provider.dart';
import '../../../core/models/exercise_log.dart';
import '../../../core/models/exercise_type.dart';
import '../../../data/persistence/persistence_repositories.dart';
import '../../widget_sync/application/widget_sync_service.dart';
import '../../widget_sync/domain/widget_data_model.dart';

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
    try {
      final logs = await _repository.loadLogs();
      return WorkoutState(logs: logs);
    } catch (error, stackTrace) {
      _logger.warning(
        'Failed to load workout logs. Falling back to empty history.',
        error: error,
        stackTrace: stackTrace,
      );
      return const WorkoutState(logs: <ExerciseLog>[]);
    }
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
      await _repository.saveLogs(updated);

      // Keep native widget in sync with the new log
      final now = ref.read(clockProvider).now();
      final todayTotal = updated
          .where(
            (l) =>
                l.type == type &&
                l.timestamp.year == now.year &&
                l.timestamp.month == now.month &&
                l.timestamp.day == now.day,
          )
          .fold<int>(0, (sum, l) => sum + l.reps);

      await WidgetSyncService.syncData(
        WidgetDataModel(
          todayTotal: todayTotal,
          targetTotal: 0,
          primaryExercise: type,
        ),
      );
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
      await _repository.saveLogs(<ExerciseLog>[]);
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
    final now = timestamp ?? ref.read(clockProvider).now();
    final normalizedReps = reps < _minReps ? _minReps : reps;

    return ExerciseLog(
      id: now.microsecondsSinceEpoch.toString(),
      type: type,
      reps: normalizedReps,
      timestamp: now,
    );
  }

  /// Exposes the repository abstraction to keep the controller storage-agnostic.
  WorkoutLogRepository get _repository =>
      ref.read(workoutLogRepositoryProvider);

  /// Exposes the injected logger so failures remain observable in tests and runtime.
  AppLogger get _logger => ref.read(appLoggerProvider);
}
