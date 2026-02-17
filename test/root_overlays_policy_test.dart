import 'package:flutter_test/flutter_test.dart';

import 'package:project_gtg/app/root_overlays.dart';

void main() {
  test('splash is disabled in test runtime regardless of flags', () {
    expect(
      shouldShowInAppSplash(
        isTestRuntime: true,
        uiTesting: false,
        smokeScreenshots: false,
      ),
      isFalse,
    );
    expect(
      shouldShowInAppSplash(
        isTestRuntime: true,
        uiTesting: true,
        smokeScreenshots: true,
      ),
      isFalse,
    );
  });

  test('uiTesting hides splash unless smoke screenshots is enabled', () {
    expect(
      shouldShowInAppSplash(
        isTestRuntime: false,
        uiTesting: true,
        smokeScreenshots: false,
      ),
      isFalse,
    );
    expect(
      shouldShowInAppSplash(
        isTestRuntime: false,
        uiTesting: true,
        smokeScreenshots: true,
      ),
      isTrue,
    );
  });

  test('non-test runtime shows splash by default', () {
    expect(
      shouldShowInAppSplash(
        isTestRuntime: false,
        uiTesting: false,
        smokeScreenshots: false,
      ),
      isTrue,
    );
  });
}
