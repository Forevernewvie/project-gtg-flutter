import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logging/app_logger.dart';
import '../../core/logging/logger_provider.dart';
import '../../core/models/exercise_log.dart';
import '../../core/models/user_preferences.dart';
import 'pocketbase_client.dart';
import 'pocketbase_config.dart';
import 'pocketbase_models.dart';

final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  return CloudSyncService(
    client: ref.watch(remoteSyncClientProvider),
    logger: ref.watch(appLoggerProvider),
  );
});

final cloudSyncAvailabilityProvider = Provider<CloudSyncAvailability>((ref) {
  final config = ref.watch(pocketBaseConfigProvider);
  return CloudSyncAvailability(
    isConfigured: config.isConfigured,
    baseUrl: config.baseUrl,
  );
});

final class CloudSyncAvailability {
  const CloudSyncAvailability({
    required this.isConfigured,
    required this.baseUrl,
  });

  final bool isConfigured;
  final String baseUrl;
}

final class CloudSyncService {
  const CloudSyncService({
    required RemoteSyncClient client,
    required AppLogger logger,
  }) : _client = client,
       _logger = logger;

  final RemoteSyncClient _client;
  final AppLogger _logger;

  bool get isConfigured => _client.isConfigured;

  Future<CloudSyncResult<List<ExerciseLog>>> mergeWorkoutLogs(
    List<ExerciseLog> localLogs,
  ) async {
    if (!isConfigured) {
      return CloudSyncResult.skipped(localLogs);
    }
    try {
      final remoteLogs = await _client.fetchWorkoutLogs();
      final merged = _mergeLogs(localLogs, remoteLogs);
      await _client.upsertWorkoutLogs(merged);
      return CloudSyncResult.synced(merged);
    } catch (error, stackTrace) {
      _logger.warning(
        'PocketBase workout log sync failed. Continuing with local logs.',
        error: error,
        stackTrace: stackTrace,
      );
      return CloudSyncResult.failed(localLogs, error);
    }
  }

  Future<CloudSyncResult<UserPreferences>> mergeUserPreferences(
    UserPreferences localPreferences,
  ) async {
    if (!isConfigured) {
      return CloudSyncResult.skipped(localPreferences);
    }
    try {
      final remotePreferences = await _client.fetchUserPreferences();
      final merged = remotePreferences ?? localPreferences;
      await _client.upsertUserPreferences(merged);
      return CloudSyncResult.synced(merged);
    } catch (error, stackTrace) {
      _logger.warning(
        'PocketBase user preference sync failed. Continuing with local preferences.',
        error: error,
        stackTrace: stackTrace,
      );
      return CloudSyncResult.failed(localPreferences, error);
    }
  }

  Future<CloudSyncResult<void>> pushWorkoutLogs(List<ExerciseLog> logs) async {
    if (!isConfigured) return CloudSyncResult.skipped(null);
    try {
      await _client.upsertWorkoutLogs(logs);
      return CloudSyncResult.synced(null);
    } catch (error, stackTrace) {
      _logger.warning(
        'PocketBase workout log upload failed.',
        error: error,
        stackTrace: stackTrace,
      );
      return CloudSyncResult.failed(null, error);
    }
  }

  Future<CloudSyncResult<void>> pushUserPreferences(
    UserPreferences preferences,
  ) async {
    if (!isConfigured) return CloudSyncResult.skipped(null);
    try {
      await _client.upsertUserPreferences(preferences);
      return CloudSyncResult.synced(null);
    } catch (error, stackTrace) {
      _logger.warning(
        'PocketBase user preference upload failed.',
        error: error,
        stackTrace: stackTrace,
      );
      return CloudSyncResult.failed(null, error);
    }
  }

  Future<GtgCoachRecommendation?> fetchRemoteCoachRecommendation() async {
    if (!isConfigured) return null;
    try {
      return await _client.fetchLatestCoachRecommendation();
    } catch (error, stackTrace) {
      _logger.warning(
        'PocketBase coach recommendation fetch failed. Using local rules.',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  List<ExerciseLog> _mergeLogs(
    List<ExerciseLog> localLogs,
    List<ExerciseLog> remoteLogs,
  ) {
    final byId = <String, ExerciseLog>{};
    for (final log in <ExerciseLog>[...localLogs, ...remoteLogs]) {
      final existing = byId[log.id];
      if (existing == null || log.timestamp.isAfter(existing.timestamp)) {
        byId[log.id] = log;
      }
    }
    final merged = byId.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return List<ExerciseLog>.unmodifiable(merged);
  }
}

enum CloudSyncStatus { skipped, synced, failed }

final class CloudSyncResult<T> {
  const CloudSyncResult._({
    required this.status,
    required this.value,
    this.error,
  });

  final CloudSyncStatus status;
  final T value;
  final Object? error;

  bool get didSync => status == CloudSyncStatus.synced;

  static CloudSyncResult<T> skipped<T>(T value) {
    return CloudSyncResult<T>._(status: CloudSyncStatus.skipped, value: value);
  }

  static CloudSyncResult<T> synced<T>(T value) {
    return CloudSyncResult<T>._(status: CloudSyncStatus.synced, value: value);
  }

  static CloudSyncResult<T> failed<T>(T value, Object error) {
    return CloudSyncResult<T>._(
      status: CloudSyncStatus.failed,
      value: value,
      error: error,
    );
  }
}
