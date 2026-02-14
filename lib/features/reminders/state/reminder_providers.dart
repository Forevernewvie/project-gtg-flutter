import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/models/reminder_settings.dart';
import 'reminder_controller.dart';
import 'reminder_dependencies.dart';

final plannedReminderTimesProvider = Provider<List<DateTime>>((ref) {
  final asyncSettings = ref.watch(reminderControllerProvider);
  final settings = asyncSettings.asData?.value ?? ReminderSettings.defaults;
  if (!settings.enabled) return const <DateTime>[];

  final planner = ref.watch(reminderPlannerProvider);
  final now = ref.watch(clockProvider).now();
  return planner.planForToday(now: now, settings: settings);
});
