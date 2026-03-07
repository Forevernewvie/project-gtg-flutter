import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/gtg_gradients.dart';
import '../../core/models/exercise_log.dart';
import '../../core/models/exercise_type.dart';
import '../../core/ui/gtg_ui.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/exercise_type_l10n.dart';
import 'presentation/exercise_ui_style.dart';
import 'state/workout_controller.dart';
import 'state/workout_stats_providers.dart';

/// Collects dashboard-specific layout and input guard rails in one place.
abstract final class _DashboardPolicy {
  static const double heroRadius = 28;
  static const int minQuickLogReps = 1;
  static const int maxQuickLogReps = 999;
  static const Map<ExerciseType, int> defaultDraftReps = <ExerciseType, int>{
    ExerciseType.pushUp: 10,
    ExerciseType.pullUp: 5,
    ExerciseType.dips: 8,
  };
}

/// Renders the home dashboard with hero metrics, quick logging, and recent history.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  /// Builds the dashboard sections inside one vertically scrolling surface.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: const _HeroCard(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: const _QuickLogCard(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: const _RecentLogsCard(),
          ),
        ),
      ],
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
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final children = <Widget>[
                          _MetricChip(
                            label: ExerciseType.pushUp.label(l10n),
                            value: '${todayTotals[ExerciseType.pushUp] ?? 0}',
                            icon: ExerciseUiStyle.icon(ExerciseType.pushUp),
                          ),
                          _MetricChip(
                            label: ExerciseType.pullUp.label(l10n),
                            value: '${todayTotals[ExerciseType.pullUp] ?? 0}',
                            icon: ExerciseUiStyle.icon(ExerciseType.pullUp),
                          ),
                          _MetricChip(
                            label: ExerciseType.dips.label(l10n),
                            value: '${todayTotals[ExerciseType.dips] ?? 0}',
                            icon: ExerciseUiStyle.icon(ExerciseType.dips),
                          ),
                        ];

                        if (GtgUi.isCompactWidth(constraints.maxWidth)) {
                          return Column(
                            children: <Widget>[
                              for (
                                var i = 0;
                                i < children.length;
                                i++
                              ) ...<Widget>[
                                children[i],
                                if (i != children.length - 1)
                                  const SizedBox(height: 10),
                              ],
                            ],
                          );
                        }

                        return Row(
                          children: <Widget>[
                            for (
                              var i = 0;
                              i < children.length;
                              i++
                            ) ...<Widget>[
                              Expanded(child: children[i]),
                              if (i != children.length - 1)
                                const SizedBox(width: 10),
                            ],
                          ],
                        );
                      },
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
  final IconData icon;

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
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
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

/// Hosts the quick-log draft state and renders the record controls.
class _QuickLogCard extends ConsumerStatefulWidget {
  const _QuickLogCard();

  /// Creates the state object that manages per-exercise quick-log drafts.
  @override
  ConsumerState<_QuickLogCard> createState() => _QuickLogCardState();
}

class _QuickLogCardState extends ConsumerState<_QuickLogCard> {
  late final Map<ExerciseType, int> _draftReps;

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

    final workout = ref.watch(workoutControllerProvider);
    final isReady = workout.hasValue;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            LayoutBuilder(
              builder: (context, constraints) {
                final resetButton = TextButton.icon(
                  onPressed: isReady
                      ? () async {
                          await ref
                              .read(workoutControllerProvider.notifier)
                              .clearAll();
                        }
                      : null,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(l10n.reset),
                );

                final title = Row(
                  children: <Widget>[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.bolt_rounded,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            l10n.quickLogTitle,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.quickLogHelper,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                if (GtgUi.isCompactWidth(constraints.maxWidth)) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      title,
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: resetButton,
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child: title),
                    const SizedBox(width: 12),
                    resetButton,
                  ],
                );
              },
            ),
            const SizedBox(height: GtgUi.contentSpacing),
            for (
              var index = 0;
              index < ExerciseType.values.length;
              index++
            ) ...<Widget>[
              _QuickLogRow(
                type: ExerciseType.values[index],
                reps: _repsFor(ExerciseType.values[index]),
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
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Text(
                    l10n.loadingLogs,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Renders one exercise row with stepper and record CTA.
class _QuickLogRow extends StatelessWidget {
  const _QuickLogRow({
    required this.type,
    required this.reps,
    required this.onMinus,
    required this.onPlus,
    required this.onRecord,
  });

  final ExerciseType type;
  final int reps;
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

            final stepper = DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      key: Key('quicklog.$keyBase.minus'),
                      tooltip: l10n.reset,
                      onPressed: onMinus,
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerHighest,
                      ),
                      icon: const Icon(Icons.remove_rounded),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 62),
                      child: Center(
                        child: Text(
                          '$reps',
                          key: Key('quicklog.$keyBase.value'),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    IconButton(
                      key: Key('quicklog.$keyBase.plus'),
                      tooltip: l10n.record,
                      onPressed: onPlus,
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.primaryContainer,
                        foregroundColor: accent,
                      ),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              ),
            );

            final recordButton = FilledButton.icon(
              key: Key('quicklog.$keyBase.record'),
              onPressed: onRecord,
              icon: const Icon(Icons.bolt_rounded, size: 18),
              label: Text(l10n.record),
            );

            final labelSection = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          ExerciseUiStyle.icon(type),
                          color: accent,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        type.label(l10n),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.repsWithUnit(reps),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  labelSection,
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: stepper),
                  const SizedBox(height: 10),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.schedule_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.recentLogsTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (top.isEmpty)
              Text(
                l10n.noLogsHint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              ...top.map(
                (log) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RecentLogRow(log: log),
                ),
              ),
          ],
        ),
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
        borderRadius: BorderRadius.circular(18),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      ExerciseUiStyle.icon(log.type),
                      color: accent,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                borderRadius: BorderRadius.circular(14),
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
                  const SizedBox(height: 10),
                  Align(alignment: Alignment.centerRight, child: repsPill),
                ],
              );
            }

            return Row(
              children: <Widget>[
                Expanded(child: leading),
                const SizedBox(width: 12),
                repsPill,
              ],
            );
          },
        ),
      ),
    );
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
