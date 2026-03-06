import 'package:flutter/material.dart';

import 'gtg_colors.dart';

abstract final class GtgGradients {
  static LinearGradient pageBackground(Brightness brightness) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: GtgColors.pageBackgroundFor(brightness),
      stops: const <double>[0, 0.45, 1],
    );
  }

  static LinearGradient hero(Brightness brightness) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: GtgColors.heroGradientFor(brightness),
      stops: const <double>[0, 0.56, 1],
    );
  }
}
