import 'package:flutter_test/flutter_test.dart';
import 'package:project_gtg/core/logging/app_logger.dart';
import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/core/models/user_preferences.dart';
import 'package:project_gtg/data/persistence/persistence_repositories.dart';
import 'package:project_gtg/data/remote/cloud_sync_service.dart';
import 'package:project_gtg/data/remote/pocketbase_client.dart';
import 'package:project_gtg/data/remote/pocketbase_models.dart';

void main() {
  test('skips cloud sync when PocketBase is not configured', () async {
    final service = CloudSyncService(
      client: _FakeRemoteSyncClient(isConfigured: false),
      logger: const _NoopLogger(),
    );
    final logs = <ExerciseLog>[_log('a', 10, DateTime(2026, 1, 1))];

    final result = await service.mergeWorkoutLogs(logs);

    expect(result.status, CloudSyncStatus.skipped);
    expect(result.value, logs);
  });

  test('merges remote and local logs by stable client id', () async {
    final remote = _FakeRemoteSyncClient(
      remoteLogs: <ExerciseLog>[
        _log('b', 5, DateTime(2026, 1, 2)),
        _log('a', 11, DateTime(2026, 1, 3)),
      ],
    );
    final service = CloudSyncService(
      client: remote,
      logger: const _NoopLogger(),
    );

    final result = await service.mergeWorkoutLogs(<ExerciseLog>[
      _log('a', 10, DateTime(2026, 1, 1)),
    ]);

    expect(result.status, CloudSyncStatus.synced);
    expect(result.value.map((log) => log.id), <String>['b', 'a']);
    expect(result.value.last.reps, 11);
    expect(remote.uploadedLogs.map((log) => log.id), <String>['b', 'a']);
  });

  test('falls back to local data when remote sync fails', () async {
    final service = CloudSyncService(
      client: _FakeRemoteSyncClient(throwsOnFetch: true),
      logger: const _NoopLogger(),
    );
    final logs = <ExerciseLog>[_log('a', 10, DateTime(2026, 1, 1))];

    final result = await service.mergeWorkoutLogs(logs);

    expect(result.status, CloudSyncStatus.failed);
    expect(result.value, logs);
  });

  test(
    'uses remote preferences when available and uploads merged value',
    () async {
      const remotePreferences = UserPreferences(
        hasCompletedOnboarding: true,
        primaryExercise: ExerciseType.pullUp,
        primaryExerciseMaxReps: 8,
      );
      final remote = _FakeRemoteSyncClient(
        remotePreferences: remotePreferences,
      );
      final service = CloudSyncService(
        client: remote,
        logger: const _NoopLogger(),
      );

      final result = await service.mergeUserPreferences(
        UserPreferences.defaults,
      );

      expect(result.status, CloudSyncStatus.synced);
      expect(result.value.primaryExercise, ExerciseType.pullUp);
      expect(remote.uploadedPreferences, remotePreferences);
    },
  );

  test(
    'CloudSyncedWorkoutLogRepository saves locally when upload fails',
    () async {
      final local = _MemoryWorkoutLogRepository();
      final service = CloudSyncService(
        client: _FailingUploadRemoteSyncClient(),
        logger: const _NoopLogger(),
      );
      final repository = CloudSyncedWorkoutLogRepository(
        localRepository: local,
        cloudSyncService: service,
      );
      final logs = <ExerciseLog>[_log('local', 7, DateTime(2026, 1, 1))];

      await repository.saveLogs(logs);

      expect(local.savedLogs, logs);
    },
  );

  test(
    'CloudSyncedWorkoutLogRepository persists merged remote logs locally',
    () async {
      final local = _MemoryWorkoutLogRepository(
        initialLogs: <ExerciseLog>[_log('local', 7, DateTime(2026, 1, 1))],
      );
      final service = CloudSyncService(
        client: _FakeRemoteSyncClient(
          remoteLogs: <ExerciseLog>[_log('remote', 8, DateTime(2026, 1, 2))],
        ),
        logger: const _NoopLogger(),
      );
      final repository = CloudSyncedWorkoutLogRepository(
        localRepository: local,
        cloudSyncService: service,
      );

      final loaded = await repository.loadLogs();

      expect(loaded.map((log) => log.id), <String>['local', 'remote']);
      expect(local.savedLogs.map((log) => log.id), <String>['local', 'remote']);
    },
  );

  test(
    'CloudSyncedUserPreferencesRepository preserves local save when upload fails',
    () async {
      final local = _MemoryUserPreferencesRepository();
      final service = CloudSyncService(
        client: _FailingUploadRemoteSyncClient(),
        logger: const _NoopLogger(),
      );
      final repository = CloudSyncedUserPreferencesRepository(
        localRepository: local,
        cloudSyncService: service,
      );
      const preferences = UserPreferences(
        hasCompletedOnboarding: true,
        primaryExercise: ExerciseType.dips,
      );

      await repository.saveUserPreferences(preferences);

      expect(local.savedPreferences, preferences);
    },
  );
}

ExerciseLog _log(String id, int reps, DateTime timestamp) {
  return ExerciseLog(
    id: id,
    type: ExerciseType.pushUp,
    reps: reps,
    timestamp: timestamp,
  );
}

final class _FakeRemoteSyncClient implements RemoteSyncClient {
  _FakeRemoteSyncClient({
    this.isConfigured = true,
    this.remoteLogs = const <ExerciseLog>[],
    this.remotePreferences,
    this.throwsOnFetch = false,
  });

  @override
  final bool isConfigured;
  final List<ExerciseLog> remoteLogs;
  final UserPreferences? remotePreferences;
  final bool throwsOnFetch;
  List<ExerciseLog> uploadedLogs = const <ExerciseLog>[];
  UserPreferences? uploadedPreferences;

  @override
  Future<List<ExerciseLog>> fetchWorkoutLogs() async {
    if (throwsOnFetch) throw StateError('remote-down');
    return remoteLogs;
  }

  @override
  Future<void> upsertWorkoutLogs(List<ExerciseLog> logs) async {
    uploadedLogs = logs;
  }

  @override
  Future<UserPreferences?> fetchUserPreferences() async => remotePreferences;

  @override
  Future<void> upsertUserPreferences(UserPreferences preferences) async {
    uploadedPreferences = preferences;
  }

  @override
  Future<GtgCoachRecommendation?> fetchLatestCoachRecommendation() async =>
      null;
}

final class _FailingUploadRemoteSyncClient extends _FakeRemoteSyncClient {
  _FailingUploadRemoteSyncClient();

  @override
  Future<void> upsertWorkoutLogs(List<ExerciseLog> logs) async {
    throw StateError('upload-failed');
  }

  @override
  Future<void> upsertUserPreferences(UserPreferences preferences) async {
    throw StateError('upload-failed');
  }
}

final class _MemoryWorkoutLogRepository implements WorkoutLogRepository {
  _MemoryWorkoutLogRepository({
    List<ExerciseLog> initialLogs = const <ExerciseLog>[],
  }) : savedLogs = initialLogs;

  List<ExerciseLog> savedLogs;

  @override
  Future<List<ExerciseLog>> loadLogs() async => savedLogs;

  @override
  Future<void> saveLogs(List<ExerciseLog> logs) async {
    savedLogs = List<ExerciseLog>.unmodifiable(logs);
  }
}

final class _MemoryUserPreferencesRepository
    implements UserPreferencesRepository {
  UserPreferences savedPreferences = UserPreferences.defaults;

  @override
  Future<UserPreferences> loadUserPreferences() async => savedPreferences;

  @override
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    savedPreferences = preferences;
  }
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
