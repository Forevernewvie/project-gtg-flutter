import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/date_utils.dart';
import '../../core/l10n/gtg_date_formatters.dart';
import '../../core/models/exercise_log.dart';
import '../../core/models/exercise_type.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/exercise_type_l10n.dart';
import '../workout/state/workout_stats_providers.dart';
import 'calendar_utils.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _visibleMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = ref.read(clockProvider).now();
    _visibleMonth = startOfMonth(now);
    _selectedDay = startOfDay(now);
  }

  void _jumpToToday() {
    final now = ref.read(clockProvider).now();
    setState(() {
      _visibleMonth = startOfMonth(now);
      _selectedDay = startOfDay(now);
    });
  }

  void _goToMonth(int delta) {
    setState(() {
      _visibleMonth = addMonths(_visibleMonth, delta);
      _selectedDay = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final today = startOfDay(ref.read(clockProvider).now());

    final logs = ref.watch(sortedWorkoutLogsProvider);
    final service = ref.watch(workoutAnalyticsServiceProvider);

    final monthStart = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final monthEnd = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 1);

    final dayTotals = <DateTime, int>{};
    for (final log in logs) {
      if (isInRange(log.timestamp, monthStart, monthEnd)) {
        final dayKey = startOfDay(log.timestamp);
        dayTotals[dayKey] = (dayTotals[dayKey] ?? 0) + log.reps;
      }
    }

    final maxTotal = dayTotals.values.fold<int>(
      0,
      (max, v) => v > max ? v : max,
    );
    final monthSum = dayTotals.values.fold<int>(
      0,
      (sum, v) => sum + (v > 0 ? v : 0),
    );
    final activeDays = dayTotals.entries.where((e) => e.value > 0).length;

    final selectedDay =
        (_selectedDay.isBefore(monthStart) || !_selectedDay.isBefore(monthEnd))
        ? DateTime(_visibleMonth.year, _visibleMonth.month, 1)
        : _selectedDay;

    final selectedTotals = service.totalsForDay(logs, selectedDay);
    final selectedSum = service.sumTotals(selectedTotals);
    final selectedSorted = <ExerciseLog>[
      for (final l in logs)
        if (isSameDay(l.timestamp, selectedDay)) l,
    ];

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
                final useCompactHeader =
                    constraints.maxWidth < 360 || textScale >= 1.25;
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
                        final useCompactHeader =
                            constraints.maxWidth < 360 || textScale >= 1.25;
                        final monthLabel = Text(
                          GtgDateFormatters.monthLabel(
                            _visibleMonth,
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
                            value: l10n.repsWithUnit(monthSum),
                            icon: Icons.bar_chart_rounded,
                            accent: colorScheme.primary,
                          ),
                          _MiniStatChip(
                            label: l10n.activeDaysLabel,
                            value: l10n.daysWithUnit(activeDays),
                            icon: Icons.local_fire_department_rounded,
                            accent: colorScheme.secondary,
                          ),
                        ];

                        if (constraints.maxWidth < 360) {
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
                      monthStart: monthStart,
                      dayTotals: dayTotals,
                      maxTotal: maxTotal,
                      selectedDay: selectedDay,
                      today: today,
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
                        selectedDay,
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
                            final useCompactSummary =
                                constraints.maxWidth < 300 || textScale >= 1.4;
                            final summaryText = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  l10n.dayTotal(selectedSum),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  l10n.repsWithUnit(selectedSum),
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
                                '${selectedTotals[ExerciseType.pushUp] ?? 0}',
                            icon: _exerciseIcon(ExerciseType.pushUp),
                            accent: _exerciseAccent(
                              context,
                              ExerciseType.pushUp,
                            ),
                          ),
                          _MiniStatChip(
                            label: ExerciseType.pullUp.label(l10n),
                            value:
                                '${selectedTotals[ExerciseType.pullUp] ?? 0}',
                            icon: _exerciseIcon(ExerciseType.pullUp),
                            accent: _exerciseAccent(
                              context,
                              ExerciseType.pullUp,
                            ),
                          ),
                          _MiniStatChip(
                            label: ExerciseType.dips.label(l10n),
                            value: '${selectedTotals[ExerciseType.dips] ?? 0}',
                            icon: _exerciseIcon(ExerciseType.dips),
                            accent: _exerciseAccent(context, ExerciseType.dips),
                          ),
                        ];

                        if (constraints.maxWidth < 420) {
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
                    if (selectedSorted.isEmpty)
                      Text(
                        l10n.noLogsForDay,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      ...selectedSorted.map(
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

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final useCompactLabels = constraints.maxWidth < 360 || textScale >= 1.3;

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

  @override
  Widget build(BuildContext context) {
    final cells = buildMonthGrid(monthStart);

    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 8.0;
        final cellSize = (constraints.maxWidth - gap * 6) / 7;
        final useCompactCell = cellSize < 30;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: gap,
            mainAxisSpacing: gap,
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
                ? Border.all(color: accent, width: 2)
                : isToday
                ? Border.all(color: accent.withValues(alpha: 0.50), width: 1.2)
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

class _DayLogRow extends StatelessWidget {
  const _DayLogRow({required this.log});

  final ExerciseLog log;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accent = _exerciseAccent(context, log.type);
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
            final useCompactRow =
                constraints.maxWidth < 280 || textScale >= 1.4;
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
                      _exerciseIcon(log.type),
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

Color _exerciseAccent(BuildContext context, ExerciseType type) {
  final colorScheme = Theme.of(context).colorScheme;
  return switch (type) {
    ExerciseType.pushUp => colorScheme.primary,
    ExerciseType.pullUp => colorScheme.secondary,
    ExerciseType.dips => const Color(0xFFF59E0B),
  };
}

IconData _exerciseIcon(ExerciseType type) {
  return switch (type) {
    ExerciseType.pushUp => Icons.fitness_center_rounded,
    ExerciseType.pullUp => Icons.vertical_align_top_rounded,
    ExerciseType.dips => Icons.workspace_premium_rounded,
  };
}
