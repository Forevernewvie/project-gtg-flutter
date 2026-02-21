import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/app_theme_preference.dart';
import '../../../data/persistence/persistence_provider.dart';

final themePreferenceControllerProvider =
    AsyncNotifierProvider<ThemePreferenceController, AppThemePreference>(
      ThemePreferenceController.new,
    );

class ThemePreferenceController extends AsyncNotifier<AppThemePreference> {
  @override
  Future<AppThemePreference> build() async {
    return ref.read(persistenceProvider).loadAppThemePreference();
  }

  Future<void> setPreference(AppThemePreference preference) async {
    state = AsyncData(preference);
    await ref.read(persistenceProvider).saveAppThemePreference(preference);
  }
}
