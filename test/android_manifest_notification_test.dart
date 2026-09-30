import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AndroidManifest Notification Infrastructure Regression Tests', () {
    late String manifestContent;

    setUpAll(() {
      final manifestFile = File('android/app/src/main/AndroidManifest.xml');
      expect(
        manifestFile.existsSync(),
        isTrue,
        reason: 'AndroidManifest.xml must exist',
      );
      manifestContent = manifestFile.readAsStringSync();
    });

    test('declares android.permission.POST_NOTIFICATIONS for Android 13+', () {
      expect(
        manifestContent.contains('android.permission.POST_NOTIFICATIONS'),
        isTrue,
        reason:
            'POST_NOTIFICATIONS permission is required for runtime notification prompts.',
      );
    });

    test('declares android.permission.RECEIVE_BOOT_COMPLETED', () {
      expect(
        manifestContent.contains('android.permission.RECEIVE_BOOT_COMPLETED'),
        isTrue,
        reason:
            'RECEIVE_BOOT_COMPLETED is required so scheduled notifications survive reboot and app updates.',
      );
    });

    test('declares android.permission.VIBRATE for tactile alerts', () {
      expect(
        manifestContent.contains('android.permission.VIBRATE'),
        isTrue,
        reason: 'VIBRATE permission is required for tactile notification cues.',
      );
    });

    test('registers ScheduledNotificationReceiver in application tag', () {
      expect(
        manifestContent.contains(
          'com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver',
        ),
        isTrue,
        reason:
            'ScheduledNotificationReceiver is mandatory for AlarmManager broadcast delivery.',
      );
    });

    test(
      'registers ScheduledNotificationBootReceiver with all required intent-filters',
      () {
        expect(
          manifestContent.contains(
            'com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver',
          ),
          isTrue,
          reason:
              'ScheduledNotificationBootReceiver must be registered to restore alarms after boot.',
        );
        expect(
          manifestContent.contains('android.intent.action.BOOT_COMPLETED'),
          isTrue,
        );
        expect(
          manifestContent.contains('android.intent.action.MY_PACKAGE_REPLACED'),
          isTrue,
        );
        expect(
          manifestContent.contains('android.intent.action.QUICKBOOT_POWERON'),
          isTrue,
        );
      },
    );
  });
}
