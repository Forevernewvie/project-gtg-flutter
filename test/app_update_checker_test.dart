import 'package:flutter_test/flutter_test.dart';

import 'package:project_gtg/core/logging/app_logger.dart';
import 'package:project_gtg/core/platform/app_build_info.dart';
import 'package:project_gtg/features/update/services/app_update_checker.dart';

class _FakeLogger implements AppLogger {
  final List<String> infos = <String>[];
  final List<String> warnings = <String>[];
  final List<String> errors = <String>[];

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    errors.add(message);
  }

  @override
  void info(String message) {
    infos.add(message);
  }

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    warnings.add(message);
  }
}

class _FakeBuildInfoReader implements AppBuildInfoReader {
  const _FakeBuildInfoReader(this.info);

  final AppBuildInfo info;

  @override
  Future<AppBuildInfo> read() async => info;
}

void main() {
  test('returns update info when hosted version is newer', () async {
    final checker = AppUpdateChecker(
      buildInfoReader: const _FakeBuildInfoReader(
        AppBuildInfo(
          versionName: '1.0.0',
          versionCode: 3,
          packageName: 'com.forevernewvie.projectgtg',
        ),
      ),
      logger: _FakeLogger(),
      loadJson: (_) async => <String, Object?>{
        'android': <String, Object?>{
          'latestVersionCode': 4,
          'latestVersionName': '1.0.1',
          'forceUpdate': false,
          'message': 'New update',
          'storeUrl':
              'https://play.google.com/store/apps/details?id=com.forevernewvie.projectgtg',
        },
      },
      skipInDebug: false,
    );

    final update = await checker.checkForUpdate();

    expect(update, isNotNull);
    expect(update!.latestVersionCode, 4);
    expect(update.latestVersionName, '1.0.1');
    expect(update.forceUpdate, isFalse);
  });

  test('returns null when hosted version is not newer', () async {
    final checker = AppUpdateChecker(
      buildInfoReader: const _FakeBuildInfoReader(
        AppBuildInfo(
          versionName: '1.0.0',
          versionCode: 4,
          packageName: 'com.forevernewvie.projectgtg',
        ),
      ),
      logger: _FakeLogger(),
      loadJson: (_) async => <String, Object?>{
        'android': <String, Object?>{
          'latestVersionCode': 4,
          'latestVersionName': '1.0.0',
          'forceUpdate': false,
          'message': 'Same version',
          'storeUrl':
              'https://play.google.com/store/apps/details?id=com.forevernewvie.projectgtg',
        },
      },
      skipInDebug: false,
    );

    expect(await checker.checkForUpdate(), isNull);
  });

  test('returns null and logs warning for invalid store URL', () async {
    final logger = _FakeLogger();
    final checker = AppUpdateChecker(
      buildInfoReader: const _FakeBuildInfoReader(
        AppBuildInfo(
          versionName: '1.0.0',
          versionCode: 1,
          packageName: 'com.forevernewvie.projectgtg',
        ),
      ),
      logger: logger,
      loadJson: (_) async => <String, Object?>{
        'android': <String, Object?>{
          'latestVersionCode': 4,
          'latestVersionName': '1.0.1',
          'forceUpdate': true,
          'message': 'Must update',
          'storeUrl': 'not-a-valid-url',
        },
      },
      skipInDebug: false,
    );

    expect(await checker.checkForUpdate(), isNull);
    expect(logger.warnings, contains(AppUpdateChecker.invalidStoreUrlLog));
  });

  test('skips hosted update checks in debug mode by default', () async {
    final logger = _FakeLogger();
    final checker = AppUpdateChecker(
      buildInfoReader: const _FakeBuildInfoReader(
        AppBuildInfo(
          versionName: '1.0.0',
          versionCode: 1,
          packageName: 'com.forevernewvie.projectgtg',
        ),
      ),
      logger: logger,
      loadJson: (_) async => throw StateError('should not fetch in debug'),
    );

    expect(await checker.checkForUpdate(), isNull);
    expect(logger.infos, contains(AppUpdateChecker.skippedDebugLog));
  });
}
