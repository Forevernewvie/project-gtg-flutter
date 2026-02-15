import 'package:flutter/material.dart';

import '../../core/gtg_gradients.dart';
import '../../core/models/exercise_type.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/exercise_type_l10n.dart';

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: GtgGradients.pageBackground),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        l10n.appTitle,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () async {
                              setState(() => _busy = true);
                              await widget.onSkip();
                              if (!context.mounted) return;
                              setState(() => _busy = false);
                            },
                      child: Text(l10n.onboardingLater),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.onboardingSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black.withValues(alpha: 0.60),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.onboardingQuestion,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.onboardingHint,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black.withValues(alpha: 0.60),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _PickCard(
                  type: ExerciseType.pushUp,
                  selected: _selected == ExerciseType.pushUp,
                  onTap: _busy
                      ? null
                      : () => setState(() => _selected = ExerciseType.pushUp),
                  accent: const Color(0xFF1B77D3),
                  subtitle: l10n.onboardingPushUpSubtitle,
                ),
                const SizedBox(height: 10),
                _PickCard(
                  type: ExerciseType.pullUp,
                  selected: _selected == ExerciseType.pullUp,
                  onTap: _busy
                      ? null
                      : () => setState(() => _selected = ExerciseType.pullUp),
                  accent: const Color(0xFF26A07A),
                  subtitle: l10n.onboardingPullUpSubtitle,
                ),
                const SizedBox(height: 10),
                _PickCard(
                  type: ExerciseType.dips,
                  selected: _selected == ExerciseType.dips,
                  onTap: _busy
                      ? null
                      : () => setState(() => _selected = ExerciseType.dips),
                  accent: const Color(0xFFF0772C),
                  subtitle: l10n.onboardingDipsSubtitle,
                ),
                const Spacer(),
                if (_busy) ...<Widget>[
                  const LinearProgressIndicator(minHeight: 3),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _busy
                        ? null
                        : () async {
                            setState(() => _busy = true);
                            await widget.onComplete(_selected);
                            if (!context.mounted) return;
                            setState(() => _busy = false);
                          },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(l10n.onboardingNext),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final borderColor = selected
        ? accent
        : Colors.black.withValues(alpha: 0.08);
    final bg = selected ? accent.withValues(alpha: 0.08) : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: <Widget>[
              Container(
                width: 6,
                height: 40,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      type.label(l10n),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black.withValues(alpha: 0.60),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: selected ? accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selected
                        ? accent
                        : Colors.black.withValues(alpha: 0.20),
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
