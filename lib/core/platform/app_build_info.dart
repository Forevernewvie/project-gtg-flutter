import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Immutable app version/build metadata returned by the host platform.
final class AppBuildInfo {
  const AppBuildInfo({
    required this.versionName,
    required this.versionCode,
    required this.packageName,
  });

  final String versionName;
  final int versionCode;
  final String packageName;
}

/// Contract for reading native app build metadata.
abstract interface class AppBuildInfoReader {
  Future<AppBuildInfo> read();
}

/// Default build-info reader backed by a lightweight MethodChannel.
final class MethodChannelAppBuildInfoReader implements AppBuildInfoReader {
  const MethodChannelAppBuildInfoReader();

  static const MethodChannel _channel = MethodChannel(
    'project_gtg/app_build_info',
  );

  @override
  Future<AppBuildInfo> read() async {
    if (kIsWeb) {
      throw UnsupportedError('Build info is unavailable on web.');
    }

    final result = await _channel.invokeMapMethod<String, Object?>(
      'getBuildInfo',
    );
    if (result == null) {
      throw PlatformException(
        code: 'null_build_info',
        message: 'Platform returned no build info.',
      );
    }

    return AppBuildInfo(
      versionName: '${result['versionName'] ?? ''}',
      versionCode: _parseInt(result['versionCode']),
      packageName: '${result['packageName'] ?? _defaultPackageName}',
    );
  }

  static int _parseInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static String get _defaultPackageName {
    if (Platform.isAndroid) return 'com.forevernewvie.projectgtg';
    return 'project_gtg';
  }
}

final appBuildInfoReaderProvider = Provider<AppBuildInfoReader>((ref) {
  return const MethodChannelAppBuildInfoReader();
});
