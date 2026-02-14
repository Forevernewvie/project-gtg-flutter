import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/env.dart';
import '../core/gtg_gradients.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/state/user_preferences_controller.dart';

class RootOverlays extends ConsumerStatefulWidget {
  const RootOverlays({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<RootOverlays> createState() => _RootOverlaysState();
}

class _RootOverlaysState extends ConsumerState<RootOverlays> {
  Timer? _timer;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();

    final allowSplash =
        !Env.isTestRuntime && (!Env.uiTesting || Env.smokeScreenshots);
    if (!allowSplash) {
      _showSplash = false;
      return;
    }

    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _showSplash = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _skipSplash() {
    if (!_showSplash) return;
    _timer?.cancel();
    setState(() => _showSplash = false);
  }

  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(userPreferencesControllerProvider);
    final prefs = prefsAsync.asData?.value;

    final shouldShowOnboarding =
        !_showSplash &&
        !Env.isTestRuntime &&
        !Env.uiTesting &&
        !Env.smokeScreenshots &&
        (prefs != null && !prefs.hasCompletedOnboarding);

    return Stack(
      children: <Widget>[
        widget.child,
        if (_showSplash) ...<Widget>[_InAppSplash(onTap: _skipSplash)],
        if (shouldShowOnboarding) ...<Widget>[
          OnboardingScreen(
            initialExercise: prefs.primaryExercise,
            onSkip: () async {
              await ref
                  .read(userPreferencesControllerProvider.notifier)
                  .completeOnboarding(prefs.primaryExercise);
            },
            onComplete: (primary) async {
              await ref
                  .read(userPreferencesControllerProvider.notifier)
                  .completeOnboarding(primary);
            },
          ),
        ],
      ],
    );
  }
}

class _InAppSplash extends StatelessWidget {
  const _InAppSplash({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: GtgGradients.hero),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'GTG',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'PUSH  ·  PULL  ·  DIPS',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '탭하여 스킵',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
