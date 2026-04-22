import 'dart:convert';
import 'dart:io' show HttpClient, HttpException, Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_link_policy.dart';
import '../../../core/app_links.dart';
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
    bool skipInDebug = kDebugMode,
  }) : _buildInfoReader = buildInfoReader,
       _logger = logger,
       _loadJson = loadJson ?? _defaultLoadJson,
       _skipInDebug = skipInDebug;

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
  final bool _skipInDebug;

  Future<AppUpdateInfo?> checkForUpdate() async {
    if (kIsWeb) {
      _logger.info(skippedWebLog);
      return null;
    }
    if (_skipInDebug) {
      _logger.info(skippedDebugLog);
      return null;
    }

    final manifestUri = AppLinkPolicy.parseExternalHttpsUri(
      AppLinks.versionManifestUrl,
    );
    if (manifestUri == null) {
      _logger.warning(invalidManifestUrlLog);
      return null;
    }

    try {
      final buildInfo = await _buildInfoReader.read();
      final rawManifest = await _loadJson(manifestUri);
      final manifest = HostedUpdateManifest.fromJson(rawManifest);
      if (manifest == null) return null;

      final entry = Platform.isIOS ? manifest.ios : manifest.android;
      if (entry == null || entry.latestVersionCode <= buildInfo.versionCode) {
        return null;
      }

      final storeUri = AppLinkPolicy.parseExternalHttpsUri(entry.storeUrl);
      if (storeUri == null) {
        _logger.warning(invalidStoreUrlLog);
        return null;
      }

      return AppUpdateInfo(
        latestVersionCode: entry.latestVersionCode,
        latestVersionName: entry.latestVersionName,
        forceUpdate: entry.forceUpdate,
        message: entry.message,
        storeUrl: storeUri.toString(),
      );
    } catch (error, stackTrace) {
      _logger.warning(failedFetchLog, error: error, stackTrace: stackTrace);
      return null;
    }
  }

  static Future<Object?> _defaultLoadJson(Uri uri) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 5);

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
