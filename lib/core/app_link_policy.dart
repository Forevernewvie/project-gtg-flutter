/// Centralizes validation rules for externally launched app links.
abstract final class AppLinkPolicy {
  static const String _httpsScheme = 'https';

  /// Returns a sanitized absolute HTTPS URI or null when the input is unsafe.
  static Uri? parseExternalHttpsUri(String rawUrl) {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) return null;
    if (uri.scheme.toLowerCase() != _httpsScheme || uri.host.isEmpty) {
      return null;
    }
    return uri;
  }
}
