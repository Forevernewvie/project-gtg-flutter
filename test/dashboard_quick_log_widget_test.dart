import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:project_gtg/app/gtg_app.dart';
import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/data/persistence/directory_provider.dart';
import 'package:project_gtg/data/persistence/gtg_persistence.dart';
import 'package:project_gtg/data/persistence/persistence_provider.dart';

class _DummyDirectoryProvider implements DirectoryProvider {
  @override
  Future<Directory> getApplicationSupportDirectory() async {
    // Should not be used by this test (we override IO methods).
    return Directory('/tmp');
  }
}

class InMemoryPersistence extends GtgPersistence {
  InMemoryPersistence() : super(directoryProvider: _DummyDirectoryProvider());

  List<ExerciseLog> _logs = const <ExerciseLog>[];

  @override
  Future<List<ExerciseLog>> loadLogs() async {
    return _logs;
  }

  @override
  Future<void> saveLogs(List<ExerciseLog> logs) async {
    _logs = List<ExerciseLog>.unmodifiable(logs);
  }
}

void main() {
  testWidgets('quick log records push-up and updates today total', (
    tester,
  ) async {
    final persistence = InMemoryPersistence();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [persistenceProvider.overrideWithValue(persistence)],
        child: const GtgApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dashboard.todayTotalValue')), findsOneWidget);
    expect(find.text('0회'), findsWidgets);

    await tester.tap(find.byKey(const Key('quicklog.pushUp.record')));
    await tester.pumpAndSettle();

    expect(find.text('10회'), findsWidgets);
  });
}
