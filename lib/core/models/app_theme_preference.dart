import 'package:flutter/material.dart';

enum AppThemePreference {
  system,
  light,
  dark;

  String get key => name;

  ThemeMode get themeMode => switch (this) {
    AppThemePreference.system => ThemeMode.system,
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };

  static AppThemePreference fromRaw(Object? raw) {
    final value = raw is String ? raw.toLowerCase() : '';
    switch (value) {
      case 'light':
        return AppThemePreference.light;
      case 'dark':
        return AppThemePreference.dark;
      default:
        return AppThemePreference.system;
    }
  }
}
