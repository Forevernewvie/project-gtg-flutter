part of 'dashboard_screen.dart';

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

  bool _isRecording = false;

  /// Persists one quick-log entry using the current draft value for that exercise.
  /// Includes debounce lock to prevent duplicate records on rapid tapping.
  Future<void> _recordExercise(ExerciseType type) async {
    if (_isRecording) return;
    setState(() {
      _isRecording = true;
    });
    try {
      await ref
          .read(workoutControllerProvider.notifier)
          .addLog(type, _repsFor(type));
    } finally {
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }
    }
  }

  /// Confirms destructive history clearing before persisting an empty log list.
  Future<void> _confirmAndClearLogs(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text(l10n.resetLogsTitle),
              content: Text(l10n.resetLogsMessage),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(
                    MaterialLocalizations.of(context).cancelButtonLabel,
                  ),
                ),
                FilledButton(
                  key: const Key('dashboard.confirmResetLogs'),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(l10n.reset),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!confirmed || !mounted) return;

    await ref.read(workoutControllerProvider.notifier).clearAll();
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
        onPressed: isReady ? () => _confirmAndClearLogs(context) : null,
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

    return GtgGlassCard(
      padding: const EdgeInsets.all(16),
      showGlow: true,
      glowColor: accent,
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
                color: Colors.black26, // Darker stepper background
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
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
                              backgroundColor: Colors.transparent, // Removed grey
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
                              backgroundColor: accent.withValues(alpha: 0.15),
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
                    padding: const EdgeInsets.all(4),
                    child: ExerciseUiStyle.glyph(type, color: accent, size: 30),
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
    );
  }
}
