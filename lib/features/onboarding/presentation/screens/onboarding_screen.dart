import 'package:flutter/material.dart';
import 'package:project_gtg/core/gtg_colors.dart';
import 'package:project_gtg/core/gtg_gradients.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/core/ui/gtg_ui.dart';
import 'package:project_gtg/features/coaching/gtg_coach_policy.dart';
import 'package:project_gtg/features/workout/presentation/exercise_ui_style.dart';
import 'package:project_gtg/l10n/app_localizations.dart';
import 'package:project_gtg/l10n/exercise_type_l10n.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.initialExercise,
    this.initialMaxReps = 0,
    required this.onComplete,
    required this.onSkip,
  });

  final ExerciseType initialExercise;
  final int initialMaxReps;
  final Future<void> Function({
    required ExerciseType primaryExercise,
    required int primaryExerciseMaxReps,
  })
  onComplete;
  final Future<void> Function() onSkip;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late ExerciseType _selected = widget.initialExercise;
  late int _maxReps = widget.initialMaxReps;
  bool _busy = false;

  void _updateMaxReps(int nextValue) {
    setState(() {
      _maxReps = nextValue.clamp(
        GtgCoachPolicy.minMaxReps,
        GtgCoachPolicy.maxMaxReps,
      );
    });
  }

  Future<void> _runBusy(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  List<_ExerciseChoice> _buildChoices(
    AppLocalizations l10n,
    Brightness brightness,
  ) {
    return <_ExerciseChoice>[
      _ExerciseChoice(
        type: ExerciseType.pushUp,
        accent: GtgColors.accentFor(brightness),
        subtitle: l10n.onboardingPushUpSubtitle,
      ),
      _ExerciseChoice(
        type: ExerciseType.pullUp,
        accent: GtgColors.successFor(brightness),
        subtitle: l10n.onboardingPullUpSubtitle,
      ),
      _ExerciseChoice(
        type: ExerciseType.dips,
        accent: GtgColors.textSecondaryFor(brightness),
        subtitle: l10n.onboardingDipsSubtitle,
      ),
    ];
  }

  /// Builds the onboarding flow and adapts header/actions for small or scaled layouts.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final brightness = Theme.of(context).brightness;
    final choices = _buildChoices(l10n, brightness);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: GtgGradients.pageBackground(Theme.of(context).brightness),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  GtgUi.screenHorizontalPadding,
                  18,
                  GtgUi.screenHorizontalPadding,
                  18,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      GtgPageIntro(
                        title: l10n.appTitle,
                        subtitle: l10n.onboardingSubtitle,
                        trailing: TextButton(
                          onPressed: _busy
                              ? null
                              : () => _runBusy(widget.onSkip),
                          child: Text(l10n.onboardingLater),
                        ),
                      ),
                      const SizedBox(height: GtgUi.primarySectionSpacing + 6),
                      GtgSectionCard(
                        icon: Icons.flag_rounded,
                        accent: GtgColors.accentFor(brightness),
                        title: l10n.onboardingQuestion,
                        subtitle: l10n.onboardingHint,
                        child: Column(
                          children: <Widget>[
                            for (
                              var index = 0;
                              index < choices.length;
                              index++
                            ) ...<Widget>[
                              _PickCard(
                                type: choices[index].type,
                                selected: _selected == choices[index].type,
                                onTap: _busy
                                    ? null
                                    : () => setState(
                                        () => _selected = choices[index].type,
                                      ),
                                accent: choices[index].accent,
                                subtitle: choices[index].subtitle,
                              ),
                              if (index != choices.length - 1)
                                const SizedBox(
                                  height: GtgUi.secondarySectionSpacing,
                                ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: GtgUi.primarySectionSpacing),
                      GtgSectionCard(
                        icon: Icons.fitness_center_rounded,
                        accent: GtgColors.successFor(brightness),
                        title: l10n.onboardingBaselineTitle,
                        subtitle: l10n.onboardingBaselineSubtitle,
                        child: _BaselineInputCard(
                          reps: _maxReps,
                          onMinus:
                              _busy || _maxReps <= GtgCoachPolicy.minMaxReps
                              ? null
                              : () => _updateMaxReps(_maxReps - 1),
                          onPlus: _busy
                              ? null
                              : () => _updateMaxReps(_maxReps + 1),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_busy) ...<Widget>[
                        const LinearProgressIndicator(minHeight: 3),
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _busy
                              ? null
                              : () => _runBusy(
                                  () => widget.onComplete(
                                    primaryExercise: _selected,
                                    primaryExerciseMaxReps: _maxReps,
                                  ),
                                ),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                GtgUi.pillRadius,
                              ),
                            ),
                          ),
                          child: Text(l10n.onboardingNext),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ExerciseChoice {
  const _ExerciseChoice({
    required this.type,
    required this.accent,
    required this.subtitle,
  });

  final ExerciseType type;
  final Color accent;
  final String subtitle;
}

class _PickCard extends StatelessWidget {
  const _PickCard({
    required this.type,
    required this.selected,
    required this.onTap,
    required this.accent,
    required this.subtitle,
  });

  final ExerciseType type;
  final bool selected;
  final VoidCallback? onTap;
  final Color accent;
  final String subtitle;

  /// Builds one selectable onboarding card with compact status affordance.
  @override
  Widget build(BuildContext context) {
    return GtgSelectableCard(
      leading: ExerciseUiStyle.glyph(
        type,
        color: selected
            ? accent
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      accent: accent,
      title: type.label(AppLocalizations.of(context)!),
      subtitle: subtitle,
      selected: selected,
      onTap: onTap,
    );
  }
}

class _BaselineInputCard extends StatelessWidget {
  const _BaselineInputCard({
    required this.reps,
    required this.onMinus,
    required this.onPlus,
  });

  final int reps;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

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
                l10n.onboardingBaselineFieldLabel,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                reps == 0 ? l10n.coachNotSet : l10n.repsWithUnit(reps),
                key: const Key('onboarding.maxReps.value'),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.onboardingBaselineFieldHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          secondary: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                key: const Key('onboarding.maxReps.minus'),
                tooltip: l10n.decreaseValue,
                onPressed: onMinus,
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surface,
                  minimumSize: const Size(40, 40),
                ),
                icon: const Icon(Icons.remove_rounded),
              ),
              const SizedBox(width: 8),
              IconButton(
                key: const Key('onboarding.maxReps.plus'),
                tooltip: l10n.increaseValue,
                onPressed: onPlus,
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
