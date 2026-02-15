import 'package:flutter_test/flutter_test.dart';

import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/features/onboarding/onboarding_screen.dart';

import 'test_app.dart';

void main() {
  testWidgets('onboarding selects primary exercise and calls onComplete', (
    tester,
  ) async {
    ExerciseType? completedWith;
    var skipCalls = 0;

    await tester.pumpWidget(
      testApp(
        OnboardingScreen(
          initialExercise: ExerciseType.pushUp,
          onComplete: (primary) async => completedWith = primary,
          onSkip: () async => skipCalls++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('풀업'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(skipCalls, 0);
    expect(completedWith, ExerciseType.pullUp);
  });

  testWidgets('onboarding skip calls onSkip', (tester) async {
    var skipCalls = 0;

    await tester.pumpWidget(
      testApp(
        OnboardingScreen(
          initialExercise: ExerciseType.pushUp,
          onComplete: (_) async {},
          onSkip: () async => skipCalls++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('나중에'));
    await tester.pumpAndSettle();

    expect(skipCalls, 1);
  });
}
