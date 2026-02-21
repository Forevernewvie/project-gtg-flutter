import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/gtg_theme.dart';
import '../core/models/app_theme_preference.dart';
import '../features/settings/state/theme_preference_controller.dart';
import '../l10n/app_localizations.dart';
import 'root_overlays.dart';
import 'router.dart';

class GtgApp extends ConsumerStatefulWidget {
  const GtgApp({super.key, this.locale});

  /// For tests only. In production we follow the device locale automatically.
  final Locale? locale;

  @override
  ConsumerState<GtgApp> createState() => _GtgAppState();
}

class _GtgAppState extends ConsumerState<GtgApp> {
  late final GoRouter _router = createRouter();

  @override
  Widget build(BuildContext context) {
    final themePreferenceAsync = ref.watch(themePreferenceControllerProvider);
    final themePreference =
        themePreferenceAsync.asData?.value ?? AppThemePreference.system;

    return MaterialApp.router(
      locale: widget.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: GtgTheme.light(),
      darkTheme: GtgTheme.dark(),
      themeMode: themePreference.themeMode,
      routerConfig: _router,
      builder: (context, child) {
        return RootOverlays(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
