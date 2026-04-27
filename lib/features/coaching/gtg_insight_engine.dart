import '../../core/date_utils.dart';
import '../../core/models/exercise_log.dart';
import 'gtg_coach_policy.dart';

/// The type of local, deterministic coaching insight to render.
enum GtgInsightKind { baselineMissing, consistency, trainingWindow, retestDue }

/// A compact local insight derived without network calls or server state.
final class GtgInsight {
  const GtgInsight({required this.kind, this.count = 0, this.hour});

  final GtgInsightKind kind;
  final int count;
  final int? hour;
}

/// Builds private, local-only GTG insights from logs and coach settings.
class GtgInsightEngine {
  const GtgInsightEngine();

  static const int lookbackDays = 14;
  static const int maxInsights = 3;

  List<GtgInsight> build({
    required List<ExerciseLog> logs,
    required GtgCoachSummary summary,
    required DateTime now,
  }) {
    final insights = <GtgInsight>[];

    if (!summary.hasBaseline) {
      insights.add(const GtgInsight(kind: GtgInsightKind.baselineMissing));
    }

    final recentLogs = _recentLogs(
      logs.where((log) => log.type == summary.primaryExercise).toList(),
      now,
    );
    final activeDays = _activeDayCount(recentLogs);
    if (activeDays > 0) {
      insights.add(
        GtgInsight(kind: GtgInsightKind.consistency, count: activeDays),
      );
    }

    final commonHour = _mostCommonHour(recentLogs);
    if (commonHour != null) {
      insights.add(
        GtgInsight(kind: GtgInsightKind.trainingWindow, hour: commonHour),
      );
    }

    if (summary.retestDue) {
      insights.add(const GtgInsight(kind: GtgInsightKind.retestDue));
    }

    return insights.take(maxInsights).toList(growable: false);
  }

  List<ExerciseLog> _recentLogs(List<ExerciseLog> logs, DateTime now) {
    final start = startOfDay(
      now,
    ).subtract(const Duration(days: lookbackDays - 1));
    return <ExerciseLog>[
      for (final log in logs)
        if (!log.timestamp.isBefore(start) && !log.timestamp.isAfter(now)) log,
    ];
  }

  int _activeDayCount(List<ExerciseLog> logs) {
    final days = <int>{};
    for (final log in logs) {
      days.add(startOfDay(log.timestamp).millisecondsSinceEpoch);
    }
    return days.length;
  }

  int? _mostCommonHour(List<ExerciseLog> logs) {
    if (logs.length < 2) return null;

    final counts = <int, int>{};
    for (final log in logs) {
      counts.update(
        log.timestamp.hour,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    MapEntry<int, int>? best;
    for (final entry in counts.entries) {
      if (best == null ||
          entry.value > best.value ||
          entry.value == best.value && entry.key < best.key) {
        best = entry;
      }
    }

    return best?.value == 1 ? null : best?.key;
  }
}
