/// Centralized constants for local persistence paths and file names.
abstract final class PersistenceConstants {
  static const String appDirectoryName = 'ProjectGTG';

  static const String logsFileName = 'exercise_logs.json';
  static const String reminderSettingsFileName = 'reminder_settings.json';
  static const String userPreferencesFileName = 'user_preferences.json';

  static const String temporarySuffix = '.tmp';
  static const String corruptedSuffix = '.corrupted-';
}
