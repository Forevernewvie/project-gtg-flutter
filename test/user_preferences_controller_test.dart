import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/core/models/user_preferences.dart';
import 'package:project_gtg/data/persistence/persistence_repositories.dart';
import 'package:project_gtg/features/onboarding/state/user_preferences_controller.dart';

class _MemoryUserPreferencesRepository implements UserPreferencesRepository {
  /// Creates an in-memory preferences repository for isolated controller tests.
  _MemoryUserPreferencesRepository(this._prefs);

  UserPreferences _prefs;

  @override
  /// Returns the stored preferences without touching disk or platform APIs.
  Future<UserPreferences> loadUserPreferences() async => _prefs;

  @override
  /// Stores the latest preferences in memory for assertion-friendly tests.
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    _prefs = preferences;
  }
}

void main() {
  test(
    'completeOnboarding persists primary exercise and completion flag',
    () async {
      final repository = _MemoryUserPreferencesRepository(
        UserPreferences.defaults,
      );

      final container = ProviderContainer(
        overrides: [
          userPreferencesRepositoryProvider.overrideWithValue(repository),
        ],
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

      final persisted = await repository.loadUserPreferences();
      expect(persisted.hasCompletedOnboarding, isTrue);
      expect(persisted.primaryExercise, ExerciseType.dips);
    },
  );
}
