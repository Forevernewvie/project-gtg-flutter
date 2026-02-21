import 'package:flutter/material.dart';

abstract final class GtgColors {
  static const _lightAccent = Color(0xFF2F6FED);
  static const _darkAccent = Color(0xFF4C8DFF);

  static const _lightTextPrimary = Color(0xFF10161D);
  static const _darkTextPrimary = Color(0xFFE6EDF3);
  static const _lightTextSecondary = Color(0xFF5A6877);
  static const _darkTextSecondary = Color(0xFF94A3B8);

  static const _lightBackground = Color(0xFFEEF2F5);
  static const _darkBackground = Color(0xFF0D1117);
  static const _lightSurface = Color(0xFFFFFFFF);
  static const _darkSurface = Color(0xFF151B23);
  static const _lightSurfaceAlt = Color(0xFFE6EDF3);
  static const _darkSurfaceAlt = Color(0xFF1E2A38);
  static const _lightSurfaceMuted = Color(0xFFF2F3F0);
  static const _darkSurfaceMuted = Color(0xFF1A2027);
  static const _lightBorder = Color(0xFFC9D4DE);
  static const _darkBorder = Color(0xFF2B3542);
  static const _lightWarningSurface = Color(0xFFE7F0FF);
  static const _darkWarningSurface = Color(0xFF1B2A44);
  static const _lightSuccess = Color(0xFF23C98A);
  static const _darkSuccess = Color(0xFF47DBA7);
  static const _lightError = Color(0xFFE15353);
  static const _darkError = Color(0xFFFF7A7B);
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
    backgroundFor(brightness),
    brightness == Brightness.dark ? _darkSurfaceMuted : _lightSurface,
  ];

  static List<Color> heroGradientFor(Brightness brightness) =>
      brightness == Brightness.dark
      ? const <Color>[Color(0xFF233A63), Color(0xFF1E3155), Color(0xFF14271F)]
      : const <Color>[Color(0xFFA8C5FF), Color(0xFF4C8DFF), Color(0xFF23C98A)];
}
