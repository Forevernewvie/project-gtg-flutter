import '../../../core/models/exercise_type.dart';

enum GtgCoachIntensity {
  recover,
  maintain,
  progress;

  String get key => name;
}

class GtgCoachRecommendation {
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
}
