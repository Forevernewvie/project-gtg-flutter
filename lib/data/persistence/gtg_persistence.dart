import '../../core/logging/app_logger.dart';
import '../../core/models/exercise_log.dart';
import '../../core/models/reminder_settings.dart';
import '../../core/models/user_preferences.dart';
import 'directory_provider.dart';
import 'json_file_store.dart';
import 'persistence_constants.dart';

/// High-level repository for app persistence entities.
class GtgPersistence {
  GtgPersistence({
    DirectoryProvider? directoryProvider,
    JsonFileStore? fileStore,
    AppLogger? logger,
  }) : _fileStore =
           fileStore ??
           JsonFileStore(
             directoryProvider: directoryProvider ?? DefaultDirectoryProvider(),
             logger: logger ?? const DebugAppLogger(),
           );

  final JsonFileStore _fileStore;

  /// Loads all exercise logs from local storage.
  Future<List<ExerciseLog>> loadLogs() async {
    final raw = await _fileStore.readJson(PersistenceConstants.logsFileName);
    if (raw == null) return <ExerciseLog>[];
    if (raw is! List) return <ExerciseLog>[];

    final logs = <ExerciseLog>[];
    for (final item in raw) {
      final map = _tryMap(item);
      if (map != null) {
        logs.add(ExerciseLog.fromJson(map));
      }
    }
    return logs;
  }

  /// Persists all exercise logs atomically.
  Future<void> saveLogs(List<ExerciseLog> logs) async {
    final payload = logs.map((e) => e.toJson()).toList(growable: false);
    await _fileStore.writeJson(PersistenceConstants.logsFileName, payload);
  }

  /// Loads reminder settings with defaults as a safe fallback.
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

  /// Persists reminder settings atomically.
  Future<void> saveReminderSettings(ReminderSettings settings) async {
    await _fileStore.writeJson(
      PersistenceConstants.reminderSettingsFileName,
      settings.toJson(),
    );
  }

  /// Loads user preferences with defaults as a safe fallback.
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

  /// Persists user preferences atomically.
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    await _fileStore.writeJson(
      PersistenceConstants.userPreferencesFileName,
      preferences.toJson(),
    );
  }

  /// Attempts to normalize dynamic map data into string-keyed JSON map.
  Map<String, dynamic>? _tryMap(Object? raw) {
    if (raw is! Map) return null;
    return raw.map((key, value) => MapEntry('$key', value));
  }
}
