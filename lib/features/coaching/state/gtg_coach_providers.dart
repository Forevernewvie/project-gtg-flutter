import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/models/user_preferences.dart';
import '../../../features/onboarding/state/user_preferences_controller.dart';
import '../../../features/workout/state/workout_stats_providers.dart';
import '../gtg_coach_policy.dart';

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
