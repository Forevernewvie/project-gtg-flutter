import 'package:flutter/material.dart';

import 'gtg_colors.dart';

abstract final class GtgTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: GtgColors.accent,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // Route pages pushed above AppShell need an explicit surface color.
      // Transparent here can render as black on some Android navigators.
      scaffoldBackgroundColor: GtgColors.backgroundTop,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: Colors.white.withValues(alpha: 0.92),
        indicatorColor: colorScheme.primaryContainer.withValues(alpha: 0.75),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      textTheme: Typography.blackCupertino.apply(
        bodyColor: GtgColors.textPrimary,
        displayColor: GtgColors.textPrimary,
      ),
    );
  }
}
