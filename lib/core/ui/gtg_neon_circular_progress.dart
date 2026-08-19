import 'dart:math';
import 'package:flutter/material.dart';

import '../gtg_colors.dart';

class GtgNeonCircularProgress extends StatelessWidget {
  const GtgNeonCircularProgress({
    super.key,
    required this.progress,
    required this.child,
    this.size = 220,
    this.strokeWidth = 12,
  });

  final double progress;
  final Widget child;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _NeonRingPainter(progress: progress, strokeWidth: strokeWidth),
        child: Center(child: child),
      ),
    );
  }
}

class _NeonRingPainter extends CustomPainter {
  _NeonRingPainter({required this.progress, required this.strokeWidth});

  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background track
    final trackPaint = Paint()
      ..color = const Color(0xFF28364A).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);
    final startAngle = -pi / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);

    const gradient = SweepGradient(
      startAngle: -pi / 2,
      endAngle: 3 * pi / 2,
      colors: [GtgColors.neonBlue, GtgColors.neonPurple, GtgColors.neonBlue],
      stops: [0.0, 0.5, 1.0],
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw neon glow (blurred shadow)
    final glowPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);
    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _NeonRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
