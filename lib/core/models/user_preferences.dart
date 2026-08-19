import 'exercise_type.dart';

class UserPreferences {
  const UserPreferences({
    required this.hasCompletedOnboarding,
    required this.primaryExercise,
    this.primaryExerciseMaxReps = 0,
    this.primaryExerciseDailySetTarget = 8,
    this.primaryExerciseLastMaxTestedAt,
  });

  final bool hasCompletedOnboarding;
  final ExerciseType primaryExercise;
  final int primaryExerciseMaxReps;
  final int primaryExerciseDailySetTarget;
  final DateTime? primaryExerciseLastMaxTestedAt;

  static const UserPreferences defaults = UserPreferences(
    hasCompletedOnboarding: true,
    primaryExercise: ExerciseType.pushUp,
  );

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'primaryExercise': primaryExercise.key,
      'primaryExerciseMaxReps': primaryExerciseMaxReps,
      'primaryExerciseDailySetTarget': primaryExerciseDailySetTarget,
      'primaryExerciseLastMaxTestedAt': primaryExerciseLastMaxTestedAt
          ?.toIso8601String(),
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
    final primaryExercise = ExerciseTypeX.fromKey(primaryKey);
    final primaryExerciseMaxReps = _readInt(
      json['primaryExerciseMaxReps'],
      fallback: defaults.primaryExerciseMaxReps,
    ).clamp(0, 999);
    final primaryExerciseDailySetTarget = _readInt(
      json['primaryExerciseDailySetTarget'],
      fallback: defaults.primaryExerciseDailySetTarget,
    ).clamp(1, 30);
    final primaryExerciseLastMaxTestedAt = _readDateTime(
      json['primaryExerciseLastMaxTestedAt'],
    );

    return UserPreferences(
      hasCompletedOnboarding: hasCompletedOnboarding,
      primaryExercise: primaryExercise,
      primaryExerciseMaxReps: primaryExerciseMaxReps,
      primaryExerciseDailySetTarget: primaryExerciseDailySetTarget,
      primaryExerciseLastMaxTestedAt: primaryExerciseLastMaxTestedAt,
    );
  }

  UserPreferences copyWith({
    bool? hasCompletedOnboarding,
    ExerciseType? primaryExercise,
    int? primaryExerciseMaxReps,
    int? primaryExerciseDailySetTarget,
    Object? primaryExerciseLastMaxTestedAt = _unset,
  }) {
    return UserPreferences(
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      primaryExercise: primaryExercise ?? this.primaryExercise,
      primaryExerciseMaxReps:
          primaryExerciseMaxReps ?? this.primaryExerciseMaxReps,
      primaryExerciseDailySetTarget:
          primaryExerciseDailySetTarget ?? this.primaryExerciseDailySetTarget,
      primaryExerciseLastMaxTestedAt:
          identical(primaryExerciseLastMaxTestedAt, _unset)
          ? this.primaryExerciseLastMaxTestedAt
          : primaryExerciseLastMaxTestedAt as DateTime?,
    );
  }

  static int _readInt(Object? value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? fallback;
  }

  static DateTime? _readDateTime(Object? value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

const Object _unset = Object();
