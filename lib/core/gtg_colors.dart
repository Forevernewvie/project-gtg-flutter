import 'package:flutter/material.dart';

abstract final class GtgColors {
  // Primary Neon Accents
  static const neonBlue = Color(0xFF00E5FF);
  static const neonPurple = Color(0xFF9D00FF);
  static const neonGreen = Color(0xFF00FF9D);

  static const _lightAccent = Color(0xFF0055FF);
  static const _darkAccent = neonBlue;

  static const _lightTextPrimary = Color(0xFF111111);
  static const _darkTextPrimary = Color(0xFFFFFFFF);
  static const _lightTextSecondary = Color(0xFF555555);
  static const _darkTextSecondary = Color(0xFFAAAAAA);

  // High-end dark backgrounds for glow effects
  static const _lightBackground = Color(0xFFF5F7FA);
  static const _darkBackground = Color(0xFF090E17); // Deep Cyber Blue-Black
  static const _lightSurface = Color(0xFFFFFFFF);
  static const _darkSurface = Color(0xFF131B26); // Slightly elevated blue-grey
  static const _lightSurfaceAlt = Color(0xFFE9EDF2);
  static const _darkSurfaceAlt = Color(0xFF1A2433);
  static const _lightSurfaceMuted = Color(0xFFF0F3F7);
  static const _darkSurfaceMuted = Color(0xFF0D141E);
  static const _lightBorder = Color(0xFFDCDFE5);
  static const _darkBorder = Color(0xFF28364A); 
  
  static const _lightWarningSurface = Color(0xFFFFF4E5);
  static const _darkWarningSurface = Color(0xFF332014);
  static const _lightSuccess = Color(0xFF00A36C);
  static const _darkSuccess = neonGreen;
  static const _lightError = Color(0xFFFF3B30);
  static const _darkError = Color(0xFFFF453A);
  
  static const _onAccentLight = Color(0xFFFFFFFF);
  static const _onAccentDark = Color(0xFF090E17); 

  static Color accentFor(Brightness brightness) =>
      brightness == Brightness.dark ? _darkAccent : _lightAccent;
  static Color onAccentFor(Brightness brightness) =>
      brightness == Brightness.dark ? _onAccentDark : _onAccentLight;

  static Color textPrimaryFor(Brightness brightness) =>
      brightness == Brightness.dark ? _darkTextPrimary : _lightTextPrimary;
  static Color textSecondaryFor(Brightness brightness) =>
      brightness == Brightness.dark ? _darkTextSecondary : _lightTextSecondary;

  static Color backgroundFor(Brightness brightness) =>
      brightness == Brightness.dark ? _darkBackground : _lightBackground;
  static Color surfaceFor(Brightness brightness) =>
      brightness == Brightness.dark ? _darkSurface : _lightSurface;
  static Color surfaceAltFor(Brightness brightness) =>
      brightness == Brightness.dark ? _darkSurfaceAlt : _lightSurfaceAlt;
  static Color surfaceMutedFor(Brightness brightness) =>
      brightness == Brightness.dark ? _darkSurfaceMuted : _lightSurfaceMuted;

  static Color borderFor(Brightness brightness) =>
      brightness == Brightness.dark ? _darkBorder : _lightBorder;
  static Color warningSurfaceFor(Brightness brightness) =>
      brightness == Brightness.dark ? _darkWarningSurface : _lightWarningSurface;
  static Color successFor(Brightness brightness) =>
      brightness == Brightness.dark ? _darkSuccess : _lightSuccess;
  static Color errorFor(Brightness brightness) =>
      brightness == Brightness.dark ? _darkError : _lightError;

  static List<Color> pageBackgroundFor(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        const Color(0xFF0D1829),
        const Color(0xFF090E17),
        const Color(0xFF04060A),
      ];
    }
    return [
      const Color(0xFFF5F7FA),
      const Color(0xFFE9EDF2),
      const Color(0xFFDCDFE5),
    ];
  }

  static List<Color> heroGradientFor(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [
        const Color(0xFF00E5FF).withValues(alpha: 0.15),
        const Color(0xFF9D00FF).withValues(alpha: 0.05),
        Colors.transparent,
      ];
    }
    return [
      const Color(0xFF0055FF).withValues(alpha: 0.1),
      Colors.transparent,
      Colors.transparent,
    ];
  }

  static ColorScheme buildColorScheme(Brightness brightness) {
    return ColorScheme(
      brightness: brightness,
      primary: accentFor(brightness),
      onPrimary: onAccentFor(brightness),
      secondary: surfaceAltFor(brightness),
      onSecondary: textPrimaryFor(brightness),
      error: errorFor(brightness),
      onError: onAccentFor(brightness),
      surface: surfaceFor(brightness),
      onSurface: textPrimaryFor(brightness),
      surfaceContainerHighest: surfaceAltFor(brightness),
      onSurfaceVariant: textSecondaryFor(brightness),
      outline: borderFor(brightness),
      outlineVariant: surfaceMutedFor(brightness),
    );
  }
}
