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
}
