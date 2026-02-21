import 'package:isar_community/isar.dart';

import '../../core/models/exercise_log.dart';
import '../../core/models/reminder_settings.dart';
import '../../core/models/user_preferences.dart';
import '../persistence/persistence_constants.dart';
import 'entities/exercise_log_entity.dart';
import 'entities/reminder_settings_entity.dart';
import 'entities/user_preferences_entity.dart';
import 'isar_database.dart';

/// Isar-backed persistence implementation with explicit migration marker.
class IsarPersistence {
  IsarPersistence({required IsarDatabase database}) : _database = database;

  final IsarDatabase _database;

  /// Opens Isar if needed.
  Future<void> open() async {
    await _database.open();
  }

  /// Checks whether migration already ran for the current schema version.
  Future<bool> hasMigrationMarker() async {
    final isar = await _database.open();
    final prefs = await isar.userPreferencesEntitys.get(
      PersistenceConstants.singletonEntityId,
    );
    return prefs?.storageVersion == PersistenceConstants.currentStorageVersion;
  }

  /// Imports legacy data into Isar in one transaction and marks migration done.
  Future<void> migrateFromLegacy({
    required List<ExerciseLog> logs,
    required ReminderSettings reminderSettings,
    required UserPreferences userPreferences,
  }) async {
    final isar = await _database.open();

    final logEntities = logs
        .map(ExerciseLogEntity.fromModel)
        .toList(growable: false);
    final reminderEntity = ReminderSettingsEntity.fromModel(reminderSettings);
    final userPrefsEntity = UserPreferencesEntity.fromModel(
      userPreferences,
      storageVersion: PersistenceConstants.currentStorageVersion,
    );

    await isar.writeTxn(() async {
      await isar.exerciseLogEntitys.clear();
      await isar.reminderSettingsEntitys.clear();
      await isar.userPreferencesEntitys.clear();

      if (logEntities.isNotEmpty) {
        await isar.exerciseLogEntitys.putAll(logEntities);
      }
      await isar.reminderSettingsEntitys.put(reminderEntity);
      await isar.userPreferencesEntitys.put(userPrefsEntity);
    });
  }

  /// Loads all workout logs currently stored in Isar.
  Future<List<ExerciseLog>> loadLogs() async {
    final isar = await _database.open();
    final entities = await isar.exerciseLogEntitys
        .where()
        .anyTimestamp()
        .findAll();

    final logs = <ExerciseLog>[];
    for (final entity in entities) {
      logs.add(entity.toModel());
    }
    return logs;
  }

  /// Replaces all logs in Isar with the provided list.
  Future<void> saveLogs(List<ExerciseLog> logs) async {
    final isar = await _database.open();
    final entities = logs
        .map(ExerciseLogEntity.fromModel)
        .toList(growable: false);

    await isar.writeTxn(() async {
      await isar.exerciseLogEntitys.clear();
      if (entities.isNotEmpty) {
        await isar.exerciseLogEntitys.putAll(entities);
      }
    });
  }

  /// Loads reminder settings, or defaults when no singleton row exists.
  Future<ReminderSettings> loadReminderSettings() async {
    final isar = await _database.open();
    final entity = await isar.reminderSettingsEntitys.get(
      PersistenceConstants.singletonEntityId,
    );
    return entity?.toModel() ?? ReminderSettings.defaults;
  }

  /// Persists reminder settings as a singleton row.
  Future<void> saveReminderSettings(ReminderSettings settings) async {
    final isar = await _database.open();
    final entity = ReminderSettingsEntity.fromModel(settings);

    await isar.writeTxn(() async {
      await isar.reminderSettingsEntitys.put(entity);
    });
  }

  /// Loads user preferences, or defaults when no singleton row exists.
  Future<UserPreferences> loadUserPreferences() async {
    final isar = await _database.open();
    final entity = await isar.userPreferencesEntitys.get(
      PersistenceConstants.singletonEntityId,
    );
    return entity?.toModel() ?? UserPreferences.defaults;
  }

  /// Persists user preferences and refreshes migration version marker.
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    final isar = await _database.open();
    final entity = UserPreferencesEntity.fromModel(
      preferences,
      storageVersion: PersistenceConstants.currentStorageVersion,
    );

    await isar.writeTxn(() async {
      await isar.userPreferencesEntitys.put(entity);
    });
  }

  /// Closes Isar database resources.
  Future<void> close({bool deleteFromDisk = false}) {
    return _database.close(deleteFromDisk: deleteFromDisk);
  }
}
