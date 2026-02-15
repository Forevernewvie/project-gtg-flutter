import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/env.dart';
import '../reminder_planner.dart';
import '../services/flutter_local_notifications_clients.dart';
import '../services/reminder_notification_client.dart';
import '../services/reminder_permission_client.dart';

final reminderPlannerProvider = Provider<ReminderPlanner>((ref) {
  return const ReminderPlanner();
});

final reminderPermissionClientProvider = Provider<ReminderPermissionClient>((
  ref,
) {
  if (Env.useFakes) {
    return const FakeReminderPermissionClient(granted: true);
  }

  if (Platform.isIOS) {
    return IosReminderPermissionClient();
  }
  if (Platform.isAndroid) {
    return AndroidReminderPermissionClient();
  }

  return const FakeReminderPermissionClient(granted: false);
});

final reminderNotificationClientProvider = Provider<ReminderNotificationClient>(
  (ref) {
    if (Env.useFakes) {
      return const FakeReminderNotificationClient();
    }
    return FlutterReminderNotificationClient();
  },
);
