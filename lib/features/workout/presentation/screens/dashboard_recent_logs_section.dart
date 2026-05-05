part of 'dashboard_screen.dart';

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
