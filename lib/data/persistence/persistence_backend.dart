import '../../core/models/exercise_log.dart';
import '../../core/models/reminder_settings.dart';
import '../../core/models/user_preferences.dart';
import '../isar/isar_persistence.dart';
import 'json_file_store.dart';
import 'persistence_constants.dart';

/// Contract for feature data persistence independent of the concrete backend.
abstract interface class PersistenceBackend {
  /// Loads all workout logs from the backend.
  Future<List<ExerciseLog>> loadLogs();

  /// Persists all workout logs to the backend.
  Future<void> saveLogs(List<ExerciseLog> logs);

  /// Loads reminder settings from the backend.
  Future<ReminderSettings> loadReminderSettings();

  /// Persists reminder settings to the backend.
  Future<void> saveReminderSettings(ReminderSettings settings);

  /// Loads user preferences from the backend.
  Future<UserPreferences> loadUserPreferences();

  /// Persists user preferences to the backend.
  Future<void> saveUserPreferences(UserPreferences preferences);

  /// Releases backend resources when deterministic cleanup is required.
  Future<void> close({bool deleteFromDisk = false});
}

/// JSON-file implementation of the app persistence backend.
final class JsonPersistenceBackend implements PersistenceBackend {
  /// Creates a JSON backend backed by the provided file store.
  const JsonPersistenceBackend({required JsonFileStore fileStore})
    : _fileStore = fileStore;

  final JsonFileStore _fileStore;

  @override
  /// Loads workout logs from JSON while tolerating missing or malformed files.
  Future<List<ExerciseLog>> loadLogs() async {
    final raw = await _fileStore.readJson(PersistenceConstants.logsFileName);
    if (raw == null || raw is! List) return <ExerciseLog>[];

    final logs = <ExerciseLog>[];
    for (final item in raw) {
      final map = _tryMap(item);
      if (map != null) {
        logs.add(ExerciseLog.fromJson(map));
      }
    }
    return logs;
  }

  @override
  /// Persists workout logs to JSON in one atomic write.
  Future<void> saveLogs(List<ExerciseLog> logs) async {
    final payload = logs.map((e) => e.toJson()).toList(growable: false);
    await _fileStore.writeJson(PersistenceConstants.logsFileName, payload);
  }

  @override
  /// Loads reminder settings from JSON with defaults as a safe fallback.
  Future<ReminderSettings> loadReminderSettings() async {
    final raw = await _fileStore.readJson(
      PersistenceConstants.reminderSettingsFileName,
    );
    final map = _tryMap(raw);
    if (map != null) {
      return ReminderSettings.fromJson(map);
    }
    return ReminderSettings.defaults;
  }

  @override
  /// Persists reminder settings to JSON in one atomic write.
  Future<void> saveReminderSettings(ReminderSettings settings) async {
    await _fileStore.writeJson(
      PersistenceConstants.reminderSettingsFileName,
      settings.toJson(),
    );
  }

  @override
  /// Loads user preferences from JSON with defaults as a safe fallback.
  Future<UserPreferences> loadUserPreferences() async {
    final raw = await _fileStore.readJson(
      PersistenceConstants.userPreferencesFileName,
    );
    final map = _tryMap(raw);
    if (map != null) {
      return UserPreferences.fromJson(map);
    }
    return UserPreferences.defaults;
  }

  @override
  /// Persists user preferences to JSON in one atomic write.
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    await _fileStore.writeJson(
      PersistenceConstants.userPreferencesFileName,
      preferences.toJson(),
    );
  }

  @override
  /// JSON storage has no open process resource to close, so this is a no-op.
  Future<void> close({bool deleteFromDisk = false}) async {}

  /// Normalizes dynamic decoded JSON into a string-keyed map when possible.
  Map<String, dynamic>? _tryMap(Object? raw) {
    if (raw is! Map) return null;
    return raw.map((key, value) => MapEntry('$key', value));
  }
}

/// Isar-backed implementation of the app persistence backend.
final class IsarPersistenceBackend implements PersistenceBackend {
  /// Creates an Isar backend backed by the provided Isar persistence adapter.
  const IsarPersistenceBackend({required IsarPersistence isarPersistence})
    : _isarPersistence = isarPersistence;

  final IsarPersistence _isarPersistence;

  @override
  /// Loads workout logs from Isar.
  Future<List<ExerciseLog>> loadLogs() {
    return _isarPersistence.loadLogs();
  }

  @override
  /// Persists workout logs to Isar.
  Future<void> saveLogs(List<ExerciseLog> logs) {
    return _isarPersistence.saveLogs(logs);
  }

  @override
  /// Loads reminder settings from Isar.
  Future<ReminderSettings> loadReminderSettings() {
    return _isarPersistence.loadReminderSettings();
  }

  @override
  /// Persists reminder settings to Isar.
  Future<void> saveReminderSettings(ReminderSettings settings) {
    return _isarPersistence.saveReminderSettings(settings);
  }

  @override
  /// Loads user preferences from Isar.
  Future<UserPreferences> loadUserPreferences() {
    return _isarPersistence.loadUserPreferences();
  }

  @override
  /// Persists user preferences to Isar.
  Future<void> saveUserPreferences(UserPreferences preferences) {
    return _isarPersistence.saveUserPreferences(preferences);
  }

  @override
  /// Closes the underlying Isar persistence resources.
  Future<void> close({bool deleteFromDisk = false}) {
    return _isarPersistence.close(deleteFromDisk: deleteFromDisk);
  }
}
