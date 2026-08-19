import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_gtg/core/gtg_gradients.dart';
import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/models/exercise_type.dart';
import 'package:project_gtg/core/ui/gtg_ui.dart';
import 'package:project_gtg/features/coaching/gtg_coach_policy.dart';
import 'package:project_gtg/features/coaching/models/gtg_coach_recommendation.dart';
import 'package:project_gtg/features/coaching/state/gtg_coach_providers.dart';
import 'package:project_gtg/features/reminders/reminder_optimization_policy.dart';
import 'package:project_gtg/features/reminders/reminder_ui_policy.dart';
import 'package:project_gtg/features/reminders/state/reminder_providers.dart';
import 'package:project_gtg/features/workout/presentation/exercise_ui_style.dart';
import 'package:project_gtg/features/workout/presentation/workout_log_row.dart';
import 'package:project_gtg/features/workout/state/workout_controller.dart';
import 'package:project_gtg/features/workout/state/workout_stats_providers.dart';
import 'package:project_gtg/l10n/app_localizations.dart';
import 'package:project_gtg/l10n/exercise_type_l10n.dart';
import '../widgets/gtg_info_bottom_sheet.dart';
import 'package:project_gtg/core/ui/gtg_neon_circular_progress.dart';

part 'dashboard_hero_section.dart';
part 'dashboard_coach_section.dart';
part 'dashboard_quick_log_section.dart';
part 'dashboard_recent_logs_section.dart';

/// Collects dashboard-specific layout and input guard rails in one place.
abstract final class _DashboardPolicy {
  static const double heroRadius = 28;
  static const int minQuickLogReps = 1;
  static const int maxQuickLogReps = 999;
  static const double startupPlaceholderHeight = 188;
  static const Map<ExerciseType, int> defaultDraftReps = <ExerciseType, int>{
    ExerciseType.pushUp: 10,
    ExerciseType.pullUp: 5,
    ExerciseType.dips: 8,
  };
}

/// Renders the home dashboard with hero metrics, quick logging, and recent history.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _dataActivated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _dataActivated = true);
    });
  }

  /// Builds the dashboard sections inside one vertically scrolling surface.
  @override
  Widget build(BuildContext context) {
    if (!_dataActivated) {
      return const _DashboardStartupPlaceholder();
    }

    final reminderSuggestion = ref.watch(
      reminderOptimizationSuggestionProvider,
    );

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              GtgUi.screenHorizontalPadding,
              GtgUi.screenTopPadding,
              GtgUi.screenHorizontalPadding,
              GtgUi.primarySectionSpacing,
            ),
            child: const _HeroCard(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              GtgUi.screenHorizontalPadding,
              0,
              GtgUi.screenHorizontalPadding,
              GtgUi.primarySectionSpacing,
            ),
            child: const _CoachCard(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              GtgUi.screenHorizontalPadding,
              0,
              GtgUi.screenHorizontalPadding,
              GtgUi.primarySectionSpacing,
            ),
            child: const _QuickLogCard(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              GtgUi.screenHorizontalPadding,
              0,
              GtgUi.screenHorizontalPadding,
              reminderSuggestion == null
                  ? GtgUi.screenBottomPadding + 4
                  : GtgUi.primarySectionSpacing,
            ),
            child: const _RecentLogsCard(),
          ),
        ),
        if (reminderSuggestion != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                GtgUi.screenHorizontalPadding,
                0,
                GtgUi.screenHorizontalPadding,
                GtgUi.screenBottomPadding + 4,
              ),
              child: _ReminderNudgeCard(suggestion: reminderSuggestion),
            ),
          ),
      ],
    );
  }
}

class _DashboardStartupPlaceholder extends StatelessWidget {
  const _DashboardStartupPlaceholder();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              GtgUi.screenHorizontalPadding,
              GtgUi.screenTopPadding,
              GtgUi.screenHorizontalPadding,
              GtgUi.primarySectionSpacing,
            ),
            child: const _StartupPlaceholderCard(
              height: _DashboardPolicy.startupPlaceholderHeight,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              GtgUi.screenHorizontalPadding,
              0,
              GtgUi.screenHorizontalPadding,
              GtgUi.primarySectionSpacing,
            ),
            child: const _StartupPlaceholderCard(height: 112),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              GtgUi.screenHorizontalPadding,
              0,
              GtgUi.screenHorizontalPadding,
              GtgUi.primarySectionSpacing,
            ),
            child: const _StartupPlaceholderCard(height: 260),
          ),
        ),
      ],
    );
  }
}

class _StartupPlaceholderCard extends StatelessWidget {
  const _StartupPlaceholderCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(GtgUi.cardRadius),
      ),
      child: SizedBox(
        height: height,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
