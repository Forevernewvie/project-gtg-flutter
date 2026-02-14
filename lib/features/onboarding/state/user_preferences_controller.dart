import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/exercise_type.dart';
import '../../../core/models/user_preferences.dart';
import '../../../data/persistence/persistence_provider.dart';

final userPreferencesControllerProvider =
    AsyncNotifierProvider<UserPreferencesController, UserPreferences>(
      UserPreferencesController.new,
    );

class UserPreferencesController extends AsyncNotifier<UserPreferences> {
  @override
  Future<UserPreferences> build() async {
    return ref.read(persistenceProvider).loadUserPreferences();
  }

  Future<void> completeOnboarding(ExerciseType primaryExercise) async {
    final current = state.asData?.value ?? UserPreferences.defaults;
    final updated = current.copyWith(
      hasCompletedOnboarding: true,
      primaryExercise: primaryExercise,
    );
    state = AsyncData(updated);
    await ref.read(persistenceProvider).saveUserPreferences(updated);
  }
}
