import 'package:flutter/widgets.dart';

import '../../../l10n/app_localizations.dart';

/// Immutable message payload used for scheduled reminder notifications.
class ReminderNotificationMessage {
  const ReminderNotificationMessage({required this.title, required this.body});

  final String title;
  final String body;
}

/// Abstraction for loading localized reminder notification copy.
abstract interface class ReminderMessageProvider {
  /// Returns localized notification title/body, with a safe fallback.
  Future<ReminderNotificationMessage> load();
}

typedef LocalizationLoader = Future<AppLocalizations> Function(Locale locale);
typedef DeviceLocaleReader = Locale Function();

/// Loads reminder messages from app localizations with explicit fallbacks.
class LocalizedReminderMessageProvider implements ReminderMessageProvider {
  LocalizedReminderMessageProvider({
    LocalizationLoader? loader,
    DeviceLocaleReader? readDeviceLocale,
    Locale? fallbackLocale,
    ReminderNotificationMessage? fallbackMessage,
  }) : loader = loader ?? _defaultLoader,
       readDeviceLocale = readDeviceLocale ?? _defaultDeviceLocale,
       fallbackLocale = fallbackLocale ?? const Locale('en'),
       fallbackMessage = fallbackMessage ?? _defaultFallbackMessage;

  final LocalizationLoader loader;
  final DeviceLocaleReader readDeviceLocale;
  final Locale fallbackLocale;
  final ReminderNotificationMessage fallbackMessage;

  /// Loads from the current device locale, then fallback locale, then constants.
  @override
  Future<ReminderNotificationMessage> load() async {
    try {
      return await _loadForLocale(readDeviceLocale());
    } catch (_) {
      try {
        return await _loadForLocale(fallbackLocale);
      } catch (_) {
        return fallbackMessage;
      }
    }
  }

  /// Loads localized strings for a specific [locale].
  Future<ReminderNotificationMessage> _loadForLocale(Locale locale) async {
    final l10n = await loader(locale);
    return ReminderNotificationMessage(
      title: l10n.notifTitle,
      body: l10n.notifBody,
    );
  }

  /// Reads locale from the platform dispatcher.
  static Locale _defaultDeviceLocale() {
    return WidgetsBinding.instance.platformDispatcher.locale;
  }

  /// Loads app localizations using Flutter's generated delegate.
  static Future<AppLocalizations> _defaultLoader(Locale locale) {
    return AppLocalizations.delegate.load(locale);
  }

  static const ReminderNotificationMessage _defaultFallbackMessage =
      ReminderNotificationMessage(
        title: 'Time for a set',
        body: 'Log one set to keep your rhythm today.',
      );
}
