part of 'dashboard_screen.dart';

/// Highlights today's progress and recent momentum in one glanceable hero card.
class _HeroCard extends ConsumerWidget {
  const _HeroCard();

  /// Builds the dashboard hero and adapts exercise chips for compact widths.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final todayTotal = ref.watch(todayTotalSumProvider);
    final activeDays = ref.watch(activeDaysLast14Provider);
    final mission = ref.watch(dailyGtgMissionProvider);
    final workoutState = ref.watch(workoutControllerProvider);
    final primaryExerciseLabel = mission.exercise.label(l10n);
    final logsReady = workoutState.hasValue;
    final heroValue = !logsReady
        ? l10n.loadingLogs
        : todayTotal == 0
        ? l10n.dashboardReadyTitle
        : l10n.repsWithUnit(todayTotal);
    final heroHint = logsReady
        ? l10n.dashboardPrimarySetHint(
            primaryExerciseLabel,
            mission.recommendedReps,
          )
        : l10n.quickLogHelper;

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
                        heroValue,
                        key: const Key('dashboard.todayTotalValue'),
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.9,
                            ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      heroHint,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _HeroPrimaryActionRow(
                      exerciseLabel: primaryExerciseLabel,
                      recommendedReps: mission.recommendedReps,
                      completedSets: mission.completedSets,
                      targetSets: mission.targetSets,
                      enabled: !mission.isComplete && workoutState.hasValue,
                      onPressed: () => _recordCurrentMissionSet(ref),
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

  Future<void> _recordCurrentMissionSet(WidgetRef ref) async {
    final mission = ref.read(dailyGtgMissionProvider);
    if (mission.isComplete) return;

    await ref
        .read(workoutControllerProvider.notifier)
        .addLog(mission.exercise, mission.recommendedReps);
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

/// Renders one clear first-action row inside the hero card.
class _HeroPrimaryActionRow extends StatelessWidget {
  const _HeroPrimaryActionRow({
    required this.exerciseLabel,
    required this.recommendedReps,
    required this.completedSets,
    required this.targetSets,
    required this.enabled,
    required this.onPressed,
  });

  final String exerciseLabel;
  final int recommendedReps;
  final int completedSets;
  final int targetSets;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 360;
            final summary = _HeroActionSummary(
              exerciseLabel: exerciseLabel,
              progressLabel: l10n.missionProgressValue(
                completedSets,
                targetSets,
              ),
            );
            final action = FilledButton.icon(
              key: const Key('dashboard.missionLogButton'),
              onPressed: enabled ? onPressed : null,
              icon: const Icon(Icons.add_task_rounded, size: 18),
              label: Text(l10n.missionLogAction(recommendedReps)),
            );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  summary,
                  const SizedBox(height: GtgUi.controlSpacing),
                  action,
                ],
              );
            }

            return Row(
              children: <Widget>[
                Expanded(child: summary),
                const SizedBox(width: GtgUi.controlSpacing),
                action,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeroActionSummary extends StatelessWidget {
  const _HeroActionSummary({
    required this.exerciseLabel,
    required this.progressLabel,
  });

  final String exerciseLabel;
  final String progressLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Padding(
            padding: EdgeInsets.all(9),
            child: Icon(
              Icons.flag_circle_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                exerciseLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                progressLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
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
