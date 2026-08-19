import 'package:flutter/material.dart';

class WatchTheme {
  static const Color slateGray = Color(0xFF2C2F33);
  static const Color darkBackground = Color(0xFF121212);
  static const Color neonMint = Color(0xFF00FF9D);
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: neonMint,
        surface: slateGray,
      ),
    );
  }
}
