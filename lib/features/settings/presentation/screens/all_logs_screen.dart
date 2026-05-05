import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_gtg/core/ads/gtg_banner_ad.dart';
import 'package:project_gtg/core/date_utils.dart';
import 'package:project_gtg/core/l10n/gtg_date_formatters.dart';
import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/ui/gtg_ui.dart';
import 'package:project_gtg/features/workout/presentation/workout_log_row.dart';
import 'package:project_gtg/features/workout/state/workout_stats_providers.dart';
import 'package:project_gtg/l10n/app_localizations.dart';

abstract final class _AllLogsPolicy {
  static const EdgeInsets screenPadding = EdgeInsets.fromLTRB(
    GtgUi.screenHorizontalPadding,
    GtgUi.screenTopPadding,
    GtgUi.screenHorizontalPadding,
    GtgUi.screenBottomPadding + 4,
  );

  static const EdgeInsets bannerPadding = EdgeInsets.fromLTRB(
    GtgUi.screenHorizontalPadding,
    0,
    GtgUi.screenHorizontalPadding,
    10,
  );
}

class AllLogsScreen extends ConsumerWidget {
  const AllLogsScreen({super.key});

  /// Builds grouped workout history while keeping empty-state and ad layout stable.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sortedLogs = ref.watch(sortedWorkoutLogsProvider);

    if (sortedLogs.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.allLogsTitle)),
        bottomNavigationBar: const GtgBannerAd(
          padding: _AllLogsPolicy.bannerPadding,
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: _AllLogsPolicy.screenPadding,
          children: <Widget>[
            GtgInfoBanner(
              icon: Icons.timeline_rounded,
              message: l10n.allLogsSubtitle,
            ),
            const SizedBox(height: GtgUi.primarySectionSpacing),
            GtgEmptyState(
              message: l10n.noLogsHintHome,
              icon: Icons.list_alt_rounded,
            ),
          ],
        ),
      );
    }

    final sections = _groupLogsByDay(sortedLogs);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.allLogsTitle)),
      bottomNavigationBar: const GtgBannerAd(
        padding: _AllLogsPolicy.bannerPadding,
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: _AllLogsPolicy.screenPadding,
        itemCount: sections.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(
                bottom: GtgUi.primarySectionSpacing,
              ),
              child: GtgInfoBanner(
                icon: Icons.timeline_rounded,
                message: l10n.allLogsSubtitle,
              ),
            );
          }

          final sectionIndex = index - 1;
          final section = sections[sectionIndex];
          final isLast = sectionIndex == sections.length - 1;

          return Padding(
            padding: EdgeInsets.only(
              bottom: isLast ? 0 : GtgUi.primarySectionSpacing,
            ),
            child: _DaySectionCard(section: section),
          );
        },
      ),
    );
  }

  /// Groups logs by calendar day so the list stays stable and scannable.
  List<_DaySection> _groupLogsByDay(List<ExerciseLog> sortedLogs) {
    final groups = <DateTime, List<ExerciseLog>>{};
    for (final log in sortedLogs) {
      final day = startOfDay(log.timestamp);
      (groups[day] ??= <ExerciseLog>[]).add(log);
    }

    return groups.entries
        .map(
          (entry) => _DaySection(
            day: entry.key,
            logs: List<ExerciseLog>.unmodifiable(entry.value),
          ),
        )
        .toList(growable: false);
  }
}

class _DaySection {
  const _DaySection({required this.day, required this.logs});

  final DateTime day;
  final List<ExerciseLog> logs;
}

class _DaySectionCard extends StatelessWidget {
  const _DaySectionCard({required this.section});

  final _DaySection section;

  /// Builds one day section with header summary and its grouped log rows.
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _DayHeader(day: section.day, logs: section.logs),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              children: <Widget>[
                for (var index = 0; index < section.logs.length; index++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: index == section.logs.length - 1
                          ? 0
                          : GtgUi.secondarySectionSpacing,
                    ),
                    child: WorkoutLogRow(log: section.logs[index]),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day, required this.logs});

  final DateTime day;
  final List<ExerciseLog> logs;

  /// Builds the day heading and moves the total pill under the title when needed.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final total = logs.fold<int>(0, (sum, log) => sum + log.reps);
    final label = GtgDateFormatters.monthDayWithWeekday(day, l10n.localeName);

    final totalBadge = DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(GtgUi.pillRadius),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          l10n.repsWithUnit(total),
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final isCompact = GtgUi.useCompactLayout(
          width: constraints.maxWidth,
          textScale: textScale,
          widthThreshold: GtgUi.collapsedNavigationWidth,
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              totalBadge,
            ],
          );
        }

        return Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            totalBadge,
          ],
        );
      },
    );
  }
}
