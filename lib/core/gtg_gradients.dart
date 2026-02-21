import 'package:flutter/material.dart';

import 'gtg_colors.dart';

abstract final class GtgGradients {
  static LinearGradient pageBackground(Brightness brightness) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: GtgColors.pageBackgroundFor(brightness),
    );
  }

  static LinearGradient hero(Brightness brightness) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: GtgColors.heroGradientFor(brightness),
    );
  }
}
