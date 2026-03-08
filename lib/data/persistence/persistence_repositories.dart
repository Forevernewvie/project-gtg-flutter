import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/app_theme_preference.dart';
import '../../core/models/exercise_log.dart';
import '../../core/models/reminder_settings.dart';
import '../../core/models/user_preferences.dart';
import 'gtg_persistence.dart';
import 'persistence_provider.dart';

/// Contract for reading and writing workout logs without exposing storage details.
abstract interface class WorkoutLogRepository {
  /// Loads all stored workout logs for the current user.
  Future<List<ExerciseLog>> loadLogs();

  /// Persists the complete workout log collection atomically.
  Future<void> saveLogs(List<ExerciseLog> logs);
}

/// Contract for reading and writing reminder settings without exposing storage details.
abstract interface class ReminderSettingsRepository {
  /// Loads the persisted reminder settings or safe defaults.
  Future<ReminderSettings> loadReminderSettings();

  /// Persists reminder settings atomically.
  Future<void> saveReminderSettings(ReminderSettings settings);
}

/// Contract for reading and writing user preferences without exposing storage details.
abstract interface class UserPreferencesRepository {
  /// Loads the persisted onboarding and primary-exercise preferences.
  Future<UserPreferences> loadUserPreferences();

  /// Persists onboarding and primary-exercise preferences atomically.
  Future<void> saveUserPreferences(UserPreferences preferences);
}

/// Contract for reading and writing app theme preferences without exposing storage details.
abstract interface class ThemePreferenceRepository {
  /// Loads the persisted app theme preference.
  Future<AppThemePreference> loadAppThemePreference();

  /// Persists the selected app theme preference.
  Future<void> saveAppThemePreference(AppThemePreference preference);
}

/// Persistence-backed adapter for workout logs.
final class PersistenceWorkoutLogRepository implements WorkoutLogRepository {
  /// Creates a workout-log repository that delegates to app persistence.
  const PersistenceWorkoutLogRepository(this._persistence);

  final GtgPersistence _persistence;

  @override
  /// Delegates workout-log reads to the shared persistence implementation.
  Future<List<ExerciseLog>> loadLogs() {
    return _persistence.loadLogs();
  }

  @override
  /// Delegates workout-log writes to the shared persistence implementation.
  Future<void> saveLogs(List<ExerciseLog> logs) {
    return _persistence.saveLogs(logs);
  }
}

/// Persistence-backed adapter for reminder settings.
final class PersistenceReminderSettingsRepository
    implements ReminderSettingsRepository {
  /// Creates a reminder-settings repository that delegates to app persistence.
  const PersistenceReminderSettingsRepository(this._persistence);

  final GtgPersistence _persistence;

  @override
  /// Delegates reminder-settings reads to the shared persistence implementation.
  Future<ReminderSettings> loadReminderSettings() {
    return _persistence.loadReminderSettings();
  }

  @override
  /// Delegates reminder-settings writes to the shared persistence implementation.
  Future<void> saveReminderSettings(ReminderSettings settings) {
    return _persistence.saveReminderSettings(settings);
  }
}

/// Persistence-backed adapter for user preferences.
final class PersistenceUserPreferencesRepository
    implements UserPreferencesRepository {
  /// Creates a user-preferences repository that delegates to app persistence.
  const PersistenceUserPreferencesRepository(this._persistence);

  final GtgPersistence _persistence;

  @override
  /// Delegates user-preferences reads to the shared persistence implementation.
  Future<UserPreferences> loadUserPreferences() {
    return _persistence.loadUserPreferences();
  }

  @override
  /// Delegates user-preferences writes to the shared persistence implementation.
  Future<void> saveUserPreferences(UserPreferences preferences) {
    return _persistence.saveUserPreferences(preferences);
  }
}

/// Persistence-backed adapter for theme preferences.
final class PersistenceThemePreferenceRepository
    implements ThemePreferenceRepository {
  /// Creates a theme-preference repository that delegates to app persistence.
  const PersistenceThemePreferenceRepository(this._persistence);

  final GtgPersistence _persistence;

  @override
  /// Delegates theme-preference reads to the shared persistence implementation.
  Future<AppThemePreference> loadAppThemePreference() {
    return _persistence.loadAppThemePreference();
  }

  @override
  /// Delegates theme-preference writes to the shared persistence implementation.
  Future<void> saveAppThemePreference(AppThemePreference preference) {
    return _persistence.saveAppThemePreference(preference);
  }
}

/// Provides workout-log repository abstraction to feature controllers.
final workoutLogRepositoryProvider = Provider<WorkoutLogRepository>((ref) {
  return PersistenceWorkoutLogRepository(ref.read(persistenceProvider));
});

/// Provides reminder-settings repository abstraction to feature controllers.
final reminderSettingsRepositoryProvider = Provider<ReminderSettingsRepository>(
  (ref) {
    return PersistenceReminderSettingsRepository(ref.read(persistenceProvider));
  },
);

/// Provides user-preferences repository abstraction to feature controllers.
final userPreferencesRepositoryProvider = Provider<UserPreferencesRepository>((
  ref,
) {
  return PersistenceUserPreferencesRepository(ref.read(persistenceProvider));
});

/// Provides theme-preference repository abstraction to feature controllers.
final themePreferenceRepositoryProvider = Provider<ThemePreferenceRepository>((
  ref,
) {
  return PersistenceThemePreferenceRepository(ref.read(persistenceProvider));
});
