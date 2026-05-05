part of 'dashboard_screen.dart';

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

class _ReminderNudgeCard extends StatelessWidget {
  const _ReminderNudgeCard({required this.suggestion});

  final ReminderOptimizationSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return GtgSectionCard(
      key: const Key('dashboard.reminderNudgeCard'),
      icon: Icons.notifications_active_rounded,
      accent: colorScheme.tertiary,
      title: l10n.reminderOptimizationTitle,
      subtitle: ReminderUiPolicy.buildOptimizationMessage(
        l10n: l10n,
        suggestion: suggestion,
      ),
      trailing: TextButton(
        onPressed: () => context.push('/settings/reminders'),
        child: Text(l10n.reminderOptimizationApply),
      ),
      child: const SizedBox.shrink(),
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
