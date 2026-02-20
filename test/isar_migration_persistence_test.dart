import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_gtg/core/logging/app_logger.dart';
import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/core/models/reminder_settings.dart';
import 'package:project_gtg/core/models/user_preferences.dart';
import 'package:project_gtg/data/isar/isar_database.dart';
import 'package:project_gtg/data/isar/isar_persistence.dart';
import 'package:project_gtg/data/persistence/directory_provider.dart';
import 'package:project_gtg/data/persistence/gtg_persistence.dart';
import 'package:project_gtg/data/persistence/json_file_store.dart';
import 'package:project_gtg/data/persistence/persistence_constants.dart';

class _FakeDirectoryProvider implements DirectoryProvider {
  _FakeDirectoryProvider(this.dir);

  final Directory dir;

  @override
  Future<Directory> getApplicationSupportDirectory() async => dir;
}

class _SpyLogger implements AppLogger {
  final List<String> infos = <String>[];
  final List<String> warnings = <String>[];
  final List<String> errors = <String>[];

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    errors.add(message);
  }

  @override
  void info(String message) {
    infos.add(message);
  }

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    warnings.add(message);
  }
}

class _InMemoryIsarStore {
  List<ExerciseLog> logs = <ExerciseLog>[];
  ReminderSettings reminderSettings = ReminderSettings.defaults;
  UserPreferences userPreferences = UserPreferences.defaults;
  bool hasMigrationMarker = false;
  int migrationRuns = 0;
}

class _InMemoryIsarPersistence extends IsarPersistence {
  _InMemoryIsarPersistence({required this.store, required super.database});

  final _InMemoryIsarStore store;

  @override
  Future<void> open() async {}

  @override
  Future<bool> hasMigrationMarker() async => store.hasMigrationMarker;

  @override
  Future<void> migrateFromLegacy({
    required List<ExerciseLog> logs,
    required ReminderSettings reminderSettings,
    required UserPreferences userPreferences,
  }) async {
    store.logs = List<ExerciseLog>.from(logs);
    store.reminderSettings = reminderSettings;
    store.userPreferences = userPreferences;
    store.hasMigrationMarker = true;
    store.migrationRuns += 1;
  }

  @override
  Future<List<ExerciseLog>> loadLogs() async =>
      List<ExerciseLog>.from(store.logs);

  @override
  Future<void> saveLogs(List<ExerciseLog> logs) async {
    store.logs = List<ExerciseLog>.from(logs);
  }

  @override
  Future<ReminderSettings> loadReminderSettings() async =>
      store.reminderSettings;

  @override
  Future<void> saveReminderSettings(ReminderSettings settings) async {
    store.reminderSettings = settings;
  }

  @override
  Future<UserPreferences> loadUserPreferences() async => store.userPreferences;

  @override
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    store.userPreferences = preferences;
  }
}

class _ThrowingIsarPersistence extends IsarPersistence {
  _ThrowingIsarPersistence(IsarDatabase database) : super(database: database);

  @override
  Future<void> open() {
    throw StateError('forced-open-failure');
  }
}

