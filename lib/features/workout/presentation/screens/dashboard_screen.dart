import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_gtg/core/gtg_gradients.dart';
import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/core/ui/gtg_ui.dart';
import 'package:project_gtg/features/coaching/gtg_coach_policy.dart';
import 'package:project_gtg/features/coaching/state/gtg_coach_providers.dart';
import 'package:project_gtg/features/workout/presentation/exercise_ui_style.dart';
import 'package:project_gtg/features/workout/presentation/workout_log_row.dart';
import 'package:project_gtg/features/workout/state/workout_controller.dart';
import 'package:project_gtg/features/workout/state/workout_stats_providers.dart';
import 'package:project_gtg/l10n/app_localizations.dart';
import 'package:project_gtg/l10n/exercise_type_l10n.dart';

/// Collects dashboard-specific layout and input guard rails in one place.
abstract final class _DashboardPolicy {
  static const double heroRadius = 28;
  static const int minQuickLogReps = 1;
  static const int maxQuickLogReps = 999;
  static const double startupPlaceholderHeight = 188;
  static const Map<ExerciseType, int> defaultDraftReps = <ExerciseType, int>{
    ExerciseType.pushUp: 10,
    ExerciseType.pullUp: 5,
    ExerciseType.dips: 8,
  };
}

/// Renders the home dashboard with hero metrics, quick logging, and recent history.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _dataActivated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _dataActivated = true);
    });
  }

  /// Builds the dashboard sections inside one vertically scrolling surface.
  @override
  Widget build(BuildContext context) {
    if (!_dataActivated) {
      return const _DashboardStartupPlaceholder();
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              GtgUi.screenHorizontalPadding,
              GtgUi.screenTopPadding,
              GtgUi.screenHorizontalPadding,
              GtgUi.primarySectionSpacing,
            ),
            child: const _HeroCard(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              GtgUi.screenHorizontalPadding,
              0,
              GtgUi.screenHorizontalPadding,
              GtgUi.primarySectionSpacing,
            ),
            child: const _CoachCard(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              GtgUi.screenHorizontalPadding,
              0,
              GtgUi.screenHorizontalPadding,
              GtgUi.primarySectionSpacing,
            ),
            child: const _QuickLogCard(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              GtgUi.screenHorizontalPadding,
              0,
              GtgUi.screenHorizontalPadding,
              GtgUi.screenBottomPadding + 4,
            ),
            child: const _RecentLogsCard(),
          ),
        ),
      ],
    );
  }
}

class _DashboardStartupPlaceholder extends StatelessWidget {
  const _DashboardStartupPlaceholder();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              GtgUi.screenHorizontalPadding,
              GtgUi.screenTopPadding,
              GtgUi.screenHorizontalPadding,
              GtgUi.primarySectionSpacing,
            ),
            child: const _StartupPlaceholderCard(
              height: _DashboardPolicy.startupPlaceholderHeight,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              GtgUi.screenHorizontalPadding,
              0,
              GtgUi.screenHorizontalPadding,
              GtgUi.primarySectionSpacing,
            ),
            child: const _StartupPlaceholderCard(height: 112),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              GtgUi.screenHorizontalPadding,
              0,
              GtgUi.screenHorizontalPadding,
              GtgUi.primarySectionSpacing,
            ),
            child: const _StartupPlaceholderCard(height: 260),
          ),
        ),
      ],
    );
  }
}

