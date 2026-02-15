import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'reminder_notification_client.dart';
import 'reminder_permission_client.dart';

class IosReminderPermissionClient implements ReminderPermissionClient {
  IosReminderPermissionClient({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );

    _initialized = true;
  }

  @override
  Future<bool> hasPermission() async {
    await _ensureInitialized();

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    final status = await ios?.checkPermissions();
    if (status == null) return false;

    // `isEnabled` maps to iOS "Authorized", while "Provisional" is reported
    // separately. Either should be treated as "permission granted".
    return status.isEnabled || status.isProvisionalEnabled;
  }

  @override
  Future<bool> requestPermission() async {
    await _ensureInitialized();

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    return await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: false,
        ) ??
        false;
  }
}

class AndroidReminderPermissionClient implements ReminderPermissionClient {
  AndroidReminderPermissionClient({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );

    _initialized = true;
  }

  @override
  Future<bool> hasPermission() async {
    await _ensureInitialized();

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    return await android?.areNotificationsEnabled() ?? false;
  }

  @override
  Future<bool> requestPermission() async {
    await _ensureInitialized();

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final granted = await android?.requestNotificationsPermission();
    if (granted != null) return granted;

    return hasPermission();
  }
}

class FlutterReminderNotificationClient implements ReminderNotificationClient {
  FlutterReminderNotificationClient({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Best-effort; fall back to timezone's default local location.
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );

    _initialized = true;
  }

  @override
  Future<void> cancelAll() async {
    await _ensureInitialized();
    await _plugin.cancelAll();
  }

  @override
  Future<void> scheduleBatch({
    required List<DateTime> times,
    required String title,
    required String body,
  }) async {
    await _ensureInitialized();
    await _plugin.cancelAll();

    if (times.isEmpty) return;

    final first = times.first;
    final dayIndex =
        first.millisecondsSinceEpoch ~/ const Duration(days: 1).inMilliseconds;
    final base = (dayIndex % 2000000) * 100; // keep ids well under 2^31

    for (var i = 0; i < times.length; i++) {
      final scheduled = times[i];
      final id = base + i;

      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduled, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'gtg_reminders',
            'GTG Reminders',
            channelDescription: 'PROJECT GTG routine reminders',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            playSound: false,
            enableVibration: false,
          ),
          iOS: DarwinNotificationDetails(presentSound: false),
        ),
        // Avoid exact alarms permission (Android 12+) by using inexact scheduling.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
