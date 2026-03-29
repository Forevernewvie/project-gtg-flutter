import 'package:flutter/material.dart';

import '../../../core/models/exercise_log.dart';
import '../../../core/ui/gtg_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/exercise_type_l10n.dart';
import 'exercise_ui_style.dart';

/// Shared responsive workout log row used across dashboard and calendar details.
class WorkoutLogRow extends StatelessWidget {
  const WorkoutLogRow({super.key, required this.log});

  final ExerciseLog log;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accent = ExerciseUiStyle.accent(context, log.type);
    final colorScheme = Theme.of(context).colorScheme;

    final time = TimeOfDay.fromDateTime(log.timestamp);
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          accent.withValues(alpha: 0.08),
          colorScheme.surface,
        ),
        borderRadius: BorderRadius.circular(GtgUi.cardRadius - 2),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final textScale = MediaQuery.textScalerOf(context).scale(1);
            final useCompactRow = GtgUi.useCompactLayout(
              width: constraints.maxWidth,
              textScale: textScale,
              widthThreshold: 280,
              textScaleThreshold: GtgUi.accessibilityTextScale,
            );
            final leading = Row(
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(
                      GtgUi.controlRadius - 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ExerciseUiStyle.glyph(
                      log.type,
                      color: accent,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: GtgUi.controlSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        log.type.label(l10n),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$hh:$mm',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
            final repsPill = DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.86),
                borderRadius: BorderRadius.circular(GtgUi.controlRadius),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Text(
                  l10n.repsWithUnit(log.reps),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            );

            if (useCompactRow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  leading,
                  const SizedBox(height: GtgUi.secondarySectionSpacing),
                  Align(alignment: Alignment.centerRight, child: repsPill),
                ],
              );
            }

            return Row(
              children: <Widget>[
                Expanded(child: leading),
                const SizedBox(width: GtgUi.controlSpacing),
                repsPill,
              ],
            );
          },
        ),
      ),
    );
  }
}
