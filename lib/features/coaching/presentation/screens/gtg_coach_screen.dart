import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/clock.dart';
import '../../../../core/ads/gtg_banner_ad.dart';
import '../../../../core/ui/gtg_ui.dart';
import '../../../../features/onboarding/state/user_preferences_controller.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/exercise_type_l10n.dart';
import '../../models/gtg_coach_recommendation.dart';
import '../../gtg_coach_policy.dart';
import '../../gtg_insight_engine.dart';
import '../../state/gtg_coach_providers.dart';
import '../../state/gtg_insight_providers.dart';

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
    final insights = ref.watch(gtgInsightsProvider);
    final adaptiveRecommendation = ref.watch(
      adaptiveGtgCoachRecommendationProvider,
    );
    final materialL10n = MaterialLocalizations.of(context);
    final lastTestedLabel = summary.lastMaxTestedAt == null
        ? l10n.coachLastTestedNever
        : materialL10n.formatShortDate(summary.lastMaxTestedAt!);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsCoachTitle)),
      bottomNavigationBar: const GtgBannerAd(
        padding: EdgeInsets.fromLTRB(
          GtgUi.screenHorizontalPadding,
          0,
          GtgUi.screenHorizontalPadding,
          10,
        ),
      ),
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
            child: _CoachFocusSummary(
              primaryExerciseLabel: summary.primaryExercise.label(l10n),
              recommendedRepsLabel: summary.hasBaseline
                  ? l10n.repsWithUnit(summary.recommendedReps)
                  : l10n.coachNotSet,
              lastTestedLabel: lastTestedLabel,
              recommendedHelper: l10n.coachRecommendedHint,
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
                GtgResponsivePair(
                  primary: _CoachStatRow(
                    label: l10n.coachRecommendedRepsLabel,
                    value: l10n.repsWithUnit(summary.recommendedReps),
                  ),
                  secondary: _CoachStatRow(
                    label: l10n.coachTodayLabel,
                    value: l10n.coachTodayProgress(
                      summary.completedSetsToday,
                      summary.dailySetTarget,
                    ),
                  ),
                ),
                const SizedBox(height: GtgUi.controlSpacing),
                GtgResponsivePair(
                  primary: _CoachStatRow(
                    label: l10n.coachCompletedSetsLabel,
                    value: l10n.coachSetsShort(summary.completedSetsToday),
                  ),
                  secondary: _CoachStatRow(
                    label: l10n.coachTargetSetsLabel,
                    value: l10n.coachSetsShort(summary.dailySetTarget),
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
          const SizedBox(height: GtgUi.primarySectionSpacing),
          _AdaptiveCoachCard(recommendation: adaptiveRecommendation),
          if (insights.isNotEmpty) ...<Widget>[
            const SizedBox(height: GtgUi.primarySectionSpacing),
            _CoachInsightsCard(insights: insights),
          ],
        ],
      ),
    );
  }
}

class _CoachFocusSummary extends StatelessWidget {
  const _CoachFocusSummary({
    required this.primaryExerciseLabel,
    required this.recommendedRepsLabel,
    required this.lastTestedLabel,
    required this.recommendedHelper,
  });

  final String primaryExerciseLabel;
  final String recommendedRepsLabel;
  final String lastTestedLabel;
  final String recommendedHelper;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _CoachAlignedStatRow(
          label: l10n.coachFocusMoveLabel,
          value: primaryExerciseLabel,
        ),
        const SizedBox(height: GtgUi.secondarySectionSpacing),
        _CoachAlignedStatRow(
          label: l10n.coachRecommendedRepsLabel,
          value: recommendedRepsLabel,
          helper: recommendedHelper,
        ),
        const SizedBox(height: GtgUi.secondarySectionSpacing),
        _CoachAlignedStatRow(
          label: l10n.coachLastTestedLabel,
          value: lastTestedLabel,
        ),
      ],
    );
  }
}

class _CoachAlignedStatRow extends StatelessWidget {
  const _CoachAlignedStatRow({
    required this.label,
    required this.value,
    this.helper,
  });

