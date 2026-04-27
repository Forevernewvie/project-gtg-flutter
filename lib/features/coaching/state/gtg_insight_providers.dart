import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../workout/state/workout_stats_providers.dart';
import '../gtg_insight_engine.dart';
import 'gtg_coach_providers.dart';

final gtgInsightEngineProvider = Provider<GtgInsightEngine>((ref) {
  return const GtgInsightEngine();
});

final gtgInsightsProvider = Provider<List<GtgInsight>>((ref) {
  return ref
      .watch(gtgInsightEngineProvider)
      .build(
        logs: ref.watch(workoutLogsProvider),
        summary: ref.watch(gtgCoachSummaryProvider),
        now: ref.watch(clockProvider).now(),
      );
});
