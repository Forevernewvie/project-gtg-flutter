import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:project_gtg/app/gtg_app.dart';
import 'package:project_gtg/core/clock.dart';
import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/data/persistence/directory_provider.dart';
import 'package:project_gtg/data/persistence/gtg_persistence.dart';
import 'package:project_gtg/data/persistence/persistence_provider.dart';

class _DummyDirectoryProvider implements DirectoryProvider {
  @override
  Future<Directory> getApplicationSupportDirectory() async {
    return Directory('/tmp');
  }
}

class FixedClock implements Clock {
  FixedClock(this._now);

  final DateTime _now;

  @override
  DateTime now() => _now;
}

class InMemoryPersistence extends GtgPersistence {
  InMemoryPersistence(this._logs)
    : super(directoryProvider: _DummyDirectoryProvider());

  List<ExerciseLog> _logs;

  @override
  Future<List<ExerciseLog>> loadLogs() async {
    return List<ExerciseLog>.unmodifiable(_logs);
  }

  @override
  Future<void> saveLogs(List<ExerciseLog> logs) async {
    _logs = List<ExerciseLog>.unmodifiable(logs);
  }
}

void main() {
  testWidgets('calendar heatmap shows day details when a date is tapped', (
    tester,
  ) async {
    final now = DateTime(2026, 2, 18, 12);
    final persistence = InMemoryPersistence(<ExerciseLog>[
      ExerciseLog(
        id: 'a',
        type: ExerciseType.pushUp,
        reps: 10,
        timestamp: DateTime(2026, 2, 14, 9, 0),
      ),
      ExerciseLog(
        id: 'b',
        type: ExerciseType.pullUp,
        reps: 3,
        timestamp: DateTime(2026, 2, 14, 10, 0),
      ),
      ExerciseLog(
        id: 'c',
        type: ExerciseType.dips,
        reps: 8,
        timestamp: DateTime(2026, 2, 3, 12, 0),
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          persistenceProvider.overrideWithValue(persistence),
          clockProvider.overrideWithValue(FixedClock(now)),
        ],
        child: const GtgApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('캘린더'));
    await tester.pumpAndSettle();

    const dayKey = Key('calendar.day.2026-02-14');
    expect(find.byKey(dayKey), findsOneWidget);

    await tester.tap(find.byKey(dayKey));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -800));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('calendar.selectedDateLabel')), findsOneWidget);
    expect(find.text('2월 14일 (토)'), findsOneWidget);
    expect(find.text('하루 누적 13회'), findsOneWidget);
    expect(find.text('푸쉬업'), findsWidgets);
    expect(find.text('풀업'), findsWidgets);
  });
}
