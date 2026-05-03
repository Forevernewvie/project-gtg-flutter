import '../../core/models/exercise_log.dart';
import '../../core/models/exercise_type.dart';
import '../../core/models/user_preferences.dart';

/// A server-side adaptive GTG recommendation.
final class GtgCoachRecommendation {
  const GtgCoachRecommendation({
    required this.exerciseType,
    required this.recommendedSets,
    required this.recommendedRepsPerSet,
    required this.intensity,
    required this.message,
    required this.reasonCode,
    required this.generatedAt,
    this.isRemote = false,
  });

  final ExerciseType exerciseType;
  final int recommendedSets;
  final int recommendedRepsPerSet;
  final GtgCoachIntensity intensity;
  final String message;
  final String reasonCode;
  final DateTime generatedAt;
  final bool isRemote;

  static GtgCoachRecommendation fromPocketBase(Map<String, Object?> json) {
    final exercise =
        ExerciseTypeX.fromKey('${json['exerciseType']}') ?? ExerciseType.pushUp;
    return GtgCoachRecommendation(
      exerciseType: exercise,
      recommendedSets: _readInt(
        json['recommendedSets'],
        fallback: 1,
      ).clamp(1, 30),
      recommendedRepsPerSet: _readInt(
        json['recommendedRepsPerSet'],
        fallback: 1,
      ).clamp(1, 999),
      intensity: GtgCoachIntensityX.fromKey('${json['intensity']}'),
      message: '${json['message'] ?? ''}'.trim(),
      reasonCode: '${json['reasonCode'] ?? 'remote'}'.trim(),
      generatedAt: _readDate(json['generatedAt']) ?? DateTime.now(),
      isRemote: true,
    );
  }
}

enum GtgCoachIntensity { recover, maintain, progress }

extension GtgCoachIntensityX on GtgCoachIntensity {
  String get key => switch (this) {
    GtgCoachIntensity.recover => 'recover',
    GtgCoachIntensity.maintain => 'maintain',
    GtgCoachIntensity.progress => 'progress',
  };

  static GtgCoachIntensity fromKey(String key) {
    return switch (key) {
      'recover' => GtgCoachIntensity.recover,
      'progress' => GtgCoachIntensity.progress,
      _ => GtgCoachIntensity.maintain,
    };
  }
}

/// PocketBase record wrapper for workout logs.
final class RemoteExerciseLog {
  const RemoteExerciseLog({required this.recordId, required this.log});

  final String recordId;
  final ExerciseLog log;

  static RemoteExerciseLog fromPocketBase(Map<String, Object?> json) {
    return RemoteExerciseLog(
      recordId: '${json['id'] ?? ''}',
      log: ExerciseLog(
        id: '${json['clientId'] ?? json['id'] ?? ''}',
        type:
            ExerciseTypeX.fromKey('${json['exerciseType']}') ??
            ExerciseType.pushUp,
        reps: _readInt(json['reps'], fallback: 1).clamp(1, 999),
        timestamp: _readDate(json['loggedAt']) ?? DateTime.now(),
      ),
    );
  }
}

Map<String, Object?> workoutLogPayload({
  required ExerciseLog log,
  required String userId,
  required String deviceId,
}) {
  return <String, Object?>{
    'user': userId,
    'clientId': log.id,
    'exerciseType': log.type.key,
    'reps': log.reps,
    'loggedAt': log.timestamp.toUtc().toIso8601String(),
    'clientUpdatedAt': DateTime.now().toUtc().toIso8601String(),
    'deviceId': deviceId,
    'deleted': false,
  };
}

Map<String, Object?> userPreferencesPayload({
  required UserPreferences preferences,
  required String userId,
  required String deviceId,
}) {
  return <String, Object?>{
    'user': userId,
    'hasCompletedOnboarding': preferences.hasCompletedOnboarding,
    'primaryExercise': preferences.primaryExercise.key,
    'primaryExerciseMaxReps': preferences.primaryExerciseMaxReps,
    'primaryExerciseDailySetTarget': preferences.primaryExerciseDailySetTarget,
    'primaryExerciseLastMaxTestedAt': preferences.primaryExerciseLastMaxTestedAt
        ?.toUtc()
        .toIso8601String(),
    'clientUpdatedAt': DateTime.now().toUtc().toIso8601String(),
    'deviceId': deviceId,
  };
}

UserPreferences userPreferencesFromPocketBase(Map<String, Object?> json) {
  return UserPreferences.fromJson(<String, Object?>{
    'hasCompletedOnboarding': json['hasCompletedOnboarding'],
    'primaryExercise': json['primaryExercise'],
    'primaryExerciseMaxReps': json['primaryExerciseMaxReps'],
    'primaryExerciseDailySetTarget': json['primaryExerciseDailySetTarget'],
    'primaryExerciseLastMaxTestedAt': json['primaryExerciseLastMaxTestedAt'],
  });
}

int _readInt(Object? value, {required int fallback}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}

DateTime? _readDate(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
