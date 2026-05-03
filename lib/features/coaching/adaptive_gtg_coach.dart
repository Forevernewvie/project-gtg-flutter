import '../../core/date_utils.dart';
import '../../core/models/exercise_log.dart';
import '../../core/models/user_preferences.dart';
import '../../data/remote/pocketbase_models.dart';
import 'gtg_coach_policy.dart';

/// Local rule engine that mirrors the shape of server-generated coach guidance.
final class AdaptiveGtgCoachPolicy {
  const AdaptiveGtgCoachPolicy();

  GtgCoachRecommendation recommend({
    required UserPreferences preferences,
    required List<ExerciseLog> logs,
    required DateTime now,
  }) {
    final summary = GtgCoachPolicy.summarize(
      preferences: preferences,
      logs: logs,
      now: now,
    );
    final recentVolume = _volumeBetween(
      logs,
      startOfDay(now).subtract(const Duration(days: 6)),
      now,
      preferences,
    );
    final previousVolume = _volumeBetween(
      logs,
      startOfDay(now).subtract(const Duration(days: 13)),
      startOfDay(now).subtract(const Duration(days: 7)),
      preferences,
    );
    final quietDays = _quietDays(logs, now, preferences);

    final intensity = _intensity(
      recentVolume: recentVolume,
      previousVolume: previousVolume,
      quietDays: quietDays,
      retestDue: summary.retestDue,
    );
    final recommendedSets = _recommendedSets(summary.dailySetTarget, intensity);
    final recommendedReps = summary.recommendedReps <= 0
        ? 1
        : summary.recommendedReps;

    return GtgCoachRecommendation(
      exerciseType: preferences.primaryExercise,
      recommendedSets: recommendedSets,
      recommendedRepsPerSet: recommendedReps,
      intensity: intensity,
      message: _message(
        intensity: intensity,
        quietDays: quietDays,
        retestDue: summary.retestDue,
      ),
      reasonCode: _reasonCode(intensity, quietDays, summary.retestDue),
      generatedAt: now,
    );
  }

  int _volumeBetween(
    List<ExerciseLog> logs,
    DateTime start,
    DateTime end,
    UserPreferences preferences,
  ) {
    var total = 0;
    for (final log in logs) {
      if (log.type != preferences.primaryExercise) continue;
      if (log.timestamp.isBefore(start) || log.timestamp.isAfter(end)) continue;
      total += log.reps;
    }
    return total;
  }

  int _quietDays(
    List<ExerciseLog> logs,
    DateTime now,
    UserPreferences preferences,
  ) {
    final today = startOfDay(now);
    for (var offset = 0; offset < 14; offset++) {
      final day = today.subtract(Duration(days: offset));
      final hasLog = logs.any(
        (log) =>
            log.type == preferences.primaryExercise &&
            isSameDay(log.timestamp, day),
      );
      if (hasLog) return offset;
    }
    return 14;
  }

  GtgCoachIntensity _intensity({
    required int recentVolume,
    required int previousVolume,
    required int quietDays,
    required bool retestDue,
  }) {
    if (quietDays >= 3 || retestDue) return GtgCoachIntensity.recover;
    if (previousVolume > 0 && recentVolume >= (previousVolume * 1.25)) {
      return GtgCoachIntensity.maintain;
    }
    if (recentVolume > 0 &&
        previousVolume > 0 &&
        recentVolume < previousVolume) {
      return GtgCoachIntensity.maintain;
    }
    return GtgCoachIntensity.progress;
  }

  int _recommendedSets(int dailySetTarget, GtgCoachIntensity intensity) {
    return switch (intensity) {
      GtgCoachIntensity.recover => (dailySetTarget * 0.5).ceil().clamp(1, 30),
      GtgCoachIntensity.maintain => dailySetTarget.clamp(1, 30),
      GtgCoachIntensity.progress => (dailySetTarget + 1).clamp(1, 30),
    };
  }

  String _message({
    required GtgCoachIntensity intensity,
    required int quietDays,
    required bool retestDue,
  }) {
    if (retestDue) {
      return 'Your max test is stale. Keep today easy and refresh your baseline soon.';
    }
    if (quietDays >= 3) {
      return 'You have been quiet for a few days. Restart with a light GTG day.';
    }
    return switch (intensity) {
      GtgCoachIntensity.recover => 'Keep today easy and rebuild rhythm.',
      GtgCoachIntensity.maintain =>
        'Hold today steady and protect consistency.',
      GtgCoachIntensity.progress =>
        'Your rhythm is stable. Add one easy GTG set today.',
    };
  }

  String _reasonCode(
    GtgCoachIntensity intensity,
    int quietDays,
    bool retestDue,
  ) {
    if (retestDue) return 'retest_due';
    if (quietDays >= 3) return 'restart_after_gap';
    return '${intensity.key}_volume';
  }
}
