import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_link_policy.dart';
import '../../../core/external_link_launcher.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/logging/logger_provider.dart';
import '../../../core/models/app_theme_preference.dart';
import '../../../core/app_links.dart';
import 'theme_preference_controller.dart';

/// Enumerates the possible outcomes of trying to open the privacy policy link.
enum PrivacyPolicyLaunchResult { opened, invalidUrl, launchFailed }

/// Handles settings-side effects so the screen can stay focused on rendering and feedback.
class SettingsActionService {
  /// Creates a settings action service with injected launcher, logger, and theme writer.
  const SettingsActionService({
    required ExternalLinkLauncher linkLauncher,
    required AppLogger logger,
    required Future<void> Function(AppThemePreference preference)
    setThemePreference,
  }) : _linkLauncher = linkLauncher,
       _logger = logger,
       _setThemePreference = setThemePreference;

  static const String invalidPrivacyUrlLog =
      'Settings privacy policy URL failed validation.';
  static const String failedPrivacyLaunchLog =
      'Settings privacy policy could not be launched.';
  static const String failedThemePreferenceLog =
      'Failed to update theme preference from settings.';

  final ExternalLinkLauncher _linkLauncher;
  final AppLogger _logger;
  final Future<void> Function(AppThemePreference preference)
  _setThemePreference;

  /// Opens the privacy policy URL after validation and returns a user-facing outcome.
  Future<PrivacyPolicyLaunchResult> openPrivacyPolicy() async {
    final uri = AppLinkPolicy.parseExternalHttpsUri(AppLinks.privacyPolicyUrl);
    if (uri == null) {
      _logger.warning(invalidPrivacyUrlLog);
      return PrivacyPolicyLaunchResult.invalidUrl;
    }

    final ok = await _linkLauncher.launch(uri);
    if (!ok) {
      _logger.warning(failedPrivacyLaunchLog);
      return PrivacyPolicyLaunchResult.launchFailed;
    }

    return PrivacyPolicyLaunchResult.opened;
  }

  /// Persists a theme preference change while logging failures through one policy entrypoint.
  Future<void> setThemePreference(AppThemePreference preference) async {
    try {
      await _setThemePreference(preference);
    } catch (error, stackTrace) {
      _logger.error(
        failedThemePreferenceLog,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}

/// Provides the settings action orchestration service for the settings screen.
final settingsActionServiceProvider = Provider<SettingsActionService>((ref) {
  return SettingsActionService(
    linkLauncher: ref.read(externalLinkLauncherProvider),
    logger: ref.read(appLoggerProvider),
    setThemePreference: (preference) {
      return ref
          .read(themePreferenceControllerProvider.notifier)
          .setPreference(preference);
    },
  );
});
