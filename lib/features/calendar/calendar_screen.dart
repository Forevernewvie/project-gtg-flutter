import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/date_utils.dart';
import '../../core/gtg_colors.dart';
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

    final logs = ref.watch(workoutLogsProvider);
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
    ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
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
                          color: Colors.black.withValues(alpha: 0.60),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(onPressed: _jumpToToday, child: Text(l10n.today)),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            GtgDateFormatters.monthLabel(
                              _visibleMonth,
                              l10n.localeName,
                            ),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
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
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        _MiniStatChip(
                          label: l10n.monthTotalLabel,
                          value: l10n.repsWithUnit(monthSum),
                        ),
                        const SizedBox(width: 10),
                        _MiniStatChip(
                          label: l10n.activeDaysLabel,
                          value: l10n.daysWithUnit(activeDays),
                        ),
                      ],
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
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
                    const SizedBox(height: 4),
                    Text(
                      l10n.dayTotal(selectedSum),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black.withValues(alpha: 0.60),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        _MiniStatChip(
                          label: ExerciseType.pushUp.label(l10n),
                          value: '${selectedTotals[ExerciseType.pushUp] ?? 0}',
                        ),
                        const SizedBox(width: 10),
                        _MiniStatChip(
                          label: ExerciseType.pullUp.label(l10n),
                          value: '${selectedTotals[ExerciseType.pullUp] ?? 0}',
                        ),
                        const SizedBox(width: 10),
                        _MiniStatChip(
                          label: ExerciseType.dips.label(l10n),
                          value: '${selectedTotals[ExerciseType.dips] ?? 0}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (selectedSorted.isEmpty)
                      Text(
                        l10n.noLogsForDay,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black.withValues(alpha: 0.60),
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
    return Row(
      children: <Widget>[
        for (final label in labels)
          Expanded(
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.black.withValues(alpha: 0.60),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MonthHeatmap extends StatelessWidget {
  const _MonthHeatmap({
    required this.monthStart,
    required this.dayTotals,
    required this.maxTotal,
    required this.selectedDay,
    required this.onSelect,
    required this.accent,
  });

  final DateTime monthStart;
  final Map<DateTime, int> dayTotals;
  final int maxTotal;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelect;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final cells = buildMonthGrid(monthStart);

    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 8.0;
        final cellSize = (constraints.maxWidth - gap * 6) / 7;

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

            final bg = _heatColor(total, maxTotal, accent);
            final border = isSelected
                ? Border.all(color: accent, width: 2)
                : Border.all(color: Colors.black.withValues(alpha: 0.06));

            final textColor = total == 0 ? GtgColors.textPrimary : Colors.white;

            return SizedBox(
              width: cellSize,
              height: cellSize,
              child: InkWell(
                key: Key('calendar.day.${ymd(date)}'),
                borderRadius: BorderRadius.circular(14),
                onTap: () => onSelect(date),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(14),
                    border: border,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w900,
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

  Color _heatColor(int total, int max, Color accent) {
    if (total <= 0 || max <= 0) {
      return Colors.black.withValues(alpha: 0.03);
    }

    final ratio = total / max;
    final alpha = switch (ratio) {
      <= 0.25 => 0.40,
      <= 0.50 => 0.58,
      <= 0.75 => 0.74,
      _ => 0.92,
    };

    return accent.withValues(alpha: alpha);
  }
}

class _MiniStatChip extends StatelessWidget {
  const _MiniStatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.black.withValues(alpha: 0.60),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
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

    final time = TimeOfDay.fromDateTime(log.timestamp);
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Row(
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
                      color: Colors.black.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              l10n.repsWithUnit(log.reps),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}
