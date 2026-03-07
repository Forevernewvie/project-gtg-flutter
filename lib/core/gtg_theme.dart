import 'package:flutter/material.dart';

import 'gtg_colors.dart';
import 'ui/gtg_ui.dart';

abstract final class GtgTheme {
  /// Builds the light theme from shared GTG design tokens.
  static ThemeData light() => _build(Brightness.light);

  /// Builds the dark theme from shared GTG design tokens.
  static ThemeData dark() => _build(Brightness.dark);

  /// Composes one theme instance for the requested brightness.
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
    final textTheme = baseTextTheme
        .apply(bodyColor: onSurface, displayColor: onSurface)
        .copyWith(
          displayLarge: baseTextTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1.4,
          ),
          displayMedium: baseTextTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1.1,
          ),
          headlineSmall: baseTextTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
          ),
          titleLarge: baseTextTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
          titleMedium: baseTextTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
          bodyLarge: baseTextTheme.bodyLarge?.copyWith(height: 1.22),
          bodyMedium: baseTextTheme.bodyMedium?.copyWith(height: 1.25),
          bodySmall: baseTextTheme.bodySmall?.copyWith(height: 1.3),
          labelLarge: baseTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.1,
          ),
        );

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
        titleTextStyle: textTheme.titleLarge,
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: surface.withValues(alpha: isDark ? 0.94 : 0.88),
        indicatorColor: accent.withValues(alpha: isDark ? 0.26 : 0.14),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
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
          borderRadius: BorderRadius.circular(GtgUi.cardRadius),
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
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GtgUi.controlRadius + 2),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GtgUi.controlRadius + 2),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GtgUi.controlRadius + 2),
          borderSide: BorderSide(color: accent, width: 1.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: onAccent,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          minimumSize: const Size(0, 46),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GtgUi.pillRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GtgUi.pillRadius),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: onSurface,
          minimumSize: const Size(42, 42),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GtgUi.controlRadius),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GtgUi.controlRadius + 4),
        ),
        iconColor: onSurfaceVariant,
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
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(GtgUi.pillRadius),
            ),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      textTheme: textTheme,
    );
  }
}
