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
  test('returns update info correctly parsed', () async {
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
        'updateRequired': true,
        'updateType': 'FORCE',
        'latestVersion': {'code': 4, 'name': '1.0.1'},
        'title': 'New Update',
        'message': 'Please update',
        'storeUrl':
            'https://play.google.com/store/apps/details?id=com.forevernewvie.projectgtg',
        'maintenance': {'isActive': false, 'message': ''},
      },
    );

    final update = await checker.checkForUpdate();

    expect(update, isNotNull);
    expect(update!.latestVersionCode, 4);
    expect(update.latestVersionName, '1.0.1');
    expect(update.updateType, 'FORCE');
    expect(update.updateRequired, isTrue);
  });
}