  final String label;
  final String value;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = GtgUi.isCompactWidth(constraints.maxWidth);
        if (isCompact) {
          return _CoachStatRow(label: label, value: value, helper: helper);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 176,
              child: Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: GtgUi.controlSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    value,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (helper case final helper?) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      helper,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AdaptiveCoachCard extends StatelessWidget {
  const _AdaptiveCoachCard({required this.recommendation});

  final GtgCoachRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final source = recommendation.isRemote
        ? l10n.adaptiveCoachRemoteSource
        : l10n.adaptiveCoachLocalSource;

    return GtgSectionCard(
      key: const Key('coach.adaptiveRecommendation'),
      icon: Icons.cloud_sync_rounded,
      accent: colorScheme.primary,
      title: l10n.adaptiveCoachTitle,
      subtitle: l10n.adaptiveCoachSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GtgResponsivePair(
            primary: _CoachStatRow(
              label: l10n.adaptiveCoachRecommendedSetsLabel,
              value: l10n.coachSetsShort(recommendation.recommendedSets),
            ),
            secondary: _CoachStatRow(
              label: l10n.coachRecommendedRepsLabel,
              value: l10n.repsWithUnit(recommendation.recommendedRepsPerSet),
            ),
          ),
          const SizedBox(height: GtgUi.controlSpacing),
          _CoachInfoBanner(
            icon: _adaptiveIcon(recommendation.intensity),
            message: l10n.adaptiveCoachRecommendationLine(
              _formatIntensity(l10n, recommendation.intensity),
              _formatRecommendationReason(l10n, recommendation.reasonCode),
              source,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _adaptiveIcon(GtgCoachIntensity intensity) {
  return switch (intensity) {
    GtgCoachIntensity.recover => Icons.spa_rounded,
    GtgCoachIntensity.maintain => Icons.check_circle_rounded,
    GtgCoachIntensity.progress => Icons.trending_up_rounded,
  };
}

String _formatIntensity(AppLocalizations l10n, GtgCoachIntensity intensity) {
  return switch (intensity) {
    GtgCoachIntensity.recover => l10n.adaptiveCoachIntensityRecover,
    GtgCoachIntensity.maintain => l10n.adaptiveCoachIntensityMaintain,
    GtgCoachIntensity.progress => l10n.adaptiveCoachIntensityProgress,
  };
}

String _formatRecommendationReason(AppLocalizations l10n, String reasonCode) {
  return switch (reasonCode) {
    'retest_due' => l10n.adaptiveCoachReasonRetestDue,
    'restart_after_gap' => l10n.adaptiveCoachReasonRestartAfterGap,
    'recover_volume' => l10n.adaptiveCoachReasonRecoverVolume,
    'progress_volume' => l10n.adaptiveCoachReasonProgressVolume,
    _ => l10n.adaptiveCoachReasonMaintainVolume,
  };
}

class _CoachInsightsCard extends StatelessWidget {
  const _CoachInsightsCard({required this.insights});

  final List<GtgInsight> insights;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return GtgSectionCard(
      key: const Key('coach.localInsights'),
      icon: Icons.insights_rounded,
      accent: colorScheme.tertiary,
      title: l10n.gtgInsightsTitle,
      subtitle: l10n.gtgInsightsSubtitle,
      child: Column(
        children: <Widget>[
          for (var i = 0; i < insights.length; i++) ...<Widget>[
            _CoachInfoBanner(
              icon: _insightIcon(insights[i].kind),
              message: _formatInsight(l10n, insights[i]),
            ),
            if (i != insights.length - 1)
              const SizedBox(height: GtgUi.controlSpacing),
          ],
        ],
      ),
    );
  }
}

IconData _insightIcon(GtgInsightKind kind) {
  return switch (kind) {
    GtgInsightKind.baselineMissing => Icons.fitness_center_rounded,
    GtgInsightKind.consistency => Icons.event_available_rounded,
    GtgInsightKind.trainingWindow => Icons.schedule_rounded,
    GtgInsightKind.retestDue => Icons.refresh_rounded,
  };
}

String _formatInsight(AppLocalizations l10n, GtgInsight insight) {
  return switch (insight.kind) {
    GtgInsightKind.baselineMissing => l10n.gtgInsightBaselineMissing,
    GtgInsightKind.consistency => l10n.gtgInsightConsistency(insight.count),
    GtgInsightKind.trainingWindow => l10n.gtgInsightTrainingWindow(
      _formatHourLabel(insight.hour ?? 0),
    ),
    GtgInsightKind.retestDue => l10n.gtgInsightRetestDue,
  };
}

String _formatHourLabel(int hour) {
  final normalized = hour.clamp(0, 23);
  return '${normalized.toString().padLeft(2, '0')}:00';
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

    return GtgInfoBanner(
      icon: icon,
      message: message,
      backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.45),
      borderColor: colorScheme.primary.withValues(alpha: 0.18),
      iconBackground: false,
      padding: const EdgeInsets.all(12),
      textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
