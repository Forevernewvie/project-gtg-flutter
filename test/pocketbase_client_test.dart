import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/data/remote/pocketbase_client.dart';
import 'package:project_gtg/data/remote/pocketbase_config.dart';

void main() {
  test('fetch requests are scoped to the authenticated user', () async {
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);

      if (request.method == 'POST' &&
          request.url.path == '/api/collections/users/auth-with-password') {
        return _jsonResponse(<String, Object?>{
          'token': 'token-123',
          'record': <String, Object?>{'id': 'user-123'},
        });
      }

      if (request.method == 'GET' && request.url.path.endsWith('/records')) {
        return _jsonResponse(<String, Object?>{'items': <Object?>[]});
      }

      fail('Unexpected request: ${request.method} ${request.url}');
    });
    final remote = _client(client);

    await remote.fetchWorkoutLogs();
    await remote.fetchUserPreferences();
    await remote.fetchLatestCoachRecommendation();

    final recordFetches = requests.where(
      (request) =>
          request.method == 'GET' && request.url.path.endsWith('/records'),
    );
    expect(recordFetches, hasLength(3));
    for (final request in recordFetches) {
      expect(request.url.queryParameters['filter'], 'user = "user-123"');
    }
  });

  test('workout upsert lookup scopes stable client id by user', () async {
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);

      if (request.method == 'POST' &&
          request.url.path == '/api/collections/users/auth-with-password') {
        return _jsonResponse(<String, Object?>{
          'token': 'token-123',
          'record': <String, Object?>{'id': 'user-123'},
        });
      }

      if (request.method == 'GET' &&
          request.url.path == '/api/collections/gtg_workout_logs/records') {
        return _jsonResponse(<String, Object?>{'items': <Object?>[]});
      }

      if (request.method == 'POST' &&
          request.url.path == '/api/collections/gtg_workout_logs/records') {
        return _jsonResponse(<String, Object?>{});
      }

      fail('Unexpected request: ${request.method} ${request.url}');
    });
    final remote = _client(client);

    await remote.upsertWorkoutLogs(<ExerciseLog>[
      ExerciseLog(
        id: 'log-1',
        type: ExerciseType.pushUp,
        reps: 10,
        timestamp: DateTime.utc(2026, 3, 8, 7, 30),
      ),
    ]);

    final lookup = requests.singleWhere(
      (request) =>
          request.method == 'GET' &&
          request.url.path == '/api/collections/gtg_workout_logs/records',
    );
    expect(
      lookup.url.queryParameters['filter'],
      'user = "user-123" && clientId = "log-1"',
    );

    final create = requests.singleWhere(
      (request) =>
          request.method == 'POST' &&
          request.url.path == '/api/collections/gtg_workout_logs/records',
    );
    final payload = jsonDecode(create.body) as Map<String, Object?>;
    expect(payload['user'], 'user-123');
    expect(payload['clientId'], 'log-1');
  });
}

PocketBaseRemoteSyncClient _client(http.Client httpClient) {
  return PocketBaseRemoteSyncClient(
    config: const PocketBaseConfig(
      baseUrl: 'https://pb.example.test',
      email: 'user@example.test',
      password: 'secret',
      deviceId: 'device-1',
    ),
    httpClient: httpClient,
  );
}

http.Response _jsonResponse(Map<String, Object?> body) {
  return http.Response(
    jsonEncode(body),
    200,
    headers: const <String, String>{'content-type': 'application/json'},
  );
}
