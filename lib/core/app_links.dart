abstract final class AppLinks {
  static const String privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue:
        'https://forevernewvie.github.io/project-gtg-flutter/privacy_policy.html',
  );

  static const String versionManifestUrl = String.fromEnvironment(
    'VERSION_MANIFEST_URL',
    defaultValue:
        'https://forevernewvie.github.io/project-gtg-flutter/version.json',
  );

  static const String playStoreUrl = String.fromEnvironment(
    'PLAY_STORE_URL_ANDROID',
    defaultValue:
        'https://play.google.com/store/apps/details?id=com.forevernewvie.projectgtg',
  );
}
