/// Centralized constants for local persistence paths and file names.
abstract final class PersistenceConstants {
  static const String appDirectoryName = 'ProjectGTG';
  static const String isarDatabaseName = 'project_gtg';

  static const String logsFileName = 'exercise_logs.json';
  static const String reminderSettingsFileName = 'reminder_settings.json';
  static const String userPreferencesFileName = 'user_preferences.json';
  static const String themePreferenceFileName = 'theme_preference.json';

  static const int singletonEntityId = 1;
  static const int currentStorageVersion = 1;

  static const String temporarySuffix = '.tmp';
  static const String corruptedSuffix = '.corrupted-';
}
