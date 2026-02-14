import 'package:flutter/material.dart';

import 'gtg_colors.dart';

abstract final class GtgGradients {
  static const pageBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[GtgColors.backgroundTop, GtgColors.backgroundBottom],
  );

  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[GtgColors.hero1, GtgColors.hero2, GtgColors.hero3],
  );
}
