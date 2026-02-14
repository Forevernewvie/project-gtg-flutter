import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/gtg_gradients.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: GtgGradients.pageBackground),
      child: Scaffold(
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
                  destinations: const <NavigationDestination>[
                    NavigationDestination(
                      icon: Icon(Icons.home_rounded),
                      label: '홈',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.calendar_month_rounded),
                      label: '캘린더',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.tune_rounded),
                      label: '설정',
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
