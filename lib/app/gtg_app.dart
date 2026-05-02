import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/ads/ad_config.dart';
import '../core/ads/ad_privacy_manager.dart';
import '../core/gtg_theme.dart';
import '../l10n/app_localizations.dart';
import 'root_overlays.dart';
import 'router.dart';

Locale _resolveAppLocale(List<Locale>? locales) {
  final hasKorean =
      locales?.any((locale) => locale.languageCode.toLowerCase() == 'ko') ??
      false;
  return hasKorean ? const Locale('ko') : const Locale('en');
}

class GtgApp extends ConsumerStatefulWidget {
  const GtgApp({super.key, this.locale});

  /// For tests only. In production we follow the device locale automatically.
  final Locale? locale;

  @override
  ConsumerState<GtgApp> createState() => _GtgAppState();
}

class _GtgAppState extends ConsumerState<GtgApp> {
  late final GoRouter _router = createRouter();
  late final ThemeData _darkTheme = GtgTheme.dark();

  @override
  void initState() {
    super.initState();
    if (AdConfig.isEnabled) {
      unawaited(AdPrivacyManager.instance.prepareForAppLaunch());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      locale: widget.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: widget.locale == null
          ? (locales, supportedLocales) => _resolveAppLocale(locales)
          : null,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: _darkTheme,
      darkTheme: _darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: _router,
      builder: (context, child) {
        return RootOverlays(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
