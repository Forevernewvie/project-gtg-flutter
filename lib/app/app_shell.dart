import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/gtg_gradients.dart';
import '../l10n/app_localizations.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final compactNavigation = width < 360 || textScale >= 1.4;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: GtgGradients.pageBackground(Theme.of(context).brightness),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(bottom: false, child: navigationShell),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: NavigationBar(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: navigationShell.goBranch,
                  labelBehavior: compactNavigation
                      ? NavigationDestinationLabelBehavior.alwaysHide
                      : null,
                  destinations: <NavigationDestination>[
                    NavigationDestination(
                      icon: const Icon(Icons.home_rounded),
                      label: l10n.navHome,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: l10n.navCalendar,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.tune_rounded),
                      label: l10n.navSettings,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
