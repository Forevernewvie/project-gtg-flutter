import 'package:flutter_test/flutter_test.dart';

import 'package:project_gtg/core/external_link_launcher.dart';
import 'package:project_gtg/core/logging/app_logger.dart';
import 'package:project_gtg/core/models/app_theme_preference.dart';
import 'package:project_gtg/features/settings/state/settings_action_service.dart';

class _SpyExternalLinkLauncher implements ExternalLinkLauncher {
  _SpyExternalLinkLauncher({required this.result});

  final bool result;
  int calls = 0;
  Uri? lastUri;

  @override
  /// Returns the configured launch result while capturing the launched URI.
  Future<bool> launch(Uri uri) async {
    calls++;
    lastUri = uri;
    return result;
  }
}

class _SpyLogger implements AppLogger {
  final List<String> infos = <String>[];
  final List<String> warnings = <String>[];
  final List<String> errors = <String>[];

  @override
  /// Records informational logs for assertions.
  void info(String message) {
    infos.add(message);
  }

  @override
  /// Records warning logs for assertions.
  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    warnings.add(message);
  }

  @override
  /// Records error logs for assertions.
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    errors.add(message);
  }
}

void main() {
  test('openPrivacyPolicy returns opened when the launcher succeeds', () async {
    final launcher = _SpyExternalLinkLauncher(result: true);
    final logger = _SpyLogger();
    final service = SettingsActionService(
      linkLauncher: launcher,
      logger: logger,
      setThemePreference: (_) async {},
    );

    final result = await service.openPrivacyPolicy();

    expect(result, PrivacyPolicyLaunchResult.opened);
    expect(launcher.calls, 1);
    expect(launcher.lastUri, isNotNull);
    expect(logger.warnings, isEmpty);
  });

  test(
    'openPrivacyPolicy returns launchFailed and logs a warning on failure',
    () async {
      final launcher = _SpyExternalLinkLauncher(result: false);
      final logger = _SpyLogger();
      final service = SettingsActionService(
        linkLauncher: launcher,
        logger: logger,
        setThemePreference: (_) async {},
      );

      final result = await service.openPrivacyPolicy();

      expect(result, PrivacyPolicyLaunchResult.launchFailed);
      expect(launcher.calls, 1);
      expect(
        logger.warnings,
        contains(SettingsActionService.failedPrivacyLaunchLog),
      );
    },
  );

  test('setThemePreference logs errors and does not rethrow', () async {
    final launcher = _SpyExternalLinkLauncher(result: true);
    final logger = _SpyLogger();
    final service = SettingsActionService(
      linkLauncher: launcher,
      logger: logger,
      setThemePreference: (_) async {
        throw StateError('boom');
      },
    );

    await service.setThemePreference(AppThemePreference.dark);

    expect(
      logger.errors,
      contains(SettingsActionService.failedThemePreferenceLog),
    );
  });
}