class _StartupPlaceholderCard extends StatelessWidget {
  const _StartupPlaceholderCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(GtgUi.cardRadius),
      ),
      child: SizedBox(
        height: height,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

/// Highlights today's progress and recent momentum in one glanceable hero card.
class _HeroCard extends ConsumerWidget {
  const _HeroCard();

  /// Builds the dashboard hero and adapts exercise chips for compact widths.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final todayTotal = ref.watch(todayTotalSumProvider);
    final todayTotals = ref.watch(todayTotalsProvider);
    final activeDays = ref.watch(activeDaysLast14Provider);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_DashboardPolicy.heroRadius),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 40,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_DashboardPolicy.heroRadius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: GtgGradients.hero(Theme.of(context).brightness),
            borderRadius: BorderRadius.circular(_DashboardPolicy.heroRadius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: -38,
                right: -16,
                child: _HeroGlow(
                  size: 132,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              Positioned(
                bottom: -52,
                left: -28,
                child: _HeroGlow(
                  size: 150,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _HeroHeader(
                      title: l10n.dashboardTitle,
                      subtitle: l10n.dashboardSubtitle,
                      activeDaysLabel: l10n.activeDaysPill(activeDays),
                    ),
                    const SizedBox(height: 20),
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.repsWithUnit(todayTotal),
                        key: const Key('dashboard.todayTotalValue'),
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.1,
                            ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.quickLogHelper,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    GtgResponsiveGroup(
                      spacing: 10,
                      children: <Widget>[
                        for (final type in ExerciseType.values)
                          _MetricChip(
                            label: type.label(l10n),
                            value: '${todayTotals[type] ?? 0}',
                            icon: ExerciseUiStyle.glyph(
                              type,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders the hero title block and the rolling streak pill.
class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.title,
    required this.subtitle,
    required this.activeDaysLabel,
  });

  final String title;
  final String subtitle;
  final String activeDaysLabel;

  /// Builds a responsive header row that can stack when space gets tight.
  @override
  Widget build(BuildContext context) {
    final titleWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.90),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    final activeDaysPill = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(GtgUi.pillRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.local_fire_department_rounded,
              size: 15,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                activeDaysLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = GtgUi.isCompactWidth(constraints.maxWidth);

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              titleWidget,
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerRight, child: activeDaysPill),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: titleWidget),
            const SizedBox(width: 12),
            activeDaysPill,
          ],
        );
      },
    );
  }
}

