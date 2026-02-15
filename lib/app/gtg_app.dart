import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/gtg_theme.dart';
import '../l10n/app_localizations.dart';
import 'root_overlays.dart';
import 'router.dart';

class GtgApp extends StatefulWidget {
  const GtgApp({super.key, this.locale});

  /// For tests only. In production we follow the device locale automatically.
  final Locale? locale;

  @override
  State<GtgApp> createState() => _GtgAppState();
}

class _GtgAppState extends State<GtgApp> {
  late final GoRouter _router = createRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      locale: widget.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: GtgTheme.light(),
      routerConfig: _router,
      builder: (context, child) {
        return RootOverlays(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
