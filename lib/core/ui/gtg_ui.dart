/// Shared UI tokens and responsive rules used by GTG screens.
abstract final class GtgUi {
  static const double compactWidth = 360;
  static const double compactActionWidth = 420;
  static const double compactDetailWidth = 300;
  static const double elevatedTextScale = 1.25;
  static const double largeTextScale = 1.3;
  static const double accessibilityTextScale = 1.4;
  static const double screenHorizontalPadding = 16;
  static const double primarySectionSpacing = 12;
  static const double secondarySectionSpacing = 10;
  static const double contentSpacing = 14;
  static const double controlSpacing = 12;
  static const double cardRadius = 20;
  static const double controlRadius = 14;
  static const double pillRadius = 999;
  static const Duration emphasisAnimationDuration = Duration(milliseconds: 220);

  /// Returns true when the current width should collapse side-by-side content.
  static bool isCompactWidth(double width, {double threshold = compactWidth}) {
    return width < threshold;
  }

  /// Returns true when text scaling requires accessibility-first stacking.
  static bool isLargeTextScale(
    double textScale, {
    double threshold = largeTextScale,
  }) {
    return textScale >= threshold;
  }

  /// Returns true when either width or text scale requires a compact layout.
  static bool useCompactLayout({
    required double width,
    required double textScale,
    double widthThreshold = compactWidth,
    double textScaleThreshold = largeTextScale,
  }) {
    return isCompactWidth(width, threshold: widthThreshold) ||
        isLargeTextScale(textScale, threshold: textScaleThreshold);
  }
}
