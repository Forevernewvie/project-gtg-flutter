import '../../core/date_utils.dart';
import '../../core/models/exercise_log.dart';
import '../../core/models/exercise_type.dart';
import 'gtg_coach_policy.dart';

/// The daily retention mission surfaced on Home.
final class DailyGtgMission {
  const DailyGtgMission({
    required this.exercise,
    required this.recommendedReps,
    required this.targetSets,
    required this.completedSets,
    required this.completedReps,
    required this.activeDaysLast7,
    required this.missedDaysSinceLastLog,
  });

  final ExerciseType exercise;
  final int recommendedReps;
  final int targetSets;
  final int completedSets;
  final int completedReps;
  final int activeDaysLast7;
  final int missedDaysSinceLastLog;

  int get remainingSets => (targetSets - completedSets).clamp(0, targetSets);
  bool get isComplete => remainingSets == 0;
  bool get isRecovery => completedSets == 0 && missedDaysSinceLastLog > 0;
  double get progress =>
      targetSets <= 0 ? 0 : (completedSets / targetSets).clamp(0, 1).toDouble();
}

/// Forgiving rhythm signal used by dashboard and calendar copy.
final class GtgRhythmSummary {
  const GtgRhythmSummary({
    required this.activeDaysLast7,
    required this.activeDaysLast14,
    required this.missedDaysSinceLastLog,
  });

  final int activeDaysLast7;
  final int activeDaysLast14;
  final int missedDaysSinceLastLog;

  bool get hasAnyRhythm => activeDaysLast14 > 0;
  bool get needsRecovery => missedDaysSinceLastLog > 0;
}

/// Builds local-first retention prompts without analytics or network state.
class GtgRetentionPolicy {
  const GtgRetentionPolicy();

  static const int recoverySetTarget = 1;
  static const Map<ExerciseType, int> defaultReps = <ExerciseType, int>{
    ExerciseType.pushUp: 10,
    ExerciseType.pullUp: 5,
    ExerciseType.dips: 8,
  };

  DailyGtgMission buildMission({
    required GtgCoachSummary summary,
    required List<ExerciseLog> logs,
    required DateTime now,
  }) {
    final primaryLogs = logs
        .where((log) => log.type == summary.primaryExercise )
        .toList(growable: false);
    final rhythm = buildRhythm(logs: primaryLogs, now: now);
    final completedSets = _completedSetsToday(primaryLogs, now);
    final completedReps = _completedRepsToday(primaryLogs, now);
    final recovering = completedSets == 0 && rhythm.missedDaysSinceLastLog > 0;

    return DailyGtgMission(
      exercise: summary.primaryExercise,
      recommendedReps: _recommendedReps(summary),
      targetSets: recovering ? recoverySetTarget : summary.dailySetTarget,
      completedSets: completedSets,
      completedReps: completedReps,
      activeDaysLast7: rhythm.activeDaysLast7,
      missedDaysSinceLastLog: rhythm.missedDaysSinceLastLog,
    );
  }

  GtgRhythmSummary buildRhythm({
    required List<ExerciseLog> logs,
    required DateTime now,
  }) {
    final today = startOfDay(now);
    final days = <int>{};
    DateTime? latestBeforeToday;

    for (final log in logs) {
      if (log.timestamp.isAfter(now)) continue;
      final day = startOfDay(log.timestamp);
      if (!today.difference(day).isNegative &&
          today.difference(day).inDays < 14) {
        days.add(day.millisecondsSinceEpoch);
      }
      if (day.isBefore(today) &&
          (latestBeforeToday == null || day.isAfter(latestBeforeToday))) {
        latestBeforeToday = day;
      }
    }

    final activeDaysLast7 = days.where((millis) {
      final day = DateTime.fromMillisecondsSinceEpoch(millis);
      return today.difference(day).inDays < 7;
    }).length;

    final missedDaysSinceLastLog = latestBeforeToday == null
        ? 0
        : (today.difference(latestBeforeToday).inDays - 1).clamp(0, 365);

    return GtgRhythmSummary(
      activeDaysLast7: activeDaysLast7,
      activeDaysLast14: days.length,
      missedDaysSinceLastLog: missedDaysSinceLastLog,
    );
  }

  int _recommendedReps(GtgCoachSummary summary) {
    if (summary.recommendedReps > 0) return summary.recommendedReps;
    return defaultReps[summary.primaryExercise] ?? 5;
  }

  int _completedSetsToday(List<ExerciseLog> logs, DateTime now) {
    final today = startOfDay(now);
    return logs.where((log) => isSameDay(log.timestamp, today)).length;
  }

  int _completedRepsToday(List<ExerciseLog> logs, DateTime now) {
    final today = startOfDay(now);
    return logs
        .where((log) => isSameDay(log.timestamp, today))
        .fold<int>(0, (total, log) => total + log.reps);
  }
}
