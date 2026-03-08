import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/env.dart';
import '../core/gtg_gradients.dart';
import '../l10n/app_localizations.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/state/user_preferences_controller.dart';
import '../features/reminders/state/reminder_controller.dart';
import 'root_overlays_policy.dart';

class RootOverlays extends ConsumerStatefulWidget {
  const RootOverlays({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<RootOverlays> createState() => _RootOverlaysState();
}

class _RootOverlaysState extends ConsumerState<RootOverlays>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _showSplash = true;

  /// Captures environment flags once so UI and lifecycle checks stay consistent.
  RootOverlayEnvironment get _environment => RootOverlayEnvironment(
    isTestRuntime: Env.isTestRuntime,
    uiTesting: Env.uiTesting,
    smokeScreenshots: Env.smokeScreenshots,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final allowSplash = RootOverlaysPolicy.shouldShowSplash(_environment);
    if (!allowSplash) {
      _showSplash = false;
      return;
    }

    _timer = Timer(RootOverlaysPolicy.splashDuration, () {
      if (!mounted) return;
      setState(() => _showSplash = false);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!RootOverlaysPolicy.shouldSyncRemindersOnLifecycle(
      environment: _environment,
      state: state,
    )) {
      return;
    }

    // Keep reminders in sync when users change permissions in iOS Settings.
    unawaited(ref.read(reminderControllerProvider.notifier).onAppForeground());
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
    final shouldShowOnboarding = RootOverlaysPolicy.shouldShowOnboarding(
      environment: _environment,
      showSplash: _showSplash,
      preferences: prefs,
    );

    return Stack(
      children: <Widget>[
        widget.child,
        if (_showSplash) ...<Widget>[_InAppSplash(onTap: _skipSplash)],
        if (shouldShowOnboarding) ...<Widget>[
          Builder(
            builder: (context) {
              final onboardingPrefs = prefs!;
              return OnboardingScreen(
                initialExercise: onboardingPrefs.primaryExercise,
                onSkip: () async {
                  await ref
                      .read(userPreferencesControllerProvider.notifier)
                      .completeOnboarding(onboardingPrefs.primaryExercise);
                },
                onComplete: (primary) async {
                  await ref
                      .read(userPreferencesControllerProvider.notifier)
                      .completeOnboarding(primary);
                },
              );
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
    final l10n = AppLocalizations.of(context)!;

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: GtgGradients.hero(Theme.of(context).brightness),
          ),
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
                    l10n.splashTapToSkip,
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
