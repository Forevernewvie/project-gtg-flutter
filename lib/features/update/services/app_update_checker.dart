import 'dart:convert';
import 'dart:io' show HttpClient, HttpException, Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/logging/logger_provider.dart';
import '../../../core/platform/app_build_info.dart';
import '../models/app_update_info.dart';

typedef JsonLoader = Future<Object?> Function(Uri uri);

/// Compares the current app build to the hosted manifest and decides whether to prompt.
class AppUpdateChecker {
  const AppUpdateChecker({
    required AppBuildInfoReader buildInfoReader,
    required AppLogger logger,
    JsonLoader? loadJson,
  }) : _buildInfoReader = buildInfoReader,
       _logger = logger,
       _loadJson = loadJson ?? _defaultLoadJson;

  static const String skippedWebLog =
      'Skipping update check: web does not support build metadata.';
  static const String skippedDebugLog = 'Skipping update check in debug mode.';
  static const String invalidManifestUrlLog =
      'Skipping update check: hosted manifest URL failed validation.';
  static const String invalidStoreUrlLog =
      'Skipping update check: store URL failed validation.';
  static const String failedFetchLog = 'Hosted update manifest fetch failed.';

  final AppBuildInfoReader _buildInfoReader;
  final AppLogger _logger;
  final JsonLoader _loadJson;

  Future<AppUpdateInfo?> checkForUpdate() async {
    if (kIsWeb) {
      _logger.info(skippedWebLog);
      return null;
    }

    try {
      final buildInfo = await _buildInfoReader.read();

      // Node.js 로컬 서버 호출
      final platform = Platform.isIOS ? 'ios' : 'android';
      final baseUrl =
          'https://distinguished-revolutionary-pull-continuously.trycloudflare.com/api/v1/check-update';
      final uri = Uri.parse(
        '$baseUrl?platform=$platform&versionCode=${buildInfo.versionCode}',
      );

      final rawManifest = await _loadJson(uri);
      final updateInfo = AppUpdateInfo.fromJson(rawManifest);

      if (updateInfo == null) return null;

      return updateInfo;
    } catch (error, stackTrace) {
      _logger.warning(failedFetchLog, error: error, stackTrace: stackTrace);
      return null;
    }
  }

  static Future<Object?> _defaultLoadJson(Uri uri) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 3); // 3초 타임아웃

    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Unexpected status code ${response.statusCode}',
          uri: uri,
        );
      }

      final body = await response.transform(utf8.decoder).join();
      return jsonDecode(body);
    } finally {
      client.close(force: true);
    }
  }
}

final appUpdateCheckerProvider = Provider<AppUpdateChecker>((ref) {
  return AppUpdateChecker(
    buildInfoReader: ref.read(appBuildInfoReaderProvider),
    logger: ref.read(appLoggerProvider),
  );
});
