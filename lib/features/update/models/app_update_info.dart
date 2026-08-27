final class AppUpdateInfo {
  const AppUpdateInfo({
    required this.updateRequired,
    required this.updateType,
    required this.latestVersionCode,
    required this.latestVersionName,
    required this.title,
    required this.message,
    required this.storeUrl,
    required this.maintenanceActive,
    required this.maintenanceMessage,
  });

  final bool updateRequired;
  final String updateType; // 'FORCE', 'OPTIONAL', 'NONE'
  final int latestVersionCode;
  final String latestVersionName;
  final String title;
  final String message;
  final String storeUrl;
  final bool maintenanceActive;
  final String maintenanceMessage;

  static AppUpdateInfo? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final map = raw.map((key, value) => MapEntry('$key', value));

    return AppUpdateInfo(
      updateRequired: _readBool(map['updateRequired']),
      updateType: '${map['updateType'] ?? 'NONE'}',
      latestVersionCode: _readInt((map['latestVersion'] as Map?)?['code']),
      latestVersionName: '${(map['latestVersion'] as Map?)?['name'] ?? ''}',
      title: '${map['title'] ?? ''}',
      message: '${map['message'] ?? ''}',
      storeUrl: '${map['storeUrl'] ?? ''}',
      maintenanceActive: _readBool((map['maintenance'] as Map?)?['isActive']),
      maintenanceMessage: '${(map['maintenance'] as Map?)?['message'] ?? ''}',
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
