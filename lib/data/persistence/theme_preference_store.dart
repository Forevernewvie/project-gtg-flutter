import '../../core/models/app_theme_preference.dart';
import 'json_file_store.dart';
import 'persistence_constants.dart';

/// Stores app theme preference independently from the main feature-data backend.
final class ThemePreferenceStore {
  /// Creates a theme-preference store backed by the provided JSON file store.
  const ThemePreferenceStore({required JsonFileStore fileStore})
    : _fileStore = fileStore;

  final JsonFileStore _fileStore;

  /// Loads the persisted app theme preference or falls back to the system mode.
  Future<AppThemePreference> loadAppThemePreference() async {
    final raw = await _fileStore.readJson(
      PersistenceConstants.themePreferenceFileName,
    );

    if (raw is String) {
      return AppThemePreference.fromRaw(raw);
    }

    final map = _tryMap(raw);
    return AppThemePreference.fromRaw(map?['themeMode']);
  }

  /// Persists the selected app theme preference independently from feature data.
  Future<void> saveAppThemePreference(AppThemePreference preference) async {
    await _fileStore.writeJson(
      PersistenceConstants.themePreferenceFileName,
      <String, Object?>{'themeMode': preference.key},
    );
  }

  /// Normalizes dynamic decoded JSON into a string-keyed map when possible.
  Map<String, dynamic>? _tryMap(Object? raw) {
    if (raw is! Map) return null;
    return raw.map((key, value) => MapEntry('$key', value));
  }
}
