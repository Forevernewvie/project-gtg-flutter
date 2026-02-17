import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/core/models/reminder_settings.dart';
import 'package:project_gtg/core/models/user_preferences.dart';
import 'package:project_gtg/data/persistence/directory_provider.dart';
import 'package:project_gtg/data/persistence/gtg_persistence.dart';
import 'package:project_gtg/data/persistence/persistence_provider.dart';
import 'package:project_gtg/features/onboarding/state/user_preferences_controller.dart';

class _DummyDirectoryProvider implements DirectoryProvider {
  @override
  Future<Directory> getApplicationSupportDirectory() async {
    return Directory('/tmp');
  }
}

class _MemoryPersistence extends GtgPersistence {
  _MemoryPersistence(this._prefs)
    : super(directoryProvider: _DummyDirectoryProvider());

  UserPreferences _prefs;

  @override
  Future<UserPreferences> loadUserPreferences() async => _prefs;

  @override
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    _prefs = preferences;
  }

  @override
  Future<List<ExerciseLog>> loadLogs() async => const <ExerciseLog>[];

  @override
  Future<ReminderSettings> loadReminderSettings() async {
    return ReminderSettings.defaults;
  }
}

void main() {
  test(
    'completeOnboarding persists primary exercise and completion flag',
    () async {
      final persistence = _MemoryPersistence(UserPreferences.defaults);

      final container = ProviderContainer(
        overrides: [persistenceProvider.overrideWithValue(persistence)],
      );
      addTearDown(container.dispose);

      final before = await container.read(
        userPreferencesControllerProvider.future,
      );
      expect(before.hasCompletedOnboarding, isFalse);
      expect(before.primaryExercise, ExerciseType.pushUp);

      await container
          .read(userPreferencesControllerProvider.notifier)
          .completeOnboarding(ExerciseType.dips);

      final after = container
          .read(userPreferencesControllerProvider)
          .asData!
          .value;
      expect(after.hasCompletedOnboarding, isTrue);
      expect(after.primaryExercise, ExerciseType.dips);

      final persisted = await persistence.loadUserPreferences();
      expect(persisted.hasCompletedOnboarding, isTrue);
      expect(persisted.primaryExercise, ExerciseType.dips);
    },
  );
}
