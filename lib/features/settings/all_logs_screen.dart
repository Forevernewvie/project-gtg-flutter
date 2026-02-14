import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_utils.dart';
import '../../core/models/exercise_log.dart';
import '../../core/models/exercise_type.dart';
import '../workout/state/workout_stats_providers.dart';

class AllLogsScreen extends ConsumerWidget {
  const AllLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(workoutLogsProvider);
    final sorted = <ExerciseLog>[...logs]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final groups = <DateTime, List<ExerciseLog>>{};
    for (final log in sorted) {
      final day = startOfDay(log.timestamp);
      groups.putIfAbsent(day, () => <ExerciseLog>[]).add(log);
    }

    final days = groups.keys.toList(growable: false)
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(title: const Text('전체 기록')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
        children: <Widget>[
          if (sorted.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Text(
                  '기록이 아직 없습니다. 홈에서 한 세트만 기록해보세요.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black.withValues(alpha: 0.60),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            for (final day in days) ...<Widget>[
              _DayHeader(day: day, logs: groups[day] ?? const <ExerciseLog>[]),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    children: <Widget>[
                      for (final log in groups[day] ?? const <ExerciseLog>[])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _LogRow(log: log),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day, required this.logs});

  final DateTime day;
  final List<ExerciseLog> logs;

  @override
  Widget build(BuildContext context) {
    final total = logs.fold<int>(0, (sum, log) => sum + log.reps);
    final label = _formatDateKo(day);

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
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              '$total회',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateKo(DateTime date) {
    const weekdays = <String>['일', '월', '화', '수', '목', '금', '토'];
    final weekday = weekdays[date.weekday % 7];
    return '${date.month}월 ${date.day}일 ($weekday)';
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.log});

  final ExerciseLog log;

  @override
  Widget build(BuildContext context) {
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
                    log.type.labelKo,
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
              '${log.reps}회',
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
