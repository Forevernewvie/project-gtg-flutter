import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/date_utils.dart';
import '../../core/l10n/gtg_date_formatters.dart';
import '../../core/models/exercise_log.dart';
import '../../core/models/exercise_type.dart';
import '../../core/ui/gtg_ui.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/exercise_type_l10n.dart';
import 'calendar_view_model.dart';
import '../workout/presentation/exercise_ui_style.dart';
import '../workout/state/workout_stats_providers.dart';
import 'calendar_utils.dart';

/// Centralizes calendar-specific layout thresholds to avoid scattered magic numbers.
abstract final class _CalendarPolicy {
  static const double heatmapGap = 8;
  static const double compactHeatmapCellSize = 30;
  static const double selectedDayBorderWidth = 2;
  static const double todayBorderWidth = 1.2;
}

/// Shows the monthly heatmap and selected-day workout details.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  /// Creates state for visible-month and selected-day interactions.
  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _visibleMonth;
  late DateTime _selectedDay;

  /// Initializes the calendar to the current month and current day.
  @override
  void initState() {
    super.initState();
    final now = ref.read(clockProvider).now();
    _visibleMonth = startOfMonth(now);
    _selectedDay = startOfDay(now);
  }

  /// Resets the calendar back to today to reduce navigation friction.
  void _jumpToToday() {
    final now = ref.read(clockProvider).now();
    setState(() {
      _visibleMonth = startOfMonth(now);
      _selectedDay = startOfDay(now);
    });
  }

  /// Moves the visible month backward or forward and snaps selection to that month.
  void _goToMonth(int delta) {
    setState(() {
      _visibleMonth = addMonths(_visibleMonth, delta);
      _selectedDay = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    });
  }

  /// Builds the full calendar screen using pre-aggregated analytics summaries.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = ref.read(clockProvider).now();
    final logs = ref.watch(sortedWorkoutLogsProvider);
    final service = ref.watch(workoutAnalyticsServiceProvider);
    final viewModel = CalendarViewModel.create(
      logs: logs,
      analyticsService: service,
      visibleMonth: _visibleMonth,
      selectedDay: _selectedDay,
      now: now,
    );

    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final textScale = MediaQuery.textScalerOf(context).scale(1);
                final useCompactHeader = GtgUi.useCompactLayout(
                  width: constraints.maxWidth,
                  textScale: textScale,
                  textScaleThreshold: GtgUi.elevatedTextScale,
                );
                final titleBlock = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.calendarTitle,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.calendarSubtitleHeatmap,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
                final todayButton = TextButton.icon(
                  onPressed: _jumpToToday,
                  icon: const Icon(Icons.my_location_rounded, size: 18),
                  label: Text(l10n.today),
                );

                if (useCompactHeader) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      titleBlock,
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: todayButton,
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child: titleBlock),
                    const SizedBox(width: 12),
                    todayButton,
                  ],
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final textScale = MediaQuery.textScalerOf(
                          context,
                        ).scale(1);
                        final useCompactHeader = GtgUi.useCompactLayout(
                          width: constraints.maxWidth,
                          textScale: textScale,
                          textScaleThreshold: GtgUi.elevatedTextScale,
                        );
                        final monthLabel = Text(
                          GtgDateFormatters.monthLabel(
                            viewModel.visibleMonth,
                            l10n.localeName,
                          ),
                          maxLines: useCompactHeader ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        );
                        final controls = DecoratedBox(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                tooltip: l10n.prevMonthTooltip,
                                onPressed: () => _goToMonth(-1),
                                icon: const Icon(Icons.chevron_left_rounded),
                              ),
                              IconButton(
                                tooltip: l10n.nextMonthTooltip,
                                onPressed: () => _goToMonth(1),
                                icon: const Icon(Icons.chevron_right_rounded),
                              ),
                            ],
                          ),
                        );

                        if (useCompactHeader) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              monthLabel,
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: controls,
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: <Widget>[
                            Expanded(child: monthLabel),
                            const SizedBox(width: 12),
                            controls,
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final chips = <Widget>[
                          _MiniStatChip(
                            label: l10n.monthTotalLabel,
                            value: l10n.repsWithUnit(
                              viewModel.monthSummary.monthSum,
                            ),
                            icon: Icons.bar_chart_rounded,
                            accent: colorScheme.primary,
                          ),
                          _MiniStatChip(
                            label: l10n.activeDaysLabel,
                            value: l10n.daysWithUnit(
                              viewModel.monthSummary.activeDays,
                            ),
                            icon: Icons.local_fire_department_rounded,
                            accent: colorScheme.secondary,
                          ),
                        ];

                        if (GtgUi.isCompactWidth(constraints.maxWidth)) {
                          return Column(
                            children: <Widget>[
                              chips[0],
                              const SizedBox(height: 10),
                              chips[1],
                            ],
                          );
                        }

                        return Row(
                          children: <Widget>[
                            Expanded(child: chips[0]),
                            const SizedBox(width: 10),
                            Expanded(child: chips[1]),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _WeekdayRow(
                      labels: GtgDateFormatters.weekdayLabelsSunFirst(
                        l10n.localeName,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _MonthHeatmap(
                      monthStart: viewModel.monthStart,
                      dayTotals: viewModel.monthSummary.dayTotals,
                      maxTotal: viewModel.monthSummary.maxTotal,
                      selectedDay: viewModel.selectedDay,
                      today: viewModel.today,
                      onSelect: (day) => setState(() => _selectedDay = day),
                      accent: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      GtgDateFormatters.monthDayWithWeekday(
                        viewModel.selectedDay,
                        l10n.localeName,
                      ),
                      key: const Key('calendar.selectedDateLabel'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.86,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final textScale = MediaQuery.textScalerOf(
                              context,
                            ).scale(1);
                            final useCompactSummary = GtgUi.useCompactLayout(
                              width: constraints.maxWidth,
                              textScale: textScale,
                              widthThreshold: GtgUi.compactDetailWidth,
                              textScaleThreshold: GtgUi.accessibilityTextScale,
                            );
                            final summaryText = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  l10n.dayTotal(
                                    viewModel.selectedSummary.totalReps,
                                  ),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  l10n.repsWithUnit(
                                    viewModel.selectedSummary.totalReps,
                                  ),
                                  maxLines: useCompactSummary ? 2 : 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                              ],
                            );
                            final summaryIcon = DecoratedBox(
                              decoration: BoxDecoration(
                                color: colorScheme.surface.withValues(
                                  alpha: 0.74,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  Icons.insights_rounded,
                                  color: colorScheme.primary,
                                  size: 24,
                                ),
                              ),
                            );

                            if (useCompactSummary) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  summaryText,
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: summaryIcon,
                                  ),
                                ],
                              );
                            }

                            return Row(
                              children: <Widget>[
                                Expanded(child: summaryText),
                                const SizedBox(width: 12),
                                summaryIcon,
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final chips = <Widget>[
                          _MiniStatChip(
                            label: ExerciseType.pushUp.label(l10n),
                            value:
                                '${viewModel.selectedSummary.totals[ExerciseType.pushUp] ?? 0}',
                            icon: ExerciseUiStyle.icon(ExerciseType.pushUp),
                            accent: ExerciseUiStyle.accent(
                              context,
                              ExerciseType.pushUp,
                            ),
                          ),
                          _MiniStatChip(
                            label: ExerciseType.pullUp.label(l10n),
                            value:
                                '${viewModel.selectedSummary.totals[ExerciseType.pullUp] ?? 0}',
                            icon: ExerciseUiStyle.icon(ExerciseType.pullUp),
                            accent: ExerciseUiStyle.accent(
                              context,
                              ExerciseType.pullUp,
                            ),
                          ),
                          _MiniStatChip(
                            label: ExerciseType.dips.label(l10n),
                            value:
                                '${viewModel.selectedSummary.totals[ExerciseType.dips] ?? 0}',
                            icon: ExerciseUiStyle.icon(ExerciseType.dips),
                            accent: ExerciseUiStyle.accent(
                              context,
                              ExerciseType.dips,
                            ),
                          ),
                        ];

                        if (GtgUi.isCompactWidth(
                          constraints.maxWidth,
                          threshold: GtgUi.compactActionWidth,
                        )) {
                          return Column(
                            children: <Widget>[
                              chips[0],
                              const SizedBox(height: 10),
                              chips[1],
                              const SizedBox(height: 10),
                              chips[2],
                            ],
                          );
                        }

                        return Row(
                          children: <Widget>[
                            Expanded(child: chips[0]),
                            const SizedBox(width: 10),
                            Expanded(child: chips[1]),
                            const SizedBox(width: 10),
                            Expanded(child: chips[2]),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    if (viewModel.selectedSummary.logs.isEmpty)
                      Text(
                        l10n.noLogsForDay,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      ...viewModel.selectedSummary.logs.map(
                        (log) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _DayLogRow(log: log),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Renders weekday labels and shortens them under tight space constraints.
class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow({required this.labels});

  final List<String> labels;

  /// Builds the weekday header above the month heatmap.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final useCompactLabels = GtgUi.useCompactLayout(
          width: constraints.maxWidth,
          textScale: textScale,
        );

        return Row(
          children: <Widget>[
            for (final label in labels)
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      useCompactLabels && label.isNotEmpty
                          ? label.substring(0, 1)
                          : label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        height: 1,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Paints the month heatmap grid and exposes tap targets for day selection.
class _MonthHeatmap extends StatelessWidget {
  const _MonthHeatmap({
    required this.monthStart,
    required this.dayTotals,
    required this.maxTotal,
    required this.selectedDay,
    required this.today,
    required this.onSelect,
    required this.accent,
  });

  final DateTime monthStart;
  final Map<DateTime, int> dayTotals;
  final int maxTotal;
  final DateTime selectedDay;
  final DateTime today;
  final ValueChanged<DateTime> onSelect;
  final Color accent;

  /// Builds an adaptive 7-column grid of day cells for the visible month.
  @override
  Widget build(BuildContext context) {
    final cells = buildMonthGrid(monthStart);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize =
            (constraints.maxWidth - _CalendarPolicy.heatmapGap * 6) / 7;
        final useCompactCell =
            cellSize < _CalendarPolicy.compactHeatmapCellSize;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: _CalendarPolicy.heatmapGap,
            mainAxisSpacing: _CalendarPolicy.heatmapGap,
            childAspectRatio: 1,
          ),
          itemCount: cells.length,
          itemBuilder: (context, index) {
            final date = cells[index];
            if (date == null) return const SizedBox.shrink();

            final key = startOfDay(date);
            final total = dayTotals[key] ?? 0;
            final isSelected = isSameDay(date, selectedDay);
            final isToday = isSameDay(date, today);
            final colorScheme = Theme.of(context).colorScheme;

            final bg = _heatColor(
              total,
              maxTotal,
              accent,
              colorScheme.surfaceContainerHigh,
            );
            final border = isSelected
                ? Border.all(
                    color: accent,
                    width: _CalendarPolicy.selectedDayBorderWidth,
                  )
                : isToday
                ? Border.all(
                    color: accent.withValues(alpha: 0.50),
                    width: _CalendarPolicy.todayBorderWidth,
                  )
                : Border.all(color: colorScheme.outlineVariant);

            final textColor = total == 0 ? colorScheme.onSurface : Colors.white;

            return SizedBox(
              width: cellSize,
              height: cellSize,
              child: Semantics(
                button: true,
                selected: isSelected,
                child: InkWell(
                  key: Key('calendar.day.${ymd(date)}'),
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onSelect(date),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(16),
                      border: border,
                      boxShadow: isSelected
                          ? <BoxShadow>[
                              BoxShadow(
                                color: accent.withValues(alpha: 0.22),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: cellSize - 8,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${date.day}',
                                style:
                                    (useCompactCell
                                            ? Theme.of(
                                                context,
                                              ).textTheme.labelSmall
                                            : Theme.of(
                                                context,
                                              ).textTheme.labelMedium)
                                        ?.copyWith(
                                          color: textColor,
                                          fontWeight: FontWeight.w900,
                                          fontSize: useCompactCell ? 10 : null,
                                          height: 1,
                                        ),
                              ),
                            ),
                          ),
                          if (total > 0 && !useCompactCell) ...<Widget>[
                            const SizedBox(height: 2),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.90),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const SizedBox(width: 4, height: 4),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Maps one day total to the heatmap fill color intensity.
  Color _heatColor(int total, int max, Color accent, Color baseColor) {
    if (total <= 0 || max <= 0) {
      return baseColor;
    }

    final ratio = total / max;
    final amount = switch (ratio) {
      <= 0.25 => 0.28,
      <= 0.50 => 0.46,
      <= 0.75 => 0.66,
      _ => 0.86,
    };

    return Color.lerp(baseColor, accent, amount) ?? accent;
  }
}

/// Shows one compact stat chip inside the month or day summary area.
class _MiniStatChip extends StatelessWidget {
  const _MiniStatChip({
    required this.label,
    required this.value,
    this.icon,
    this.accent,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? accent;

  /// Builds a labeled stat chip with optional accent icon.
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = accent ?? colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          accentColor.withValues(alpha: 0.08),
          colorScheme.surface,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: <Widget>[
            if (icon != null) ...<Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(icon, color: accentColor, size: 18),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders one selected-day log entry with responsive reps placement.
class _DayLogRow extends StatelessWidget {
  const _DayLogRow({required this.log});

  final ExerciseLog log;

  /// Builds the day detail row and stacks the pill when accessibility needs more width.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accent = ExerciseUiStyle.accent(context, log.type);
    final colorScheme = Theme.of(context).colorScheme;

    final time = TimeOfDay.fromDateTime(log.timestamp);
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          accent.withValues(alpha: 0.08),
          colorScheme.surface,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final textScale = MediaQuery.textScalerOf(context).scale(1);
            final useCompactRow = GtgUi.useCompactLayout(
              width: constraints.maxWidth,
              textScale: textScale,
              widthThreshold: 280,
              textScaleThreshold: GtgUi.accessibilityTextScale,
            );
            final leading = Row(
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      ExerciseUiStyle.icon(log.type),
                      color: accent,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
            final repsPill = DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.86),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Text(
                  l10n.repsWithUnit(log.reps),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            );

            if (useCompactRow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  leading,
                  const SizedBox(height: 10),
                  Align(alignment: Alignment.centerRight, child: repsPill),
                ],
              );
            }

            return Row(
              children: <Widget>[
                Expanded(child: leading),
                const SizedBox(width: 12),
                repsPill,
              ],
            );
          },
        ),
      ),
    );
  }
}
