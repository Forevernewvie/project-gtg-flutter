import '../../../core/models/exercise_type.dart';

/// Represents the payload of data synchronized to the Native OS (iOS/Android)
/// for rendering the home and lock screen widgets.
class WidgetDataModel {
  const WidgetDataModel({
    required this.todayTotal,
    required this.targetTotal,
    required this.primaryExercise,
  });

  /// Total reps logged today for the primary exercise.
  final int todayTotal;

  /// The daily target reps (from coaching logic).
  final int targetTotal;

  /// The currently focused exercise.
  final ExerciseType primaryExercise;

  /// Converts to a map of strings/ints for HomeWidget to save into AppGroups/SharedPreferences.
  Map<String, dynamic> toMap() {
    return {
      'gtg_today_total': todayTotal,
      'gtg_target_total': targetTotal,
      'gtg_primary_exercise': primaryExercise.key,
    };
  }
}
