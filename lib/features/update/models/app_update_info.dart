/// One platform entry from the hosted update manifest.
final class HostedPlatformUpdate {
  const HostedPlatformUpdate({
    required this.latestVersionCode,
    required this.latestVersionName,
    required this.forceUpdate,
    required this.message,
    required this.storeUrl,
  });

  final int latestVersionCode;
  final String latestVersionName;
  final bool forceUpdate;
  final String message;
  final String storeUrl;

  static HostedPlatformUpdate? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final map = raw.map((key, value) => MapEntry('$key', value));

    return HostedPlatformUpdate(
      latestVersionCode: _readInt(map['latestVersionCode']),
      latestVersionName: '${map['latestVersionName'] ?? ''}',
      forceUpdate: _readBool(map['forceUpdate']),
      message: '${map['message'] ?? ''}',
      storeUrl: '${map['storeUrl'] ?? ''}',
    );
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static bool _readBool(Object? value) {
    if (value is bool) return value;
    return '$value'.toLowerCase() == 'true';
  }
}

/// Parsed root manifest read from hosted JSON.
final class HostedUpdateManifest {
  const HostedUpdateManifest({this.android, this.ios});

  final HostedPlatformUpdate? android;
  final HostedPlatformUpdate? ios;

  static HostedUpdateManifest? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final map = raw.map((key, value) => MapEntry('$key', value));

    return HostedUpdateManifest(
      android: HostedPlatformUpdate.fromJson(map['android']),
      ios: HostedPlatformUpdate.fromJson(map['ios']),
    );
  }
}

/// Resolved update prompt shown to the user when a newer version exists.
final class AppUpdateInfo {
  const AppUpdateInfo({
    required this.latestVersionCode,
    required this.latestVersionName,
    required this.forceUpdate,
    required this.message,
    required this.storeUrl,
  });

  final int latestVersionCode;
  final String latestVersionName;
  final bool forceUpdate;
  final String message;
  final String storeUrl;
}
