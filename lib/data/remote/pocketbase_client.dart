import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/models/exercise_log.dart';
import '../../core/models/user_preferences.dart';
import 'pocketbase_config.dart';
import 'pocketbase_models.dart';

abstract interface class RemoteSyncClient {
  bool get isConfigured;
  Future<List<ExerciseLog>> fetchWorkoutLogs();
  Future<void> upsertWorkoutLogs(List<ExerciseLog> logs);
  Future<UserPreferences?> fetchUserPreferences();
  Future<void> upsertUserPreferences(UserPreferences preferences);
  Future<GtgCoachRecommendation?> fetchLatestCoachRecommendation();
}

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final remoteSyncClientProvider = Provider<RemoteSyncClient>((ref) {
  return PocketBaseRemoteSyncClient(
    config: ref.watch(pocketBaseConfigProvider),
    httpClient: ref.watch(httpClientProvider),
  );
});

final class PocketBaseRemoteSyncClient implements RemoteSyncClient {
  PocketBaseRemoteSyncClient({
    required PocketBaseConfig config,
    required http.Client httpClient,
  }) : _config = config,
       _httpClient = httpClient;

  final PocketBaseConfig _config;
  final http.Client _httpClient;

  String? _token;
  String? _userId;

  @override
  bool get isConfigured => _config.isConfigured;

  @override
  Future<List<ExerciseLog>> fetchWorkoutLogs() async {
    if (!isConfigured) return const <ExerciseLog>[];
    await _ensureAuth();
    final response = await _get(
      '/api/collections/gtg_workout_logs/records',
      <String, String>{
        'perPage': '500',
        'sort': 'loggedAt',
        'filter': _authenticatedUserFilter,
      },
    );
    final items = _items(response);
    return items
        .map(RemoteExerciseLog.fromPocketBase)
        .map((r) => r.log)
        .toList(growable: false);
  }

  @override
  Future<void> upsertWorkoutLogs(List<ExerciseLog> logs) async {
    if (!isConfigured || logs.isEmpty) return;
    await _ensureAuth();
    for (final log in logs) {
      final existingId = await _findRecordId(
        collection: 'gtg_workout_logs',
        filter:
            '$_authenticatedUserFilter && clientId = "${_escapeFilter(log.id)}"',
      );
      final payload = workoutLogPayload(
        log: log,
        userId: _userId!,
        deviceId: _config.deviceId,
      );
      if (existingId == null) {
        await _post('/api/collections/gtg_workout_logs/records', payload);
      } else {
        await _patch(
          '/api/collections/gtg_workout_logs/records/$existingId',
          payload,
        );
      }
    }
  }

  @override
  Future<UserPreferences?> fetchUserPreferences() async {
    if (!isConfigured) return null;
    await _ensureAuth();
    final response = await _get(
      '/api/collections/gtg_user_preferences/records',
      <String, String>{
        'perPage': '1',
        'sort': '-updated',
        'filter': _authenticatedUserFilter,
      },
    );
    final items = _items(response);
    if (items.isEmpty) return null;
    return userPreferencesFromPocketBase(items.first);
  }

  @override
  Future<void> upsertUserPreferences(UserPreferences preferences) async {
    if (!isConfigured) return;
    await _ensureAuth();
    final existingId = await _findRecordId(
      collection: 'gtg_user_preferences',
      filter: 'user = "${_escapeFilter(_userId!)}"',
    );
    final payload = userPreferencesPayload(
      preferences: preferences,
      userId: _userId!,
      deviceId: _config.deviceId,
    );
    if (existingId == null) {
      await _post('/api/collections/gtg_user_preferences/records', payload);
    } else {
      await _patch(
        '/api/collections/gtg_user_preferences/records/$existingId',
        payload,
      );
    }
  }

  @override
  Future<GtgCoachRecommendation?> fetchLatestCoachRecommendation() async {
    if (!isConfigured) return null;
    await _ensureAuth();
    final response = await _get(
      '/api/collections/gtg_coach_recommendations/records',
      <String, String>{
        'perPage': '1',
        'sort': '-generatedAt',
        'filter': _authenticatedUserFilter,
      },
    );
    final items = _items(response);
    if (items.isEmpty) return null;
    return GtgCoachRecommendation.fromPocketBase(items.first);
  }

  Future<void> _ensureAuth() async {
    if (_token != null && _userId != null) return;
    final response = await _request(
      'POST',
      '/api/collections/users/auth-with-password',
      body: <String, Object?>{
        'identity': _config.email,
        'password': _config.password,
      },
      authenticated: false,
    );
    _token = '${response['token'] ?? ''}';
    final record = response['record'];
    if (_token!.isEmpty || record is! Map<String, Object?>) {
      throw const FormatException('PocketBase auth response is missing token.');
    }
    _userId = '${record['id'] ?? ''}';
    if (_userId!.isEmpty) {
      throw const FormatException(
        'PocketBase auth response is missing user id.',
      );
    }
  }

  Future<String?> _findRecordId({
    required String collection,
    required String filter,
  }) async {
    final response = await _get('/api/collections/$collection/records', {
      'perPage': '1',
      'filter': filter,
    });
    final items = _items(response);
    if (items.isEmpty) return null;
    return '${items.first['id'] ?? ''}';
  }

  Future<Map<String, Object?>> _get(String path, [Map<String, String>? query]) {
    return _request('GET', path, query: query);
  }

  Future<Map<String, Object?>> _post(String path, Map<String, Object?> body) {
    return _request('POST', path, body: body);
  }

  Future<Map<String, Object?>> _patch(String path, Map<String, Object?> body) {
    return _request('PATCH', path, body: body);
  }

  Future<Map<String, Object?>> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, Object?>? body,
    bool authenticated = true,
  }) async {
    final uri = _config.buildUri(path, query);
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (authenticated && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    final response = switch (method) {
      'GET' => await _httpClient.get(uri, headers: headers),
      'POST' => await _httpClient.post(
        uri,
        headers: headers,
        body: jsonEncode(body ?? const <String, Object?>{}),
      ),
      'PATCH' => await _httpClient.patch(
        uri,
        headers: headers,
        body: jsonEncode(body ?? const <String, Object?>{}),
      ),
      _ => throw ArgumentError.value(method, 'method'),
    };

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PocketBaseClientException(
        statusCode: response.statusCode,
        body: response.body,
      );
    }
    if (response.body.isEmpty) return <String, Object?>{};
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, Object?>) return decoded;
    throw const FormatException('PocketBase response root must be an object.');
  }

  List<Map<String, Object?>> _items(Map<String, Object?> response) {
    final raw = response['items'];
    if (raw is! List) return const <Map<String, Object?>>[];
    return raw.whereType<Map<String, Object?>>().toList(growable: false);
  }

  String _escapeFilter(String value) {
    return value.replaceAll('\\', '\\\\').replaceAll('"', '\\"');
  }

  String get _authenticatedUserFilter => 'user = "${_escapeFilter(_userId!)}"';
}

final class PocketBaseClientException implements Exception {
  const PocketBaseClientException({
    required this.statusCode,
    required this.body,
  });

  final int statusCode;
  final String body;

  @override
  String toString() => 'PocketBaseClientException($statusCode): $body';
}
