import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/logging/logger_provider.dart';
import '../../../core/models/app_theme_preference.dart';
import '../../../data/persistence/persistence_provider.dart';

final themePreferenceControllerProvider =
    AsyncNotifierProvider<ThemePreferenceController, AppThemePreference>(
      ThemePreferenceController.new,
    );

class ThemePreferenceController extends AsyncNotifier<AppThemePreference> {
  /// Loads the persisted theme preference for app bootstrap.
  @override
  Future<AppThemePreference> build() async {
    return ref.read(persistenceProvider).loadAppThemePreference();
  }

  /// Persists a new theme preference while keeping failures observable in logs.
  Future<void> setPreference(AppThemePreference preference) async {
    state = AsyncData(preference);
    try {
      await ref.read(persistenceProvider).saveAppThemePreference(preference);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to persist theme preference.',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Exposes the injected logger without coupling the controller to one implementation.
  AppLogger get _logger => ref.read(appLoggerProvider);
}
