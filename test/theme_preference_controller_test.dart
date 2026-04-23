import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:project_gtg/core/models/app_theme_preference.dart';
import 'package:project_gtg/data/persistence/persistence_repositories.dart';
import 'package:project_gtg/features/settings/state/theme_preference_controller.dart';

class _ThrowingThemePreferenceRepository implements ThemePreferenceRepository {
  @override
  Future<AppThemePreference> loadAppThemePreference() async {
    throw StateError('theme-load-failed');
  }

  @override
  Future<void> saveAppThemePreference(AppThemePreference preference) async {}
}

void main() {
  test('build falls back to system theme when loading fails', () async {
    final container = ProviderContainer(
      overrides: [
        themePreferenceRepositoryProvider.overrideWithValue(
          _ThrowingThemePreferenceRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final value = await container.read(
      themePreferenceControllerProvider.future,
    );

    expect(value, AppThemePreference.system);
  });
}
