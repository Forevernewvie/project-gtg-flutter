abstract final class Env {
  static const bool uiTesting = bool.fromEnvironment('UI_TESTING');
  static const bool smokeScreenshots = bool.fromEnvironment(
    'SMOKE_SCREENSHOTS',
  );
}
