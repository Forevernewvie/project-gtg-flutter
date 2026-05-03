import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/models/user_preferences.dart';
import '../../../features/onboarding/state/user_preferences_controller.dart';
import '../../../data/remote/cloud_sync_service.dart';
import '../../../data/remote/pocketbase_models.dart';
import '../../../features/workout/state/workout_stats_providers.dart';
import '../adaptive_gtg_coach.dart';
import '../gtg_coach_policy.dart';
import '../gtg_retention_policy.dart';

/// Exposes current persisted preferences as a synchronous value with safe defaults.
final userPreferencesValueProvider = Provider<UserPreferences>((ref) {
  return ref.watch(userPreferencesControllerProvider).asData?.value ??
      UserPreferences.defaults;
});

/// Builds the GTG coaching summary for the user's current focus movement.
final gtgCoachSummaryProvider = Provider<GtgCoachSummary>((ref) {
  return GtgCoachPolicy.summarize(
    preferences: ref.watch(userPreferencesValueProvider),
    logs: ref.watch(workoutLogsProvider),
    now: ref.watch(clockProvider).now(),
  );
});

final gtgRetentionPolicyProvider = Provider<GtgRetentionPolicy>((ref) {
  return const GtgRetentionPolicy();
});

/// Builds the daily Home mission that turns GTG logging into a return loop.
final dailyGtgMissionProvider = Provider<DailyGtgMission>((ref) {
  return ref
      .watch(gtgRetentionPolicyProvider)
      .buildMission(
        summary: ref.watch(gtgCoachSummaryProvider),
        logs: ref.watch(workoutLogsProvider),
        now: ref.watch(clockProvider).now(),
      );
});

/// Builds forgiving rhythm context for recovery copy and calendar summary.
final gtgRhythmSummaryProvider = Provider<GtgRhythmSummary>((ref) {
  return ref
      .watch(gtgRetentionPolicyProvider)
      .buildRhythm(
        logs: ref.watch(workoutLogsProvider),
        now: ref.watch(clockProvider).now(),
      );
});

final adaptiveGtgCoachPolicyProvider = Provider<AdaptiveGtgCoachPolicy>((ref) {
  return const AdaptiveGtgCoachPolicy();
});

/// Returns a server recommendation when PocketBase has one, otherwise local rules.
final adaptiveGtgCoachRecommendationProvider =
    FutureProvider<GtgCoachRecommendation>((ref) async {
      final remote = await ref
          .watch(cloudSyncServiceProvider)
          .fetchRemoteCoachRecommendation();
      if (remote != null) return remote;
      return ref
          .watch(adaptiveGtgCoachPolicyProvider)
          .recommend(
            preferences: ref.watch(userPreferencesValueProvider),
            logs: ref.watch(workoutLogsProvider),
            now: ref.watch(clockProvider).now(),
          );
    });
