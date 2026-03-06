import 'package:flutter/material.dart';

abstract final class GtgColors {
  static const _lightAccent = Color(0xFF2563FF);
  static const _darkAccent = Color(0xFF74A8FF);

  static const _lightTextPrimary = Color(0xFF0F1724);
  static const _darkTextPrimary = Color(0xFFF2F7FC);
  static const _lightTextSecondary = Color(0xFF5E6B7A);
  static const _darkTextSecondary = Color(0xFF9AA9BC);

  static const _lightBackground = Color(0xFFF4F7FB);
  static const _darkBackground = Color(0xFF09111C);
  static const _lightSurface = Color(0xFFFFFFFF);
  static const _darkSurface = Color(0xFF101A27);
  static const _lightSurfaceAlt = Color(0xFFEAF1F8);
  static const _darkSurfaceAlt = Color(0xFF152131);
  static const _lightSurfaceMuted = Color(0xFFF0F4F8);
  static const _darkSurfaceMuted = Color(0xFF0D1621);
  static const _lightBorder = Color(0xFFD5E0EA);
  static const _darkBorder = Color(0xFF243244);
  static const _lightWarningSurface = Color(0xFFE8F1FF);
  static const _darkWarningSurface = Color(0xFF193152);
  static const _lightSuccess = Color(0xFF1ACB82);
  static const _darkSuccess = Color(0xFF43E6A0);
  static const _lightError = Color(0xFFE35757);
  static const _darkError = Color(0xFFFF8585);
  static const _onAccent = Color(0xFFF7FAFF);

  static Color accentFor(Brightness brightness) =>
      brightness == Brightness.dark ? _darkAccent : _lightAccent;
  static Color onAccentFor(Brightness brightness) => _onAccent;

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
      brightness == Brightness.dark
      ? _darkWarningSurface
      : _lightWarningSurface;
  static Color successFor(Brightness brightness) =>
      brightness == Brightness.dark ? _darkSuccess : _lightSuccess;
  static Color errorFor(Brightness brightness) =>
      brightness == Brightness.dark ? _darkError : _lightError;

  static List<Color> pageBackgroundFor(Brightness brightness) => <Color>[
    brightness == Brightness.dark
        ? const Color(0xFF08111B)
        : const Color(0xFFF5F8FC),
    brightness == Brightness.dark
        ? const Color(0xFF0D1A27)
        : const Color(0xFFEAF3FF),
    brightness == Brightness.dark
        ? const Color(0xFF0B1519)
        : const Color(0xFFF5F8FC),
  ];

  static List<Color> heroGradientFor(Brightness brightness) =>
      brightness == Brightness.dark
      ? const <Color>[Color(0xFF193B7A), Color(0xFF2456A8), Color(0xFF1C935E)]
      : const <Color>[Color(0xFF8FB6FF), Color(0xFF2563FF), Color(0xFF21C17A)];
}
