abstract final class AppLinks {
  static const String privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue:
        'https://forevernewvie.github.io/project-gtg-flutter/privacy_policy.html',
  );
}
