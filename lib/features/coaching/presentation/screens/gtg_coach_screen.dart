import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/clock.dart';
import '../../../../core/ui/gtg_ui.dart';
import '../../../../features/onboarding/state/user_preferences_controller.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/exercise_type_l10n.dart';
import '../../gtg_coach_policy.dart';
import '../../state/gtg_coach_providers.dart';

/// Settings surface for the app's lightweight GTG coaching layer.
class GtgCoachScreen extends ConsumerWidget {
  const GtgCoachScreen({super.key});

  Future<void> _updateMaxReps(
    WidgetRef ref,
    GtgCoachSummary summary,
    int nextValue,
  ) {
    final normalized = nextValue.clamp(
      GtgCoachPolicy.minMaxReps,
      GtgCoachPolicy.maxMaxReps,
    );
    return ref
        .read(userPreferencesControllerProvider.notifier)
        .updatePrimaryExerciseCoaching(
          maxReps: normalized,
          lastMaxTestedAt: normalized > 0
              ? ref.read(clockProvider).now()
              : null,
          clearLastMaxTestedAt: normalized == 0,
        );
  }

  Future<void> _updateDailyTarget(WidgetRef ref, int nextValue) {
    final normalized = nextValue.clamp(
      GtgCoachPolicy.minDailySetTarget,
      GtgCoachPolicy.maxDailySetTarget,
    );
    return ref
        .read(userPreferencesControllerProvider.notifier)
        .updatePrimaryExerciseCoaching(dailySetTarget: normalized);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final summary = ref.watch(gtgCoachSummaryProvider);
    final materialL10n = MaterialLocalizations.of(context);
    final lastTestedLabel = summary.lastMaxTestedAt == null
        ? l10n.coachLastTestedNever
        : materialL10n.formatShortDate(summary.lastMaxTestedAt!);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsCoachTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          GtgUi.screenHorizontalPadding,
          GtgUi.screenTopPadding,
          GtgUi.screenHorizontalPadding,
          GtgUi.screenBottomPadding + 4,
        ),
        children: <Widget>[
          GtgPageIntro(
            title: l10n.settingsCoachTitle,
            subtitle: l10n.settingsCoachSubtitle,
          ),
          const SizedBox(height: GtgUi.primarySectionSpacing),
          GtgSectionCard(
            icon: Icons.track_changes_rounded,
            accent: Theme.of(context).colorScheme.primary,
            title: l10n.coachFocusTitle,
            subtitle: l10n.coachFocusSubtitle,
            child: Column(
              children: <Widget>[
                _CoachStatRow(
                  label: l10n.coachFocusMoveLabel,
                  value: summary.primaryExercise.label(l10n),
                ),
                const SizedBox(height: GtgUi.secondarySectionSpacing),
                _CoachStatRow(
                  label: l10n.coachRecommendedRepsLabel,
                  value: summary.hasBaseline
                      ? l10n.repsWithUnit(summary.recommendedReps)
                      : l10n.coachNotSet,
                  helper: l10n.coachRecommendedHint,
                ),
                const SizedBox(height: GtgUi.secondarySectionSpacing),
                _CoachStatRow(
                  label: l10n.coachLastTestedLabel,
                  value: lastTestedLabel,
                ),
              ],
            ),
          ),
          const SizedBox(height: GtgUi.primarySectionSpacing),
          GtgSectionCard(
            icon: Icons.fitness_center_rounded,
            accent: Theme.of(context).colorScheme.secondary,
            title: l10n.coachBaselineTitle,
            subtitle: l10n.coachBaselineSubtitle,
            child: Column(
              children: <Widget>[
                _StepperPreferenceField(
                  fieldKey: 'coach.maxReps',
                  label: l10n.coachBaselineLabel,
                  value: summary.maxReps,
                  minimum: GtgCoachPolicy.minMaxReps,
                  maximum: GtgCoachPolicy.maxMaxReps,
                  semanticZeroLabel: l10n.coachNotSet,
                  onChanged: (nextValue) =>
                      _updateMaxReps(ref, summary, nextValue),
                ),
                const SizedBox(height: GtgUi.secondarySectionSpacing),
                _StepperPreferenceField(
                  fieldKey: 'coach.dailySetTarget',
                  label: l10n.coachDailySetGoalLabel,
                  value: summary.dailySetTarget,
                  minimum: GtgCoachPolicy.minDailySetTarget,
                  maximum: GtgCoachPolicy.maxDailySetTarget,
                  suffixBuilder: l10n.coachSetsShort,
                  onChanged: (nextValue) => _updateDailyTarget(ref, nextValue),
                ),
              ],
            ),
          ),
          const SizedBox(height: GtgUi.primarySectionSpacing),
          GtgSectionCard(
            icon: Icons.today_rounded,
            accent: Theme.of(context).colorScheme.primary,
            title: l10n.coachPlanTitle,
            subtitle: l10n.coachPlanSubtitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.coachTodayProgress(
                    summary.completedSetsToday,
                    summary.dailySetTarget,
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: summary.progress,
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: GtgUi.controlSpacing),
                Text(
                  l10n.coachRemainingSets(summary.remainingSetsToday),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (summary.retestDue) ...<Widget>[
                  const SizedBox(height: GtgUi.controlSpacing),
                  _CoachInfoBanner(
                    icon: Icons.refresh_rounded,
                    message: l10n.coachRetestDueMessage,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachStatRow extends StatelessWidget {
  const _CoachStatRow({required this.label, required this.value, this.helper});

  final String label;
  final String value;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        if (helper case final helper?) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            helper,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _StepperPreferenceField extends StatelessWidget {
  const _StepperPreferenceField({
    required this.fieldKey,
    required this.label,
    required this.value,
    required this.minimum,
    required this.maximum,
    required this.onChanged,
    this.semanticZeroLabel,
    this.suffixBuilder,
  });

  final String fieldKey;
  final String label;
  final int value;
  final int minimum;
  final int maximum;
  final Future<void> Function(int value) onChanged;
  final String? semanticZeroLabel;
  final String Function(int value)? suffixBuilder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labelText = value == 0 && semanticZeroLabel != null
        ? semanticZeroLabel!
        : (suffixBuilder?.call(value) ?? '$value');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(GtgUi.cardRadius - 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: GtgResponsivePair(
          primary: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                labelText,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          secondary: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                key: Key('$fieldKey.minus'),
                onPressed: value > minimum ? () => onChanged(value - 1) : null,
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surface,
                  minimumSize: const Size(40, 40),
                ),
                icon: const Icon(Icons.remove_rounded),
              ),
              const SizedBox(width: 8),
              IconButton(
                key: Key('$fieldKey.plus'),
                onPressed: value < maximum ? () => onChanged(value + 1) : null,
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.primary,
                  minimumSize: const Size(40, 40),
                ),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          expandPrimary: true,
          expandSecondary: false,
          compactSecondaryAlignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}

class _CoachInfoBanner extends StatelessWidget {
  const _CoachInfoBanner({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            Icon(icon, color: colorScheme.primary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
