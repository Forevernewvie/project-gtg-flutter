import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Contract for launching validated external links without exposing plugin details.
abstract interface class ExternalLinkLauncher {
  /// Launches the given URI outside the app and returns whether it succeeded.
  Future<bool> launch(Uri uri);
}

/// Default launcher implementation backed by `url_launcher`.
final class UrlLauncherExternalLinkLauncher implements ExternalLinkLauncher {
  /// Creates the default external-link launcher implementation.
  const UrlLauncherExternalLinkLauncher();

  @override
  /// Launches the URI in an external application to reduce in-app attack surface.
  Future<bool> launch(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Provides the external-link launcher abstraction for dependency injection.
final externalLinkLauncherProvider = Provider<ExternalLinkLauncher>((ref) {
  return const UrlLauncherExternalLinkLauncher();
});
