abstract final class AppLinks {
  static const String privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue:
        'https://raw.githubusercontent.com/Forevernewvie/project-gtg-flutter/main/docs/privacy_policy.md',
  );
}
