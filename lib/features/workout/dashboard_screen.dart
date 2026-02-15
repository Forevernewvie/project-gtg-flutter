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
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: _HeroCard(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _QuickLogCard(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: _RecentLogsCard(),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final todayTotal = ref.watch(todayTotalSumProvider);
    final todayTotals = ref.watch(todayTotalsProvider);
    final activeDays = ref.watch(activeDaysLast14Provider);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: GtgGradients.hero,
        borderRadius: BorderRadius.circular(22),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.dashboardTitle,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.dashboardSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.90),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Text(
                      l10n.activeDaysPill(activeDays),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              l10n.repsWithUnit(todayTotal),
              key: const Key('dashboard.todayTotalValue'),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                _MetricChip(
                  label: ExerciseType.pushUp.label(l10n),
                  value: '${todayTotals[ExerciseType.pushUp] ?? 0}',
                ),
                const SizedBox(width: 10),
                _MetricChip(
                  label: ExerciseType.pullUp.label(l10n),
                  value: '${todayTotals[ExerciseType.pullUp] ?? 0}',
                ),
                const SizedBox(width: 10),
                _MetricChip(
                  label: ExerciseType.dips.label(l10n),
                  value: '${todayTotals[ExerciseType.dips] ?? 0}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
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
      ),
    );
  }
}

class _QuickLogCard extends ConsumerStatefulWidget {
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  l10n.quickLogTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextButton(
                  onPressed: isReady
                      ? () async {
                          await ref
                              .read(workoutControllerProvider.notifier)
                              .clearAll();
                        }
                      : null,
                  child: Text(l10n.reset),
                ),
              ],
            ),
            const SizedBox(height: 10),
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
              const SizedBox(height: 12),
              Text(
                l10n.loadingLogs,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black.withValues(alpha: 0.60),
                  fontWeight: FontWeight.w600,
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

    final keyBase = switch (type) {
      ExerciseType.pushUp => 'pushUp',
      ExerciseType.pullUp => 'pullUp',
      ExerciseType.dips => 'dips',
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    type.label(l10n),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.repsWithUnit(reps),
                    key: Key('quicklog.$keyBase.value'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black.withValues(alpha: 0.60),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              key: Key('quicklog.$keyBase.minus'),
              onPressed: onMinus,
              icon: const Icon(Icons.remove_rounded),
            ),
            IconButton(
              key: Key('quicklog.$keyBase.plus'),
              onPressed: onPlus,
              icon: const Icon(Icons.add_rounded),
            ),
            const SizedBox(width: 6),
            FilledButton(
              key: Key('quicklog.$keyBase.record'),
              onPressed: onRecord,
              child: Text(l10n.record),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentLogsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final logs = ref.watch(workoutLogsProvider);

    final recent = <ExerciseLog>[...logs]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final top = recent.take(5).toList(growable: false);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.recentLogsTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            if (top.isEmpty)
              Text(
                l10n.noLogsHint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black.withValues(alpha: 0.60),
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

    final time = TimeOfDay.fromDateTime(log.timestamp);
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Row(
          children: <Widget>[
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
                      color: Colors.black.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              l10n.repsWithUnit(log.reps),
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
