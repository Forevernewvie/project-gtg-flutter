import '../../core/env.dart';
import '../../core/logging/app_logger.dart';
import '../../core/models/app_theme_preference.dart';
import '../../core/models/exercise_log.dart';
import '../../core/models/reminder_settings.dart';
import '../../core/models/user_preferences.dart';
import '../isar/isar_database.dart';
import '../isar/isar_persistence.dart';
import 'directory_provider.dart';
import 'json_file_store.dart';
import 'persistence_backend.dart';
import 'persistence_bootstrapper.dart';
import 'theme_preference_store.dart';

/// High-level facade for app persistence entities.
///
/// Responsibilities:
/// - expose stable persistence APIs to the rest of the app
/// - delegate feature data to the selected backend
/// - keep theme preference storage independent from backend migration mode
class GtgPersistence {
  GtgPersistence({
    DirectoryProvider? directoryProvider,
    JsonFileStore? fileStore,
    IsarDatabase? isarDatabase,
    IsarPersistence? isarPersistence,
    PersistenceBootstrapper? bootstrapper,
    ThemePreferenceStore? themePreferenceStore,
    AppLogger? logger,
    bool? enableIsarMigration,
  }) {
    final resolvedLogger = logger ?? const DebugAppLogger();
    final resolvedEnableIsarMigration =
        enableIsarMigration ?? !Env.isTestRuntime;
    final resolvedDirectoryProvider =
        directoryProvider ?? DefaultDirectoryProvider();

    _fileStore =
        fileStore ??
        JsonFileStore(
          directoryProvider: resolvedDirectoryProvider,
          logger: resolvedLogger,
        );

    _isarPersistence =
        isarPersistence ??
        IsarPersistence(
          database:
              isarDatabase ??
              IsarDatabase(directoryProvider: resolvedDirectoryProvider),
        );

    final jsonBackend = JsonPersistenceBackend(fileStore: _fileStore);
    final isarBackend = IsarPersistenceBackend(
      isarPersistence: _isarPersistence,
    );

    _bootstrapper =
        bootstrapper ??
        PersistenceBootstrapper(
          logger: resolvedLogger,
          enableIsarMigration: resolvedEnableIsarMigration,
          jsonBackend: jsonBackend,
          isarPersistence: _isarPersistence,
          isarBackend: isarBackend,
        );

    _themePreferenceStore =
        themePreferenceStore ?? ThemePreferenceStore(fileStore: _fileStore);
  }

  late final JsonFileStore _fileStore;
  late final IsarPersistence _isarPersistence;
  late final PersistenceBootstrapper _bootstrapper;
  late final ThemePreferenceStore _themePreferenceStore;

  PersistenceBackend? _backend;
  Future<PersistenceBackend>? _backendFuture;

  /// Loads all exercise logs from the selected backend.
  Future<List<ExerciseLog>> loadLogs() async {
    return (await _resolveBackend()).loadLogs();
  }

  /// Persists all exercise logs to the selected backend.
  Future<void> saveLogs(List<ExerciseLog> logs) async {
    await (await _resolveBackend()).saveLogs(logs);
  }

  /// Loads reminder settings with defaults as a safe fallback.
  Future<ReminderSettings> loadReminderSettings() async {
    return (await _resolveBackend()).loadReminderSettings();
  }

  /// Persists reminder settings atomically.
  Future<void> saveReminderSettings(ReminderSettings settings) async {
    await (await _resolveBackend()).saveReminderSettings(settings);
  }

  /// Loads user preferences with defaults as a safe fallback.
  Future<UserPreferences> loadUserPreferences() async {
    return (await _resolveBackend()).loadUserPreferences();
  }

  /// Persists user preferences atomically.
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    await (await _resolveBackend()).saveUserPreferences(preferences);
  }

  /// Loads app theme preference independently from feature data storage mode.
  Future<AppThemePreference> loadAppThemePreference() {
    return _themePreferenceStore.loadAppThemePreference();
  }

  /// Persists app theme preference independently from feature data storage mode.
  Future<void> saveAppThemePreference(AppThemePreference preference) {
    return _themePreferenceStore.saveAppThemePreference(preference);
  }

  /// Releases backend resources when callers need deterministic cleanup.
  Future<void> close({bool deleteFromDisk = false}) async {
    final backend = _backend;
    if (backend == null) return;
    await backend.close(deleteFromDisk: deleteFromDisk);
  }

  /// Resolves and memoizes the active feature-data backend for this process.
  Future<PersistenceBackend> _resolveBackend() async {
    final current = _backend;
    if (current != null) return current;

    final future = _backendFuture ??= _bootstrapper.initialize();
    final resolved = await future;
    _backend = resolved;
    return resolved;
  }
}
