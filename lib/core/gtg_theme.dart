import 'package:flutter/material.dart';

import 'gtg_colors.dart';

abstract final class GtgTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final accent = GtgColors.accentFor(brightness);
    final onAccent = GtgColors.onAccentFor(brightness);
    final background = GtgColors.backgroundFor(brightness);
    final surface = GtgColors.surfaceFor(brightness);
    final surfaceAlt = GtgColors.surfaceAltFor(brightness);
    final border = GtgColors.borderFor(brightness);
    final warningSurface = GtgColors.warningSurfaceFor(brightness);
    final success = GtgColors.successFor(brightness);
    final error = GtgColors.errorFor(brightness);
    final onSurface = GtgColors.textPrimaryFor(brightness);
    final onSurfaceVariant = GtgColors.textSecondaryFor(brightness);

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: accent,
          brightness: brightness,
        ).copyWith(
          primary: accent,
          onPrimary: onAccent,
          primaryContainer: warningSurface,
          onPrimaryContainer: onSurface,
          secondary: success,
          onSecondary: onAccent,
          tertiary: GtgColors.surfaceMutedFor(brightness),
          onTertiary: onSurface,
          surface: surface,
          onSurface: onSurface,
          surfaceContainerLowest: background,
          surfaceContainerLow: surfaceAlt,
          surfaceContainer: surface,
          surfaceContainerHigh: surfaceAlt,
          surfaceContainerHighest: GtgColors.surfaceMutedFor(brightness),
          onSurfaceVariant: onSurfaceVariant,
          outline: border,
          outlineVariant: border,
          error: error,
          onError: const Color(0xFF0F141A),
        );

    final baseTextTheme = isDark
        ? Typography.whiteCupertino
        : Typography.blackCupertino;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: surface.withValues(alpha: isDark ? 0.96 : 0.92),
        indicatorColor: warningSurface,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: accent);
          }
          return IconThemeData(color: onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontWeight: FontWeight.w700,
            color: states.contains(WidgetState.selected)
                ? onSurface
                : onSurfaceVariant,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        labelStyle: TextStyle(
          color: onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accent, width: 1.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: onAccent,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return onAccent;
          return onSurface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return GtgColors.surfaceMutedFor(brightness);
        }),
        trackOutlineColor: WidgetStatePropertyAll(border),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return accent;
            return surface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return onAccent;
            return onSurface;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return BorderSide(color: accent, width: 1.1);
            }
            return BorderSide(color: border);
          }),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
    );
  }
}
