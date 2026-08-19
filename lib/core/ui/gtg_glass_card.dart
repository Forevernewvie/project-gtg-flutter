import 'dart:ui';
import 'package:flutter/material.dart';

import 'gtg_ui.dart';

class GtgGlassCard extends StatelessWidget {
  const GtgGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius,
    this.showGlow = false,
    this.glowColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final bool showGlow;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = borderRadius ?? BorderRadius.circular(GtgUi.cardRadius + 8);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: showGlow && isDark && glowColor != null
            ? [
                BoxShadow(
                  color: glowColor!.withValues(alpha: 0.15),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: isDark ? const Color(0x0AFFFFFF) : const Color(0x66FFFFFF),
              borderRadius: radius,
              border: Border.all(
                color: isDark
                    ? const Color(0x1AFFFFFF)
                    : const Color(0x33000000),
                width: 0.8,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
