import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/clock.dart';
import '../core/env.dart';
import '../core/external_link_launcher.dart';
import '../core/gtg_gradients.dart';
import '../core/models/exercise_type.dart';
import '../core/models/user_preferences.dart';
import '../l10n/app_localizations.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/onboarding/state/user_preferences_controller.dart';
import '../features/reminders/state/reminder_controller.dart';
import '../features/update/models/app_update_info.dart';
import '../features/update/services/app_update_checker.dart';
import 'root_overlays_policy.dart';

class RootOverlays extends ConsumerStatefulWidget {
  const RootOverlays({
    super.key,
    required this.child,
    this.environmentOverride,
  });

  final Widget child;
  final RootOverlayEnvironment? environmentOverride;

  @override
  ConsumerState<RootOverlays> createState() => _RootOverlaysState();
}

class _RootOverlaysState extends ConsumerState<RootOverlays>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _showSplash = true;
  bool _overlayChecksActivated = false;
  bool _updateCheckScheduled = false;
  bool _updatePromptShown = false;

  /// Captures environment flags once so UI and lifecycle checks stay consistent.
  RootOverlayEnvironment get _environment =>
      widget.environmentOverride ??
      RootOverlayEnvironment(
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
    } else {
      _timer = Timer(RootOverlaysPolicy.splashDuration, () {
        if (!mounted) return;
        setState(() => _showSplash = false);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _overlayChecksActivated = true);
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
    final prefsAsync = !_overlayChecksActivated || _showSplash
        ? null
        : ref.watch(userPreferencesControllerProvider);
    final prefs = prefsAsync?.asData?.value;
    final prefsReady = prefsAsync?.hasValue ?? false;
    final shouldShowOnboarding = RootOverlaysPolicy.shouldShowOnboarding(
      environment: _environment,
      showSplash: _showSplash,
      preferences: prefs,
    );

    if (!_showSplash && prefsReady && !shouldShowOnboarding) {
      _scheduleUpdateCheck(context);
    }

    return Stack(
      children: <Widget>[
        widget.child,
        if (_showSplash) ...<Widget>[_InAppSplash(onTap: _skipSplash)],
        if (shouldShowOnboarding)
          _OnboardingRootOverlay(
            preferences: prefs!,
            completeOnboarding:
                ({
                  required primaryExercise,
                  required primaryExerciseMaxReps,
                  required primaryExerciseLastMaxTestedAt,
                }) {
                  return ref
                      .read(userPreferencesControllerProvider.notifier)
                      .completeOnboarding(
                        primaryExercise,
                        primaryExerciseMaxReps: primaryExerciseMaxReps,
                        primaryExerciseLastMaxTestedAt:
                            primaryExerciseLastMaxTestedAt,
                      );
                },
            now: () => ref.read(clockProvider).now(),
          ),
      ],
    );
  }

  void _scheduleUpdateCheck(BuildContext context) {
    if (_updateCheckScheduled || _updatePromptShown) return;
    if (_environment.isTestRuntime || _environment.uiTesting) return;

    _updateCheckScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final update = await ref.read(appUpdateCheckerProvider).checkForUpdate();
      if (!mounted || update == null || _updatePromptShown) return;

      _updatePromptShown = true;
      await _showUpdatePrompt(update);
    });
  }

  Future<void> _showUpdatePrompt(AppUpdateInfo update) async {
    if (!mounted) return;

    final dialogContext = context;
    final l10n = AppLocalizations.of(dialogContext)!;

    await showDialog<void>(
      context: dialogContext,
      barrierDismissible: !update.forceUpdate,
      builder: (overlayContext) {
        return AlertDialog(
          title: Text(l10n.appUpdateTitle),
          content: Text(
            update.message.isEmpty
                ? l10n.appUpdateBody(update.latestVersionName)
                : update.message,
          ),
          actions: <Widget>[
            if (!update.forceUpdate)
              TextButton(
                onPressed: () => Navigator.of(overlayContext).pop(),
                child: Text(l10n.appUpdateLater),
              ),
            FilledButton(
              onPressed: () async {
                final uri = Uri.tryParse(update.storeUrl);
                if (uri != null) {
                  await ref.read(externalLinkLauncherProvider).launch(uri);
                }
                if (!overlayContext.mounted || update.forceUpdate) return;
                Navigator.of(overlayContext).pop();
              },
              child: Text(l10n.appUpdateNow),
            ),
          ],
        );
      },
    );
  }
}

class _OnboardingRootOverlay extends StatelessWidget {
  const _OnboardingRootOverlay({
    required this.preferences,
    required this.completeOnboarding,
    required this.now,
  });

  final UserPreferences preferences;
  final Future<void> Function({
    required ExerciseType primaryExercise,
    required int primaryExerciseMaxReps,
    required DateTime? primaryExerciseLastMaxTestedAt,
  })
  completeOnboarding;
  final DateTime Function() now;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Overlay(
        initialEntries: <OverlayEntry>[
          OverlayEntry(
            builder: (context) {
              return OnboardingScreen(
                initialExercise: preferences.primaryExercise,
                initialMaxReps: preferences.primaryExerciseMaxReps,
                onSkip: () {
                  return completeOnboarding(
                    primaryExercise: preferences.primaryExercise,
                    primaryExerciseMaxReps: preferences.primaryExerciseMaxReps,
                    primaryExerciseLastMaxTestedAt:
                        preferences.primaryExerciseLastMaxTestedAt,
                  );
                },
                onComplete:
                    ({
                      required primaryExercise,
                      required primaryExerciseMaxReps,
                    }) {
                      return completeOnboarding(
                        primaryExercise: primaryExercise,
                        primaryExerciseMaxReps: primaryExerciseMaxReps,
                        primaryExerciseLastMaxTestedAt:
                            primaryExerciseMaxReps > 0 ? now() : null,
                      );
                    },
              );
            },
          ),
        ],
      ),
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
