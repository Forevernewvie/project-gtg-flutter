import 'dart:io';

import 'package:isar_community/isar.dart';

import '../persistence/directory_provider.dart';
import '../persistence/persistence_constants.dart';
import 'entities/exercise_log_entity.dart';
import 'entities/reminder_settings_entity.dart';
import 'entities/user_preferences_entity.dart';

/// Owns Isar open/close lifecycle and database path resolution.
class IsarDatabase {
  IsarDatabase({
    required DirectoryProvider directoryProvider,
    this.databaseName = PersistenceConstants.isarDatabaseName,
  }) : _directoryProvider = directoryProvider;

  final DirectoryProvider _directoryProvider;
  final String databaseName;

  Isar? _isar;

  /// Opens and memoizes the Isar instance for this process.
  Future<Isar> open() async {
    final existing = _isar;
    if (existing != null && existing.isOpen) {
      return existing;
    }

    final baseDir = await _directoryProvider.getApplicationSupportDirectory();
    final appDir = Directory(
      '${baseDir.path}/${PersistenceConstants.appDirectoryName}',
    );
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }

    _isar = await Isar.open(
      <CollectionSchema<dynamic>>[
        ExerciseLogEntitySchema,
        ReminderSettingsEntitySchema,
        UserPreferencesEntitySchema,
      ],
      name: databaseName,
      directory: appDir.path,
      inspector: false,
    );

    return _isar!;
  }

  /// Closes the memoized Isar instance if it is currently open.
  Future<void> close({bool deleteFromDisk = false}) async {
    final current = _isar;
    if (current == null) return;

    if (current.isOpen) {
      current.close(deleteFromDisk: deleteFromDisk);
    }
    _isar = null;
  }
}
