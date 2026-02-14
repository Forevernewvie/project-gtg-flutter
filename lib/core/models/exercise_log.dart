import 'exercise_type.dart';

class ExerciseLog {
  const ExerciseLog({
    required this.id,
    required this.type,
    required this.reps,
    required this.timestamp,
  });

  final String id;
  final ExerciseType type;
  final int reps;
  final DateTime timestamp;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'type': type.key,
      'reps': reps,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static ExerciseLog fromJson(Map<String, Object?> json) {
    final typeValue = json['type'];
    final typeKey = typeValue is String ? typeValue : '';
    final type = ExerciseTypeX.fromKey(typeKey);
    if (type == null) {
      throw const FormatException('Unknown exercise type');
    }

    final repsValue = json['reps'];
    final reps = repsValue is int ? repsValue : int.tryParse('$repsValue') ?? 0;

    final tsValue = json['timestamp'];
    final tsRaw = tsValue is String ? tsValue : '';
    final timestamp = DateTime.tryParse(tsRaw);
    if (timestamp == null) {
      throw const FormatException('Invalid timestamp');
    }

    final idValue = json['id'];
    final id = idValue is String ? idValue : '';
    if (id.isEmpty) {
      throw const FormatException('Missing id');
    }

    return ExerciseLog(id: id, type: type, reps: reps, timestamp: timestamp);
  }
}
