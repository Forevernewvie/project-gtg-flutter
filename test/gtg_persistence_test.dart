import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/core/models/reminder_settings.dart';
import 'package:project_gtg/core/models/user_preferences.dart';
import 'package:project_gtg/data/persistence/directory_provider.dart';
import 'package:project_gtg/data/persistence/gtg_persistence.dart';

class FakeDirectoryProvider implements DirectoryProvider {
  FakeDirectoryProvider(this.dir);

  final Directory dir;

  @override
  Future<Directory> getApplicationSupportDirectory() async {
    return dir;
  }
}

void main() {
  test('corrupted JSON is quarantined and load returns defaults', () async {
    final tmp = await Directory.systemTemp.createTemp('gtg_persist_test_');
    addTearDown(() async {
      if (await tmp.exists()) {
        await tmp.delete(recursive: true);
      }
    });

    final persistence = GtgPersistence(
      directoryProvider: FakeDirectoryProvider(tmp),
    );

    // Create an invalid JSON file.
    final projectDir = Directory('${tmp.path}/ProjectGTG');
    await projectDir.create(recursive: true);
    final logsFile = File('${projectDir.path}/exercise_logs.json');
    await logsFile.writeAsString('{not json');

    final logs = await persistence.loadLogs();
    expect(logs, isEmpty);

    final quarantined = projectDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.contains('exercise_logs.json.corrupted-'))
        .toList();

    expect(quarantined.length, 1);
  });

  test('save/load roundtrip keeps data and cleans tmp files', () async {
    final tmp = await Directory.systemTemp.createTemp('gtg_persist_test_');
    addTearDown(() async {
      if (await tmp.exists()) {
        await tmp.delete(recursive: true);
      }
    });

    final persistence = GtgPersistence(
      directoryProvider: FakeDirectoryProvider(tmp),
    );

    final logs = <ExerciseLog>[
      ExerciseLog(
        id: '1',
        type: ExerciseType.pushUp,
        reps: 12,
        timestamp: DateTime(2026, 2, 17, 9, 0),
      ),
      ExerciseLog(
        id: '2',
        type: ExerciseType.pullUp,
        reps: 4,
        timestamp: DateTime(2026, 2, 17, 12, 30),
      ),
    ];

    await persistence.saveLogs(logs);
    await persistence.saveReminderSettings(
      const ReminderSettings(
        enabled: true,
        intervalMinutes: 60,
        quietStartMinutes: 23 * 60,
        quietEndMinutes: 7 * 60,
        skipWeekends: true,
        maxPerDay: 8,
      ),
    );
    await persistence.saveUserPreferences(
      const UserPreferences(
        hasCompletedOnboarding: true,
        primaryExercise: ExerciseType.dips,
      ),
    );

    final loadedLogs = await persistence.loadLogs();
    final loadedReminder = await persistence.loadReminderSettings();
    final loadedPrefs = await persistence.loadUserPreferences();

    expect(loadedLogs.length, 2);
    expect(loadedLogs.first.reps, 12);
    expect(loadedLogs.last.type, ExerciseType.pullUp);

    expect(loadedReminder.enabled, isTrue);
    expect(loadedReminder.maxPerDay, 8);
    expect(loadedReminder.skipWeekends, isTrue);

    expect(loadedPrefs.hasCompletedOnboarding, isTrue);
    expect(loadedPrefs.primaryExercise, ExerciseType.dips);

    final projectDir = Directory('${tmp.path}/ProjectGTG');
    final tmpFiles = projectDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.tmp'))
        .toList();
    expect(tmpFiles, isEmpty);
  });
}