void main() {
  test(
    'migrates legacy JSON into Isar once and keeps data across restart',
    () async {
      final tmp = await Directory.systemTemp.createTemp('isar_migration_test_');
      addTearDown(() async {
        if (await tmp.exists()) {
          await tmp.delete(recursive: true);
        }
      });

      final dirProvider = _FakeDirectoryProvider(tmp);
      final logger = _SpyLogger();
      final jsonStore = JsonFileStore(
        directoryProvider: dirProvider,
        logger: logger,
      );

      final logs = <ExerciseLog>[
        ExerciseLog(
          id: '1',
          type: ExerciseType.pushUp,
          reps: 11,
          timestamp: DateTime(2026, 2, 20, 8, 30),
        ),
        ExerciseLog(
          id: '2',
          type: ExerciseType.pullUp,
          reps: 5,
          timestamp: DateTime(2026, 2, 20, 12, 0),
        ),
      ];
      const settings = ReminderSettings(
        enabled: true,
        intervalMinutes: 45,
        quietStartMinutes: 23 * 60,
        quietEndMinutes: 7 * 60,
        skipWeekends: true,
        maxPerDay: 10,
      );
      const preferences = UserPreferences(
        hasCompletedOnboarding: true,
        primaryExercise: ExerciseType.dips,
      );

      await jsonStore.writeJson(
        PersistenceConstants.logsFileName,
        logs.map((e) => e.toJson()).toList(growable: false),
      );
      await jsonStore.writeJson(
        PersistenceConstants.reminderSettingsFileName,
        settings.toJson(),
      );
      await jsonStore.writeJson(
        PersistenceConstants.userPreferencesFileName,
        preferences.toJson(),
      );

      final memoryStore = _InMemoryIsarStore();
      const dbName = 'isar_migration_primary';
      final persistence = GtgPersistence(
        directoryProvider: dirProvider,
        logger: logger,
        enableIsarMigration: true,
        isarPersistence: _InMemoryIsarPersistence(
          store: memoryStore,
          database: IsarDatabase(
            directoryProvider: dirProvider,
            databaseName: dbName,
          ),
        ),
      );

      final migratedLogs = await persistence.loadLogs();
      final migratedSettings = await persistence.loadReminderSettings();
      final migratedPrefs = await persistence.loadUserPreferences();

      expect(migratedLogs.length, 2);
      expect(migratedLogs.first.reps, 11);
      expect(migratedSettings.intervalMinutes, 45);
      expect(migratedPrefs.primaryExercise, ExerciseType.dips);

      final projectDir = Directory('${tmp.path}/ProjectGTG');
      final legacyFiles = <String>[
        PersistenceConstants.logsFileName,
        PersistenceConstants.reminderSettingsFileName,
        PersistenceConstants.userPreferencesFileName,
      ];
      for (final fileName in legacyFiles) {
        final file = File('${projectDir.path}/$fileName');
        if (await file.exists()) {
          await file.delete();
        }
      }

      final logsAfterLegacyDelete = await persistence.loadLogs();
      expect(logsAfterLegacyDelete.length, 2);
      expect(memoryStore.migrationRuns, 1);
      await persistence.close();

      final restarted = GtgPersistence(
        directoryProvider: dirProvider,
        logger: logger,
        enableIsarMigration: true,
        isarPersistence: _InMemoryIsarPersistence(
          store: memoryStore,
          database: IsarDatabase(
            directoryProvider: dirProvider,
            databaseName: dbName,
          ),
        ),
      );
      final afterRestart = await restarted.loadLogs();
      expect(afterRestart.length, 2);
      expect(afterRestart.last.type, ExerciseType.pullUp);
      expect(memoryStore.migrationRuns, 1);
      await restarted.close();

      expect(
        logger.infos.any((m) => m.contains('migrated to Isar successfully')),
        isTrue,
      );
    },
  );

  test('falls back to JSON backend when Isar initialization fails', () async {
    final tmp = await Directory.systemTemp.createTemp('isar_fallback_test_');
    addTearDown(() async {
      if (await tmp.exists()) {
        await tmp.delete(recursive: true);
      }
    });

    final dirProvider = _FakeDirectoryProvider(tmp);
    final logger = _SpyLogger();
    final jsonStore = JsonFileStore(
      directoryProvider: dirProvider,
      logger: logger,
    );

    final initialLogs = <ExerciseLog>[
      ExerciseLog(
        id: 'j-1',
        type: ExerciseType.pushUp,
        reps: 7,
        timestamp: DateTime(2026, 2, 21, 7, 0),
      ),
    ];

    await jsonStore.writeJson(
      PersistenceConstants.logsFileName,
      initialLogs.map((e) => e.toJson()).toList(growable: false),
    );

    final persistence = GtgPersistence(
      directoryProvider: dirProvider,
      logger: logger,
      enableIsarMigration: true,
      isarPersistence: _ThrowingIsarPersistence(
        IsarDatabase(directoryProvider: dirProvider, databaseName: 'unused'),
      ),
    );

    final loaded = await persistence.loadLogs();
    expect(loaded.length, 1);
    expect(loaded.first.reps, 7);

    final updatedLogs = <ExerciseLog>[
      ExerciseLog(
        id: 'j-2',
        type: ExerciseType.dips,
        reps: 9,
        timestamp: DateTime(2026, 2, 21, 9, 30),
      ),
    ];
    await persistence.saveLogs(updatedLogs);

    final raw = await jsonStore.readJson(PersistenceConstants.logsFileName);
    expect(raw, isA<List<dynamic>>());
    final rawList = raw! as List<dynamic>;
    expect(rawList.length, 1);
    final map = (rawList.first as Map).cast<String, Object?>();
    final roundtrip = ExerciseLog.fromJson(map);
    expect(roundtrip.type, ExerciseType.dips);
    expect(roundtrip.reps, 9);

    expect(
      logger.warnings.any((m) => m.contains('Falling back to JSON backend')),
      isTrue,
    );
  });
}
