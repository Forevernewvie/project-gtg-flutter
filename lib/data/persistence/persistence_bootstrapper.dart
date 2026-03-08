import '../../core/logging/app_logger.dart';
import '../../core/models/exercise_log.dart';
import '../../core/models/reminder_settings.dart';
import '../../core/models/user_preferences.dart';
import '../isar/isar_persistence.dart';
import 'persistence_backend.dart';

/// Selects the runtime persistence backend and performs one-time migration if needed.
final class PersistenceBootstrapper {
  /// Creates a bootstrapper that can choose between JSON and Isar backends.
  const PersistenceBootstrapper({
    required AppLogger logger,
    required bool enableIsarMigration,
    required JsonPersistenceBackend jsonBackend,
    required IsarPersistence isarPersistence,
    required IsarPersistenceBackend isarBackend,
  }) : _logger = logger,
       _enableIsarMigration = enableIsarMigration,
       _jsonBackend = jsonBackend,
       _isarPersistence = isarPersistence,
       _isarBackend = isarBackend;

  final AppLogger _logger;
  final bool _enableIsarMigration;
  final JsonPersistenceBackend _jsonBackend;
  final IsarPersistence _isarPersistence;
  final IsarPersistenceBackend _isarBackend;

  /// Chooses the active backend and migrates legacy JSON data into Isar when enabled.
  Future<PersistenceBackend> initialize() async {
    final stopwatch = Stopwatch()..start();
    if (!_enableIsarMigration) {
      stopwatch.stop();
      _logger.info(
        'Persistence initialized in JSON mode (Isar migration disabled) in '
        '${stopwatch.elapsedMilliseconds}ms.',
      );
      return _jsonBackend;
    }

    try {
      await _isarPersistence.open();
      final hasMarker = await _isarPersistence.hasMigrationMarker();

      if (!hasMarker) {
        final logs = await _jsonBackend.loadLogs();
        final reminderSettings = await _jsonBackend.loadReminderSettings();
        final userPreferences = await _jsonBackend.loadUserPreferences();

        await _migrateFromJson(
          logs: logs,
          reminderSettings: reminderSettings,
          userPreferences: userPreferences,
        );

        _logger.info('Legacy JSON data migrated to Isar successfully.');
      }

      stopwatch.stop();
      _logger.info(
        'Persistence initialized in Isar mode in '
        '${stopwatch.elapsedMilliseconds}ms.',
      );
      return _isarBackend;
    } catch (error, stackTrace) {
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
      return _jsonBackend;
    }
  }

  /// Migrates legacy JSON domain data into Isar in one orchestration step.
  Future<void> _migrateFromJson({
    required List<ExerciseLog> logs,
    required ReminderSettings reminderSettings,
    required UserPreferences userPreferences,
  }) async {
    await _isarPersistence.migrateFromLegacy(
      logs: logs,
      reminderSettings: reminderSettings,
      userPreferences: userPreferences,
    );
  }
}
