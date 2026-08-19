import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watch_connectivity/watch_connectivity.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/logging/logger_provider.dart';
import '../../workout/state/workout_controller.dart';
import '../../../core/models/exercise_type.dart';

class WatchSyncService {
  final WatchConnectivity _watch;
  final AppLogger _logger;
  final WorkoutController _workoutController;
  StreamSubscription<Map<String, dynamic>>? _messageSubscription;

  WatchSyncService({
    required WatchConnectivity watch,
    required AppLogger logger,
    required WorkoutController workoutController,
  }) : _watch = watch,
       _logger = logger,
       _workoutController = workoutController;

  void initialize() {
    _logger.info(
      'WatchSyncService: Initializing watch connectivity listener...',
    );
    _messageSubscription = _watch.messageStream.listen(_onMessageReceived);
  }

  void dispose() {
    _messageSubscription?.cancel();
  }

  void _onMessageReceived(Map<String, dynamic> message) {
    _logger.info('WatchSyncService: Received message from watch: $message');
    try {
      final action = message['action'];
      if (action == 'log_set') {
        final exerciseKey = message['exercise_key'] as String?;
        // Fallback to pushUp if not specified
        final exerciseType = exerciseKey != null
            ? ExerciseType.values.firstWhere(
                (e) => e.key == exerciseKey,
                orElse: () => ExerciseType.pushUp,
              )
            : ExerciseType.pushUp;

        // Log exactly 1 set since it's a +1 button
        _workoutController.addLog(exerciseType, 1);
        _logger.info(
          'WatchSyncService: Logged 1 set of $exerciseType from Watch',
        );
      }
    } catch (e, st) {
      _logger.warning(
        'WatchSyncService: Failed to process watch message',
        error: e,
        stackTrace: st,
      );
    }
  }
}

final watchSyncServiceProvider = Provider<WatchSyncService>((ref) {
  final service = WatchSyncService(
    watch: WatchConnectivity(),
    logger: ref.read(appLoggerProvider),
    workoutController: ref.read(workoutControllerProvider.notifier),
  );

  // Register to dispose when provider is destroyed
  ref.onDispose(service.dispose);

  return service;
});
