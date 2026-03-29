import 'package:flutter/material.dart';
import 'package:project_gtg/core/gtg_colors.dart';
import 'package:project_gtg/core/gtg_gradients.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/core/ui/gtg_ui.dart';
import 'package:project_gtg/features/workout/presentation/exercise_ui_style.dart';
import 'package:project_gtg/l10n/app_localizations.dart';
import 'package:project_gtg/l10n/exercise_type_l10n.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.initialExercise,
    required this.onComplete,
    required this.onSkip,
  });

  final ExerciseType initialExercise;
  final Future<void> Function(ExerciseType primaryExercise) onComplete;
  final Future<void> Function() onSkip;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late ExerciseType _selected = widget.initialExercise;
  bool _busy = false;

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
                                  () => widget.onComplete(_selected),
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
