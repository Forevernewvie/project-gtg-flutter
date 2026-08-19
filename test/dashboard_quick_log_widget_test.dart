import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:project_gtg/app/gtg_app.dart';
import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
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
  InMemoryPersistence({List<ExerciseLog> logs = const <ExerciseLog>[]})
    : _logs = List<ExerciseLog>.unmodifiable(logs),
      super(directoryProvider: _DummyDirectoryProvider());

  List<ExerciseLog> _logs;

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
  testWidgets(skip: true, 'quick log records push-up and updates today total', (
    tester,
  ) async {
    final persistence = InMemoryPersistence();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [persistenceProvider.overrideWithValue(persistence)],
        child: const GtgApp(locale: Locale('ko')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dashboard.todayTotalValue')), findsOneWidget);
    expect(find.text('오늘 1세트 준비 완료'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('quicklog.pushUp.record')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('quicklog.pushUp.record')));
    await tester.pumpAndSettle();

    expect(find.text('10회'), findsWidgets);
  });

  testWidgets(skip: true, 'home mission cannot log beyond the daily set target', (
    tester,
  ) async {
    final persistence = InMemoryPersistence();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [persistenceProvider.overrideWithValue(persistence)],
        child: const GtgApp(locale: Locale('ko')),
      ),
    );
    await tester.pumpAndSettle();

    final missionButton = find.byKey(const Key('dashboard.missionLogButton'));
    expect(missionButton, findsOneWidget);

    for (var i = 0; i < 9; i++) {
      await tester.tap(missionButton, warnIfMissed: false);
    }
    await tester.pumpAndSettle();

    expect(persistence._logs.length, 8);
    expect(find.text('8/8세트'), findsOneWidget);
    expect(tester.widget<FilledButton>(missionButton).onPressed, isNull);
  });

  testWidgets(skip: true, 'reset requires confirmation before clearing all logs', (
    tester,
  ) async {
    final persistence = InMemoryPersistence(
      logs: <ExerciseLog>[
        ExerciseLog(
          id: 'seed',
          type: ExerciseType.pushUp,
          reps: 10,
          timestamp: DateTime(2026, 3, 8, 7, 30),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [persistenceProvider.overrideWithValue(persistence)],
        child: const GtgApp(locale: Locale('ko')),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('초기화'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('초기화'));
    await tester.pumpAndSettle();

    expect(find.text('모든 훈련 기록을 삭제할까요?'), findsOneWidget);
    expect(persistence._logs, isNotEmpty);

    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(persistence._logs, isNotEmpty);

    await tester.tap(find.text('초기화'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dashboard.confirmResetLogs')));
    await tester.pumpAndSettle();

    expect(persistence._logs, isEmpty);
  });
}
