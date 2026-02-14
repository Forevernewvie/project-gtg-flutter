enum ExerciseType { pushUp, pullUp, dips }

extension ExerciseTypeX on ExerciseType {
  String get key {
    return switch (this) {
      ExerciseType.pushUp => 'pushUp',
      ExerciseType.pullUp => 'pullUp',
      ExerciseType.dips => 'dips',
    };
  }

  String get labelKo {
    return switch (this) {
      ExerciseType.pushUp => '푸쉬업',
      ExerciseType.pullUp => '풀업',
      ExerciseType.dips => '딥스',
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
