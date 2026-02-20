import 'package:isar_community/isar.dart';

import '../../../core/models/exercise_type.dart';
import '../../../core/models/user_preferences.dart';
import '../../persistence/persistence_constants.dart';

part 'user_preferences_entity.g.dart';

@collection
class UserPreferencesEntity {
  UserPreferencesEntity();

  Id id = PersistenceConstants.singletonEntityId;

  bool hasCompletedOnboarding = UserPreferences.defaults.hasCompletedOnboarding;
  String primaryExerciseKey = UserPreferences.defaults.primaryExercise.key;

  /// Internal storage schema version marker for safe one-time migration.
  int storageVersion = 0;

  /// Converts this persistence entity into the domain model.
  UserPreferences toModel() {
    final primaryExercise =
        ExerciseTypeX.fromKey(primaryExerciseKey) ??
        UserPreferences.defaults.primaryExercise;

    return UserPreferences(
      hasCompletedOnboarding: hasCompletedOnboarding,
      primaryExercise: primaryExercise,
    );
  }

  /// Creates a singleton Isar entity from the domain preferences model.
  static UserPreferencesEntity fromModel(
    UserPreferences model, {
    required int storageVersion,
  }) {
    return UserPreferencesEntity()
      ..hasCompletedOnboarding = model.hasCompletedOnboarding
      ..primaryExerciseKey = model.primaryExercise.key
      ..storageVersion = storageVersion;
  }
}
