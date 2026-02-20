import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_gtg/features/reminders/services/reminder_message_provider.dart';
import 'package:project_gtg/l10n/app_localizations.dart';

void main() {
  group('LocalizedReminderMessageProvider', () {
    test('loads message from device locale first', () async {
      final provider = LocalizedReminderMessageProvider(
        loader: AppLocalizations.delegate.load,
        readDeviceLocale: () => const Locale('ko'),
      );

      final message = await provider.load();
      expect(message.title, '한 세트 타이밍');
      expect(message.body, contains('푸쉬업/풀업/딥스'));
    });

    test(
      'falls back to fallback locale when device locale load fails',
      () async {
        final provider = LocalizedReminderMessageProvider(
          loader: (locale) async {
            if (locale.languageCode == 'ko') {
              throw StateError('device locale load failed');
            }
            return AppLocalizations.delegate.load(locale);
          },
          readDeviceLocale: () => const Locale('ko'),
          fallbackLocale: const Locale('en'),
        );

        final message = await provider.load();
        expect(message.title, 'Time for a set');
        expect(message.body, contains('push-ups'));
      },
    );

    test(
      'uses static fallback message when all localization loads fail',
      () async {
        const fallback = ReminderNotificationMessage(
          title: 'Fallback title',
          body: 'Fallback body',
        );
        final provider = LocalizedReminderMessageProvider(
          loader: (_) async => throw StateError('all failed'),
          readDeviceLocale: () => const Locale('ko'),
          fallbackLocale: const Locale('en'),
          fallbackMessage: fallback,
        );

        final message = await provider.load();
        expect(message.title, fallback.title);
        expect(message.body, fallback.body);
      },
    );
  });
}
