part of 'dashboard_screen.dart';

/// Summarizes the user's GTG coaching setup without disrupting the main log flow.
class _CoachCard extends ConsumerWidget {
  const _CoachCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final summary = ref.watch(gtgCoachSummaryProvider);

    return GtgGlassCard(
      showGlow: true,
      glowColor: const Color(0xFF00E5FF),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Your Smart Coach',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
              ),
              if (!summary.hasBaseline)
                TextButton(
                  onPressed: () => context.push('/settings/coach'),
                  child: Text(l10n.coachSetBaselineAction),
                ),
            ],
          ),
          const SizedBox(height: 24),
          summary.hasBaseline
              ? _CoachReadyState(summary: summary)
              : _CoachEmptyState(message: l10n.coachSetupHint),
        ],
      ),
    );
  }
}

class _ReminderNudgeCard extends StatelessWidget {
  const _ReminderNudgeCard({required this.suggestion});

  final ReminderOptimizationSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GtgGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reminderOptimizationTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            ReminderUiPolicy.buildOptimizationMessage(
              l10n: l10n,
              suggestion: suggestion,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.push('/settings/reminders'),
            child: Text(l10n.reminderOptimizationApply),
          ),
        ],
      ),
    );
  }
}

class _CoachReadyState extends ConsumerWidget {
  const _CoachReadyState({required this.summary});

  final GtgCoachSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {


    final completedSets = summary.completedSetsToday;
    final targetSets = summary.dailySetTarget;
    final progress = targetSets > 0
        ? (completedSets / targetSets).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return GtgNeonCircularProgress(
                progress: value,
                size: 260,
                strokeWidth: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$completedSets / $targetSets',
                      style: const TextStyle(
                        color: Color(0xFF00E5FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Daily Goal',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${summary.recommendedReps} ${summary.primaryExercise.key}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedSets completed',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${(value * 100).toInt()}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
        Text(
          progress >= 1.0
              ? "Goal reached! Great job! 🙌"
              : "You're ${(progress * 100).toInt()}% there! Let's hit $targetSets today! 🙌",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0055FF).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FilledButton.icon(
              onPressed: () {
                // Focus on Quick Log
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0066FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              icon: const Icon(Icons.local_fire_department_rounded),
              label: Text(
                'Start ${summary.primaryExercise.key}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => context.push('/logs'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            child: const Text(
              'Activity Log',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
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
