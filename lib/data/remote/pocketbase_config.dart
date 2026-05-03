import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Runtime configuration for optional PocketBase-backed cloud features.
final class PocketBaseConfig {
  const PocketBaseConfig({
    required this.baseUrl,
    required this.email,
    required this.password,
    this.deviceId = 'default-device',
  });

  /// PocketBase root URL, for example `https://pb.example.com`.
  final String baseUrl;

  /// Email for the current auth user in MVP builds.
  final String email;

  /// Password for the current auth user in MVP builds.
  final String password;

  /// Stable client device id used for conflict/audit metadata.
  final String deviceId;

  bool get isConfigured =>
      baseUrl.trim().isNotEmpty &&
      email.trim().isNotEmpty &&
      password.trim().isNotEmpty;

  Uri buildUri(String path, [Map<String, String>? queryParameters]) {
    final root = Uri.parse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/');
    final relativePath = path.startsWith('/') ? path.substring(1) : path;
    return root.resolve(relativePath).replace(queryParameters: queryParameters);
  }
}

/// Reads PocketBase settings from compile-time dart-defines.
final pocketBaseConfigProvider = Provider<PocketBaseConfig>((ref) {
  return const PocketBaseConfig(
    baseUrl: String.fromEnvironment('GTG_POCKETBASE_URL'),
    email: String.fromEnvironment('GTG_POCKETBASE_EMAIL'),
    password: String.fromEnvironment('GTG_POCKETBASE_PASSWORD'),
    deviceId: String.fromEnvironment(
      'GTG_POCKETBASE_DEVICE_ID',
      defaultValue: 'default-device',
    ),
  );
});
