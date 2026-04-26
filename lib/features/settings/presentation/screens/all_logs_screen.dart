import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_gtg/core/ads/gtg_banner_ad.dart';
import 'package:project_gtg/core/date_utils.dart';
import 'package:project_gtg/core/l10n/gtg_date_formatters.dart';
import 'package:project_gtg/core/models/exercise_log.dart';
import 'package:project_gtg/core/ui/gtg_ui.dart';
import 'package:project_gtg/features/workout/state/workout_stats_providers.dart';
import 'package:project_gtg/l10n/app_localizations.dart';
import 'package:project_gtg/l10n/exercise_type_l10n.dart';

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
            _AllLogsIntro(subtitle: l10n.allLogsSubtitle),
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
              child: _AllLogsIntro(subtitle: l10n.allLogsSubtitle),
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

class _AllLogsIntro extends StatelessWidget {
  const _AllLogsIntro({required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          colorScheme.primary.withValues(alpha: 0.08),
          colorScheme.surface,
        ),
        borderRadius: BorderRadius.circular(GtgUi.cardRadius),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(GtgUi.controlRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.timeline_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: GtgUi.controlSpacing),
            Expanded(
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                    child: _LogRow(log: section.logs[index]),
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

class _LogRow extends StatelessWidget {
  const _LogRow({required this.log});

  final ExerciseLog log;

  /// Builds a responsive history row that stacks value content on constrained layouts.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final time = TimeOfDay.fromDateTime(log.timestamp);
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');

    final valueText = Text(
      l10n.repsWithUnit(log.reps),
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final textScale = MediaQuery.textScalerOf(context).scale(1);
            final isCompact = GtgUi.useCompactLayout(
              width: constraints.maxWidth,
              textScale: textScale,
              widthThreshold: GtgUi.compactDetailWidth,
              textScaleThreshold: GtgUi.accessibilityTextScale,
            );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    log.type.label(l10n),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$hh:$mm',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  valueText,
                ],
              );
            }

            return Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        log.type.label(l10n),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$hh:$mm',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                valueText,
              ],
            );
          },
        ),
      ),
    );
  }
}