/// Displays one exercise stat inside the hero card.
class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final Widget icon;

  /// Builds a compact stat chip with icon, label, and value.
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(padding: const EdgeInsets.all(8), child: icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Summarizes the user's GTG coaching setup without disrupting the main log flow.
class _CoachCard extends ConsumerWidget {
  const _CoachCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final summary = ref.watch(gtgCoachSummaryProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return GtgSectionCard(
      key: const Key('dashboard.coachCard'),
      icon: Icons.track_changes_rounded,
      accent: colorScheme.secondary,
      title: l10n.settingsCoachTitle,
      subtitle: summary.hasBaseline
          ? l10n.coachCardReadySubtitle
          : l10n.coachCardSetupSubtitle,
      trailing: TextButton(
        onPressed: () => context.push('/settings/coach'),
        child: Text(
          summary.hasBaseline
              ? l10n.coachAdjustAction
              : l10n.coachSetBaselineAction,
        ),
      ),
      child: summary.hasBaseline
          ? _CoachReadyState(summary: summary)
          : _CoachEmptyState(message: l10n.coachSetupHint),
    );
  }
}

class _CoachReadyState extends StatelessWidget {
  const _CoachReadyState({required this.summary});

  final GtgCoachSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accent = Theme.of(context).colorScheme.secondary;
    final progressValue = l10n.coachTodayProgress(
      summary.completedSetsToday,
      summary.dailySetTarget,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GtgResponsivePair(
          primary: _CoachValueTile(
            label: l10n.coachRecommendedRepsLabel,
            value: l10n.repsWithUnit(summary.recommendedReps),
            accent: accent,
            keyValue: 'recommended',
          ),
          secondary: _CoachValueTile(
            label: l10n.coachTodayLabel,
            value: progressValue,
            accent: accent,
            keyValue: 'today',
          ),
        ),
        const SizedBox(height: GtgUi.controlSpacing),
        GtgResponsivePair(
          primary: _CoachValueTile(
            label: l10n.coachCompletedSetsLabel,
            value: l10n.coachSetsShort(summary.completedSetsToday),
            accent: accent,
            keyValue: 'completedSets',
          ),
          secondary: _CoachValueTile(
            label: l10n.coachTargetSetsLabel,
            value: l10n.coachSetsShort(summary.dailySetTarget),
            accent: accent,
            keyValue: 'targetSets',
          ),
        ),
        const SizedBox(height: GtgUi.controlSpacing),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            key: const Key('dashboard.coachProgress'),
            value: summary.progress,
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.coachRemainingSets(summary.remainingSetsToday),
          key: const Key('dashboard.coachRemaining'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (summary.retestDue) ...<Widget>[
          const SizedBox(height: GtgUi.controlSpacing),
          DecoratedBox(
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: <Widget>[
                  Icon(Icons.refresh_rounded, color: accent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.coachRetestDueMessage,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CoachValueTile extends StatelessWidget {
  const _CoachValueTile({
    required this.label,
    required this.value,
    required this.accent,
    required this.keyValue,
  });

  final String label;
  final String value;
  final Color accent;
  final String keyValue;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              key: Key('dashboard.coach.$keyValue'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoachEmptyState extends StatelessWidget {
  const _CoachEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// Hosts the quick-log draft state and renders the record controls.
class _QuickLogCard extends ConsumerStatefulWidget {
  const _QuickLogCard();

  /// Creates the state object that manages per-exercise quick-log drafts.
  @override
  ConsumerState<_QuickLogCard> createState() => _QuickLogCardState();
}

class _QuickLogCardState extends ConsumerState<_QuickLogCard> {
  late final Map<ExerciseType, int> _draftReps;
  String? _appliedCoachSignature;

  /// Seeds quick-log drafts from central defaults so exercise presets stay consistent.
  @override
  void initState() {
    super.initState();
    _draftReps = Map<ExerciseType, int>.of(_DashboardPolicy.defaultDraftReps);
  }

  /// Returns the current draft repetition count for one exercise type.
  int _repsFor(ExerciseType type) {
    return _draftReps[type] ?? _DashboardPolicy.minQuickLogReps;
  }

  /// Applies bounded repetition changes to one quick-log draft.
  void _updateReps(ExerciseType type, int nextReps) {
    setState(() {
      _draftReps[type] = nextReps.clamp(
        _DashboardPolicy.minQuickLogReps,
        _DashboardPolicy.maxQuickLogReps,
      );
    });
  }

  /// Persists one quick-log entry using the current draft value for that exercise.
  Future<void> _recordExercise(ExerciseType type) async {
    await ref
        .read(workoutControllerProvider.notifier)
        .addLog(type, _repsFor(type));
  }

  /// Builds the quick-log card while adapting controls for narrow widths.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userPreferences = ref.watch(userPreferencesValueProvider);
    final coachSummary = ref.watch(gtgCoachSummaryProvider);

    final workout = ref.watch(workoutControllerProvider);
    final isReady = workout.hasValue;
    final colorScheme = Theme.of(context).colorScheme;
    final coachSignature = coachSummary.hasBaseline
        ? '${coachSummary.primaryExercise.key}:${coachSummary.recommendedReps}'
        : null;

    if (coachSignature != null && coachSignature != _appliedCoachSignature) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _appliedCoachSignature == coachSignature) return;
        setState(() {
          _draftReps[coachSummary.primaryExercise] =
              coachSummary.recommendedReps;
          _appliedCoachSignature = coachSignature;
        });
      });
    }

    return GtgSectionCard(
      icon: Icons.bolt_rounded,
      accent: colorScheme.primary,
      title: l10n.quickLogTitle,
      subtitle: l10n.quickLogHelper,
      trailing: TextButton.icon(
        onPressed: isReady
            ? () async {
                await ref.read(workoutControllerProvider.notifier).clearAll();
              }
            : null,
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: Text(l10n.reset),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (
            var index = 0;
            index < ExerciseType.values.length;
            index++
          ) ...<Widget>[
            _QuickLogRow(
              type: ExerciseType.values[index],
              reps: _repsFor(ExerciseType.values[index]),
              recommendedReps:
                  coachSummary.hasBaseline &&
                      ExerciseType.values[index] ==
                          userPreferences.primaryExercise
                  ? coachSummary.recommendedReps
                  : null,
              onMinus: isReady
                  ? () => _updateReps(
                      ExerciseType.values[index],
                      _repsFor(ExerciseType.values[index]) - 1,
                    )
                  : null,
              onPlus: isReady
                  ? () => _updateReps(
                      ExerciseType.values[index],
                      _repsFor(ExerciseType.values[index]) + 1,
                    )
                  : null,
              onRecord: isReady
                  ? () => _recordExercise(ExerciseType.values[index])
                  : null,
            ),
            if (index != ExerciseType.values.length - 1)
              const SizedBox(height: GtgUi.secondarySectionSpacing),
          ],
          if (!isReady) ...<Widget>[
            const SizedBox(height: GtgUi.contentSpacing),
            GtgEmptyState(
              icon: Icons.hourglass_bottom_rounded,
              message: l10n.loadingLogs,
            ),
          ],
        ],
      ),
    );
  }
}

/// Renders one exercise row with stepper and record CTA.
class _QuickLogRow extends StatelessWidget {
  const _QuickLogRow({
    required this.type,
    required this.reps,
    required this.recommendedReps,
    required this.onMinus,
    required this.onPlus,
    required this.onRecord,
  });

  final ExerciseType type;
  final int reps;
  final int? recommendedReps;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;
  final VoidCallback? onRecord;

  /// Builds a responsive quick-log row and keeps action targets accessible.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final accent = ExerciseUiStyle.accent(context, type);
    final surface = Color.alphaBlend(
      accent.withValues(alpha: 0.08),
      colorScheme.surface,
    );
    final keyBase = type.key;

    return AnimatedContainer(
      duration: GtgUi.emphasisAnimationDuration,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = GtgUi.isCompactWidth(
              constraints.maxWidth,
              threshold: GtgUi.compactActionWidth,
            );
            final textScale = MediaQuery.textScalerOf(context).scale(1);
            final stackLabelMeta =
                isCompact ||
                GtgUi.isLargeTextScale(
                  textScale,
                  threshold: GtgUi.elevatedTextScale,
                );

            final stepper = DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: SizedBox(
                  height: 40,
                  width: isCompact ? null : 170,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            key: Key('quicklog.$keyBase.minus'),
                            tooltip: l10n.decreaseValue,
                            onPressed: onMinus,
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  colorScheme.surfaceContainerHighest,
                              minimumSize: const Size(40, 40),
                              padding: EdgeInsets.zero,
                            ),
                            icon: const Icon(Icons.remove_rounded),
                          ),
                          IconButton(
                            key: Key('quicklog.$keyBase.plus'),
                            tooltip: l10n.increaseValue,
                            onPressed: onPlus,
                            style: IconButton.styleFrom(
                              backgroundColor: colorScheme.primaryContainer,
                              foregroundColor: accent,
                              minimumSize: const Size(40, 40),
                              padding: EdgeInsets.zero,
                            ),
                            icon: const Icon(Icons.add_rounded),
                          ),
                        ],
                      ),
                      IgnorePointer(
                        child: Text(
                          '$reps',
                          key: Key('quicklog.$keyBase.value'),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

            final recordButton = FilledButton.icon(
              key: Key('quicklog.$keyBase.record'),
              onPressed: onRecord,
              icon: const Icon(Icons.bolt_rounded, size: 16),
              label: Text(l10n.record),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            );

            final countPill = DecoratedBox(
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(GtgUi.pillRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  l10n.repsWithUnit(reps),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            );
            final recommendedPill = recommendedReps == null
                ? null
                : DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(GtgUi.pillRadius),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        l10n.coachQuickLogRecommended(recommendedReps!),
                        key: Key('quicklog.$keyBase.recommended'),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  );

            final titleRow = Row(
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ExerciseUiStyle.glyph(type, color: accent, size: 18),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    type.label(l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            );

            final labelSection = stackLabelMeta
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      titleRow,
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[countPill, ?recommendedPill],
                      ),
                    ],
                  )
                : Row(
                    children: <Widget>[
                      Expanded(child: titleRow),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[countPill, ?recommendedPill],
                        ),
                      ),
                    ],
                  );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  labelSection,
                  const SizedBox(height: 10),
                  SizedBox(width: double.infinity, child: stepper),
                  const SizedBox(height: 8),
                  SizedBox(width: double.infinity, child: recordButton),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(child: labelSection),
                const SizedBox(width: 12),
                stepper,
                const SizedBox(width: 12),
                recordButton,
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Shows the most recent logs in a compact activity feed.
class _RecentLogsCard extends ConsumerWidget {
  const _RecentLogsCard();

  /// Builds recent activity rows or an empty-state hint when there is no history.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final sortedLogs = ref.watch(sortedWorkoutLogsProvider);

    final top = sortedLogs.take(5).toList(growable: false);

    return GtgSectionCard(
      icon: Icons.schedule_rounded,
      title: l10n.recentLogsTitle,
      child: top.isEmpty
          ? Text(
              l10n.noLogsHint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            )
          : Column(
              children: <Widget>[
                for (var index = 0; index < top.length; index++) ...<Widget>[
                  _RecentLogRow(log: top[index]),
                  if (index != top.length - 1)
                    const SizedBox(height: GtgUi.secondarySectionSpacing),
                ],
              ],
            ),
    );
  }
}

/// Renders one compact recent-log row with localized time and reps.
class _RecentLogRow extends StatelessWidget {
  const _RecentLogRow({required this.log});

  final ExerciseLog log;

  /// Builds a responsive row that stacks the reps pill when text size is large.
  @override
  Widget build(BuildContext context) {
    return WorkoutLogRow(log: log);
  }
}

/// Paints a soft decorative glow behind the hero without affecting hit testing.
class _HeroGlow extends StatelessWidget {
  const _HeroGlow({required this.size, required this.color});

  final double size;
  final Color color;

  /// Builds a fixed-size circular glow layer.
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: SizedBox.square(dimension: size),
      ),
    );
  }
}
