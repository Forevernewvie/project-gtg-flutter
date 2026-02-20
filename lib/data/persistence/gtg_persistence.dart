import '../../core/logging/app_logger.dart';
import '../../core/models/exercise_log.dart';
import '../../core/models/reminder_settings.dart';
import '../../core/models/user_preferences.dart';
import '../isar/isar_database.dart';
import '../isar/isar_persistence.dart';
import 'directory_provider.dart';
import 'json_file_store.dart';
import 'persistence_constants.dart';

enum _PersistenceMode { unknown, json, isar }

/// High-level repository for app persistence entities.
///
/// Migration strategy:
/// - Prefer Isar backend.
/// - If Isar has no migration marker, import from legacy JSON once.
/// - If Isar init/migration fails, gracefully fallback to JSON backend.
class GtgPersistence {
  GtgPersistence({
    DirectoryProvider? directoryProvider,
    JsonFileStore? fileStore,
    IsarDatabase? isarDatabase,
    IsarPersistence? isarPersistence,
    AppLogger? logger,
    bool enableIsarMigration = true,
  }) : _logger = logger ?? const DebugAppLogger(),
       _enableIsarMigration = enableIsarMigration {
    final resolvedDirectoryProvider =
        directoryProvider ?? DefaultDirectoryProvider();

    _fileStore =
        fileStore ??
        JsonFileStore(
          directoryProvider: resolvedDirectoryProvider,
          logger: _logger,
        );

    _isarPersistence =
        isarPersistence ??
        IsarPersistence(
          database:
              isarDatabase ??
              IsarDatabase(directoryProvider: resolvedDirectoryProvider),
        );
  }

  final AppLogger _logger;
  final bool _enableIsarMigration;

  late final JsonFileStore _fileStore;
  late final IsarPersistence _isarPersistence;

  _PersistenceMode _mode = _PersistenceMode.unknown;
  Future<void>? _initializationFuture;

  /// Loads all exercise logs from persistence.
  Future<List<ExerciseLog>> loadLogs() async {
    await _ensureInitialized();

    if (_mode == _PersistenceMode.isar) {
      return _isarPersistence.loadLogs();
    }

    return _loadLogsFromJson();
  }

  /// Persists all exercise logs to the selected backend.
  Future<void> saveLogs(List<ExerciseLog> logs) async {
    await _ensureInitialized();

    if (_mode == _PersistenceMode.isar) {
      await _isarPersistence.saveLogs(logs);
      return;
    }

    await _saveLogsToJson(logs);
  }

  /// Loads reminder settings with defaults as a safe fallback.
  Future<ReminderSettings> loadReminderSettings() async {
    await _ensureInitialized();

    if (_mode == _PersistenceMode.isar) {
      return _isarPersistence.loadReminderSettings();
    }

    return _loadReminderSettingsFromJson();
  }

  /// Persists reminder settings atomically.
  Future<void> saveReminderSettings(ReminderSettings settings) async {
    await _ensureInitialized();

    if (_mode == _PersistenceMode.isar) {
      await _isarPersistence.saveReminderSettings(settings);
      return;
    }

    await _saveReminderSettingsToJson(settings);
  }

  /// Loads user preferences with defaults as a safe fallback.
  Future<UserPreferences> loadUserPreferences() async {
    await _ensureInitialized();

    if (_mode == _PersistenceMode.isar) {
      return _isarPersistence.loadUserPreferences();
    }

    return _loadUserPreferencesFromJson();
  }

  /// Persists user preferences atomically.
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    await _ensureInitialized();

    if (_mode == _PersistenceMode.isar) {
      await _isarPersistence.saveUserPreferences(preferences);
      return;
    }

    await _saveUserPreferencesToJson(preferences);
  }

  /// Releases Isar database resources when callers need deterministic cleanup.
  Future<void> close({bool deleteFromDisk = false}) async {
    if (_mode != _PersistenceMode.isar) return;
    await _isarPersistence.close(deleteFromDisk: deleteFromDisk);
  }

  Future<void> _ensureInitialized() async {
    final future = _initializationFuture ??= _initializeBackend();
    await future;
  }

  Future<void> _initializeBackend() async {
    final stopwatch = Stopwatch()..start();
    if (!_enableIsarMigration) {
      _mode = _PersistenceMode.json;
      stopwatch.stop();
      _logger.info(
        'Persistence initialized in JSON mode (Isar migration disabled) in '
        '${stopwatch.elapsedMilliseconds}ms.',
      );
      return;
    }

    try {
      await _isarPersistence.open();
      final hasMarker = await _isarPersistence.hasMigrationMarker();

      if (!hasMarker) {
        final logs = await _loadLogsFromJson();
        final reminderSettings = await _loadReminderSettingsFromJson();
        final userPreferences = await _loadUserPreferencesFromJson();

        await _isarPersistence.migrateFromLegacy(
          logs: logs,
          reminderSettings: reminderSettings,
          userPreferences: userPreferences,
        );

        _logger.info('Legacy JSON data migrated to Isar successfully.');
      }

      _mode = _PersistenceMode.isar;
      stopwatch.stop();
      _logger.info(
        'Persistence initialized in Isar mode in '
        '${stopwatch.elapsedMilliseconds}ms.',
      );
    } catch (error, stackTrace) {
      _mode = _PersistenceMode.json;
      stopwatch.stop();
      _logger.warning(
        'Isar initialization/migration failed. Falling back to JSON backend.',
        error: error,
        stackTrace: stackTrace,
      );
      _logger.info(
        'Persistence initialized in JSON fallback mode in '
        '${stopwatch.elapsedMilliseconds}ms.',
      );
    }
  }

  Future<List<ExerciseLog>> _loadLogsFromJson() async {
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

  Future<void> _saveLogsToJson(List<ExerciseLog> logs) async {
    final payload = logs.map((e) => e.toJson()).toList(growable: false);
    await _fileStore.writeJson(PersistenceConstants.logsFileName, payload);
  }

  Future<ReminderSettings> _loadReminderSettingsFromJson() async {
    final raw = await _fileStore.readJson(
      PersistenceConstants.reminderSettingsFileName,
    );
    final map = _tryMap(raw);
    if (map != null) {
      return ReminderSettings.fromJson(map);
    }
    return ReminderSettings.defaults;
  }

  Future<void> _saveReminderSettingsToJson(ReminderSettings settings) async {
    await _fileStore.writeJson(
      PersistenceConstants.reminderSettingsFileName,
      settings.toJson(),
    );
  }

  Future<UserPreferences> _loadUserPreferencesFromJson() async {
    final raw = await _fileStore.readJson(
      PersistenceConstants.userPreferencesFileName,
    );
    final map = _tryMap(raw);
    if (map != null) {
      return UserPreferences.fromJson(map);
    }
    return UserPreferences.defaults;
  }

  Future<void> _saveUserPreferencesToJson(UserPreferences preferences) async {
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
