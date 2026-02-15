enum ExerciseType { pushUp, pullUp, dips }

extension ExerciseTypeX on ExerciseType {
  String get key {
    return switch (this) {
      ExerciseType.pushUp => 'pushUp',
      ExerciseType.pullUp => 'pullUp',
      ExerciseType.dips => 'dips',
    };
  }

  static ExerciseType? fromKey(String value) {
    return switch (value) {
      'pushUp' => ExerciseType.pushUp,
      'pullUp' => ExerciseType.pullUp,
      'dips' => ExerciseType.dips,
      _ => null,
    };
  }
}
