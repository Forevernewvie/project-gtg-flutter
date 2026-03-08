import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/exercise_type.dart';
import '../../../core/models/user_preferences.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/logging/logger_provider.dart';
import '../../../data/persistence/persistence_repositories.dart';

final userPreferencesControllerProvider =
    AsyncNotifierProvider<UserPreferencesController, UserPreferences>(
      UserPreferencesController.new,
    );

class UserPreferencesController extends AsyncNotifier<UserPreferences> {
  /// Loads persisted user preferences for onboarding bootstrap.
  @override
  Future<UserPreferences> build() async {
    return _repository.loadUserPreferences();
  }

  /// Marks onboarding complete and persists the selected primary exercise.
  Future<void> completeOnboarding(ExerciseType primaryExercise) async {
    final current = state.asData?.value ?? UserPreferences.defaults;
    final updated = current.copyWith(
      hasCompletedOnboarding: true,
      primaryExercise: primaryExercise,
    );
    state = AsyncData(updated);
    try {
      await _repository.saveUserPreferences(updated);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to persist user preferences.',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Exposes the repository abstraction to keep the controller storage-agnostic.
  UserPreferencesRepository get _repository =>
      ref.read(userPreferencesRepositoryProvider);

  /// Exposes the injected logger so persistence failures remain observable.
  AppLogger get _logger => ref.read(appLoggerProvider);
}
