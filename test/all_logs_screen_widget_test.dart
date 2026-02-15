import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/features/settings/all_logs_screen.dart';
import 'package:project_gtg/features/workout/state/workout_stats_providers.dart';

import 'test_app.dart';

void main() {
  testWidgets('all logs groups by day and shows totals', (tester) async {
    final logs = <ExerciseLog>[
      ExerciseLog(
        id: '1',
        type: ExerciseType.pushUp,
        reps: 10,
        timestamp: DateTime(2026, 2, 14, 13, 36),
      ),
      ExerciseLog(
        id: '2',
        type: ExerciseType.pullUp,
        reps: 5,
        timestamp: DateTime(2026, 2, 14, 14, 0),
      ),
      ExerciseLog(
        id: '3',
        type: ExerciseType.dips,
        reps: 3,
        timestamp: DateTime(2026, 2, 13, 12, 0),
      ),
      ExerciseLog(
        id: '4',
        type: ExerciseType.pushUp,
        reps: 4,
        timestamp: DateTime(2026, 2, 13, 12, 5),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [workoutLogsProvider.overrideWithValue(logs)],
        child: testApp(const AllLogsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('2월 14일'), findsOneWidget);
    expect(find.textContaining('2월 13일'), findsOneWidget);

    // Totals per day (10+5, 3+4).
    expect(find.text('15회'), findsOneWidget);
    expect(find.text('7회'), findsOneWidget);

    expect(find.text('푸쉬업'), findsWidgets);
    expect(find.text('풀업'), findsOneWidget);
    expect(find.text('딥스'), findsOneWidget);

    expect(find.text('10회'), findsOneWidget);
    expect(find.text('5회'), findsOneWidget);
    expect(find.text('3회'), findsOneWidget);
    expect(find.text('4회'), findsOneWidget);

    expect(find.textContaining('기록이 아직 없습니다'), findsNothing);
  });
}
