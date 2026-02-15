import 'package:flutter/material.dart';

import 'package:project_gtg/l10n/app_localizations.dart';

Widget testApp(Widget home, {Locale locale = const Locale('ko')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}
