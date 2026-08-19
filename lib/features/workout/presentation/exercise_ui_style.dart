import 'package:flutter/material.dart';

import '../../../core/models/exercise_type.dart';

/// Centralizes per-exercise visual mapping for consistent workout UI.
abstract final class ExerciseUiStyle {
  static const Color _dipsAccent = Color(0xFFF59E0B);

  /// Returns the semantic accent color for one exercise type.
  static Color accent(BuildContext context, ExerciseType type) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (type) {
      ExerciseType.pushUp => colorScheme.primary,
      ExerciseType.pullUp => colorScheme.secondary,
      ExerciseType.dips => _dipsAccent,
    };
  }

  /// Returns the icon that should represent an exercise across screens.
  static IconData icon(ExerciseType type) {
    return switch (type) {
      ExerciseType.pushUp => Icons.fitness_center_rounded,
      ExerciseType.pullUp => Icons.vertical_align_top_rounded,
      ExerciseType.dips => Icons.workspace_premium_rounded,
    };
  }

  /// Returns the bundled GPT-generated exercise icon asset.
  static String assetPath(ExerciseType type) {
    return switch (type) {
      ExerciseType.pushUp => 'assets/exercise_icons/push_up.jpg',
      ExerciseType.pullUp => 'assets/exercise_icons/pull_up.jpg',
      ExerciseType.dips => 'assets/exercise_icons/dips.jpg',
    };
  }

  /// Returns a compact exercise icon, with the code-drawn glyph as a safe fallback.
  static Widget glyph(
    ExerciseType type, {
    required Color color,
    double size = 18,
  }) {
    return ExerciseIcon(type: type, fallbackColor: color, size: size);
  }
}

class ExerciseIcon extends StatelessWidget {
  const ExerciseIcon({
    super.key,
    required this.type,
    required this.fallbackColor,
    this.size = 18,
  });

  final ExerciseType type;
  final Color fallbackColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        ExerciseUiStyle.assetPath(type),
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        excludeFromSemantics: true,
        errorBuilder: (context, error, stackTrace) {
          return ExerciseGlyph(type: type, color: fallbackColor, size: size);
        },
      ),
    );
  }
}

class ExerciseGlyph extends StatelessWidget {
  const ExerciseGlyph({
    super.key,
    required this.type,
    required this.color,
    this.size = 18,
  });

  final ExerciseType type;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _ExerciseGlyphPainter(type: type, color: color),
      ),
    );
  }
}

class _ExerciseGlyphPainter extends CustomPainter {
  const _ExerciseGlyphPainter({required this.type, required this.color});

  final ExerciseType type;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (type) {
      case ExerciseType.pushUp:
        _drawPushUp(canvas, size, stroke, fill);
      case ExerciseType.pullUp:
        _drawPullUp(canvas, size, stroke, fill);
      case ExerciseType.dips:
        _drawDips(canvas, size, stroke, fill);
    }
  }


  void _drawPushUp(Canvas canvas, Size size, Paint stroke, Paint fill) {
    final head = Offset(size.width * 0.25, size.height * 0.28);
    canvas.drawCircle(head, size.width * 0.10, fill);
    final body = Path()
      ..moveTo(size.width * 0.33, size.height * 0.36)
      ..lineTo(size.width * 0.58, size.height * 0.42)
      ..lineTo(size.width * 0.77, size.height * 0.62);
    canvas.drawPath(body, stroke);
    canvas.drawLine(
      Offset(size.width * 0.54, size.height * 0.44),
      Offset(size.width * 0.47, size.height * 0.67),
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.73, size.height * 0.58),
      Offset(size.width * 0.82, size.height * 0.76),
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.16, size.height * 0.78),
      Offset(size.width * 0.88, size.height * 0.78),
      stroke,
    );
  }

  void _drawPullUp(Canvas canvas, Size size, Paint stroke, Paint fill) {
    final barY = size.height * 0.22;
    canvas.drawLine(
      Offset(size.width * 0.16, barY),
      Offset(size.width * 0.84, barY),
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.28, barY),
      Offset(size.width * 0.28, size.height * 0.34),
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.72, barY),
      Offset(size.width * 0.72, size.height * 0.34),
      stroke,
    );
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.40),
      size.width * 0.09,
      fill,
    );
    canvas.drawLine(
      Offset(size.width * 0.37, size.height * 0.34),
      Offset(size.width * 0.44, size.height * 0.48),
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.63, size.height * 0.34),
      Offset(size.width * 0.56, size.height * 0.48),
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.50, size.height * 0.49),
      Offset(size.width * 0.50, size.height * 0.70),
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.50, size.height * 0.70),
      Offset(size.width * 0.41, size.height * 0.84),
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.50, size.height * 0.70),
      Offset(size.width * 0.59, size.height * 0.84),
      stroke,
    );
  }

  void _drawDips(Canvas canvas, Size size, Paint stroke, Paint fill) {
    final leftBarX = size.width * 0.28;
    final rightBarX = size.width * 0.72;
    final topY = size.height * 0.22;
    final barBottom = size.height * 0.80;
    canvas.drawLine(
      Offset(leftBarX, topY),
      Offset(leftBarX, barBottom),
      stroke,
    );
    canvas.drawLine(
      Offset(rightBarX, topY),
      Offset(rightBarX, barBottom),
      stroke,
    );
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.30),
      size.width * 0.09,
      fill,
    );
    canvas.drawLine(
      Offset(size.width * 0.50, size.height * 0.39),
      Offset(size.width * 0.50, size.height * 0.62),
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.50, size.height * 0.44),
      Offset(leftBarX, size.height * 0.48),
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.50, size.height * 0.44),
      Offset(rightBarX, size.height * 0.48),
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.50, size.height * 0.62),
      Offset(size.width * 0.41, size.height * 0.82),
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.50, size.height * 0.62),
      Offset(size.width * 0.59, size.height * 0.82),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _ExerciseGlyphPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.color != color;
  }
}
