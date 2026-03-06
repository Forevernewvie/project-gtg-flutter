import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/exercise_log.dart';
import '../../core/models/exercise_type.dart';
import '../../core/gtg_gradients.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/exercise_type_l10n.dart';
import 'state/workout_controller.dart';
import 'state/workout_stats_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

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

class _HeroCard extends ConsumerWidget {
  const _HeroCard();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final todayTotal = ref.watch(todayTotalSumProvider);
    final todayTotals = ref.watch(todayTotalsProvider);
    final activeDays = ref.watch(activeDaysLast14Provider);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
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
        borderRadius: BorderRadius.circular(28),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: GtgGradients.hero(Theme.of(context).brightness),
            borderRadius: BorderRadius.circular(28),
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
                            icon: _exerciseIcon(ExerciseType.pushUp),
                          ),
                          _MetricChip(
                            label: ExerciseType.pullUp.label(l10n),
                            value: '${todayTotals[ExerciseType.pullUp] ?? 0}',
                            icon: _exerciseIcon(ExerciseType.pullUp),
                          ),
                          _MetricChip(
                            label: ExerciseType.dips.label(l10n),
                            value: '${todayTotals[ExerciseType.dips] ?? 0}',
                            icon: _exerciseIcon(ExerciseType.dips),
                          ),
                        ];

                        if (constraints.maxWidth < 360) {
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

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.title,
    required this.subtitle,
    required this.activeDaysLabel,
  });

  final String title;
  final String subtitle;
  final String activeDaysLabel;

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
        borderRadius: BorderRadius.circular(999),
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
        final isCompact = constraints.maxWidth < 360;

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

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

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

class _QuickLogCard extends ConsumerStatefulWidget {
  const _QuickLogCard();
  @override
  ConsumerState<_QuickLogCard> createState() => _QuickLogCardState();
}

class _QuickLogCardState extends ConsumerState<_QuickLogCard> {
  int pushUp = 10;
  int pullUp = 5;
  int dips = 8;

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

                if (constraints.maxWidth < 360) {
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
            const SizedBox(height: 14),
            _QuickLogRow(
              type: ExerciseType.pushUp,
              reps: pushUp,
              onMinus: isReady
                  ? () => setState(() => pushUp = (pushUp - 1).clamp(1, 999))
                  : null,
              onPlus: isReady
                  ? () => setState(() => pushUp = pushUp + 1)
                  : null,
              onRecord: isReady
                  ? () async {
                      await ref
                          .read(workoutControllerProvider.notifier)
                          .addLog(ExerciseType.pushUp, pushUp);
                    }
                  : null,
            ),
            const SizedBox(height: 10),
            _QuickLogRow(
              type: ExerciseType.pullUp,
              reps: pullUp,
              onMinus: isReady
                  ? () => setState(() => pullUp = (pullUp - 1).clamp(1, 999))
                  : null,
              onPlus: isReady
                  ? () => setState(() => pullUp = pullUp + 1)
                  : null,
              onRecord: isReady
                  ? () async {
                      await ref
                          .read(workoutControllerProvider.notifier)
                          .addLog(ExerciseType.pullUp, pullUp);
                    }
                  : null,
            ),
            const SizedBox(height: 10),
            _QuickLogRow(
              type: ExerciseType.dips,
              reps: dips,
              onMinus: isReady
                  ? () => setState(() => dips = (dips - 1).clamp(1, 999))
                  : null,
              onPlus: isReady ? () => setState(() => dips = dips + 1) : null,
              onRecord: isReady
                  ? () async {
                      await ref
                          .read(workoutControllerProvider.notifier)
                          .addLog(ExerciseType.dips, dips);
                    }
                  : null,
            ),
            if (!isReady) ...<Widget>[
              const SizedBox(height: 14),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _exerciseAccent(context, type);
    final surface = Color.alphaBlend(
      accent.withValues(alpha: 0.08),
      colorScheme.surface,
    );

    final keyBase = switch (type) {
      ExerciseType.pushUp => 'pushUp',
      ExerciseType.pullUp => 'pullUp',
      ExerciseType.dips => 'dips',
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 420;

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
                          _exerciseIcon(type),
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

class _RecentLogsCard extends ConsumerWidget {
  const _RecentLogsCard();
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

class _RecentLogRow extends StatelessWidget {
  const _RecentLogRow({required this.log});

  final ExerciseLog log;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accent = _exerciseAccent(context, log.type);
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
            final useCompactRow =
                constraints.maxWidth < 280 || textScale >= 1.4;
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
                      _exerciseIcon(log.type),
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

class _HeroGlow extends StatelessWidget {
  const _HeroGlow({required this.size, required this.color});

  final double size;
  final Color color;

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

Color _exerciseAccent(BuildContext context, ExerciseType type) {
  final colorScheme = Theme.of(context).colorScheme;
  return switch (type) {
    ExerciseType.pushUp => colorScheme.primary,
    ExerciseType.pullUp => colorScheme.secondary,
    ExerciseType.dips => const Color(0xFFF59E0B),
  };
}

IconData _exerciseIcon(ExerciseType type) {
  return switch (type) {
    ExerciseType.pushUp => Icons.fitness_center_rounded,
    ExerciseType.pullUp => Icons.vertical_align_top_rounded,
    ExerciseType.dips => Icons.workspace_premium_rounded,
  };
}
