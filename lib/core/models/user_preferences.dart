import 'exercise_type.dart';

class UserPreferences {
  const UserPreferences({
    required this.hasCompletedOnboarding,
    required this.primaryExercise,
  });

  final bool hasCompletedOnboarding;
  final ExerciseType primaryExercise;

  static const UserPreferences defaults = UserPreferences(
    hasCompletedOnboarding: false,
    primaryExercise: ExerciseType.pushUp,
  );

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'primaryExercise': primaryExercise.key,
    };
  }

  static UserPreferences fromJson(Map<String, Object?> json) {
    final completedValue = json['hasCompletedOnboarding'];
    final bool hasCompletedOnboarding;

    if (completedValue is bool) {
      hasCompletedOnboarding = completedValue;
    } else if (completedValue is num) {
      hasCompletedOnboarding = completedValue != 0;
    } else if (completedValue is String) {
      hasCompletedOnboarding = completedValue.toLowerCase() == 'true';
    } else {
      hasCompletedOnboarding = defaults.hasCompletedOnboarding;
    }

    final primaryValue = json['primaryExercise'];
    final primaryKey = primaryValue is String ? primaryValue : '';
    final primaryExercise =
        ExerciseTypeX.fromKey(primaryKey) ?? defaults.primaryExercise;

    return UserPreferences(
      hasCompletedOnboarding: hasCompletedOnboarding,
      primaryExercise: primaryExercise,
    );
  }

  UserPreferences copyWith({
    bool? hasCompletedOnboarding,
    ExerciseType? primaryExercise,
  }) {
    return UserPreferences(
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      primaryExercise: primaryExercise ?? this.primaryExercise,
    );
  }
}
