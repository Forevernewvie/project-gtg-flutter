import 'package:isar_community/isar.dart';

import '../../../core/models/exercise_log.dart';
import '../../../core/models/exercise_type.dart';

part 'exercise_log_entity.g.dart';

@collection
class ExerciseLogEntity {
  ExerciseLogEntity();

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String logId;

  @Index()
  late DateTime timestamp;

  @Index()
  late String typeKey;

  late int reps;

  /// Converts this persistence entity into the domain model.
  ExerciseLog toModel() {
    final type = ExerciseTypeX.fromKey(typeKey);
    if (type == null) {
      throw const FormatException('Unknown exercise type key in Isar entity');
    }

    return ExerciseLog(id: logId, type: type, reps: reps, timestamp: timestamp);
  }

  /// Creates an Isar entity from the domain model.
  static ExerciseLogEntity fromModel(ExerciseLog model) {
    return ExerciseLogEntity()
      ..logId = model.id
      ..timestamp = model.timestamp
      ..typeKey = model.type.key
      ..reps = model.reps;
  }
}
