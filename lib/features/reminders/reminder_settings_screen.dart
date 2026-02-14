import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/reminder_settings.dart';
import '../../core/gtg_colors.dart';
import 'state/reminder_controller.dart';
import 'state/reminder_providers.dart';

class ReminderSettingsScreen extends ConsumerStatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  ConsumerState<ReminderSettingsScreen> createState() =>
      _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState
    extends ConsumerState<ReminderSettingsScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final asyncSettings = ref.watch(reminderControllerProvider);
    final settings = asyncSettings.asData?.value ?? ReminderSettings.defaults;
    final plannedTimes = ref.watch(plannedReminderTimesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('리마인더')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
        children: <Widget>[
          Text(
            '조용하게, 꾸준히',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            '반복 주기를 설정하면 오늘 남은 시간만큼만 예약합니다.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black.withValues(alpha: 0.60),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '리마인더 켜기',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              settings.enabled
                                  ? '오늘 남은 알림 ${plannedTimes.length}개 예약됨'
                                  : '원할 때만 켜고 끌 수 있어요.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.black.withValues(alpha: 0.60),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        key: const Key('reminders.enabledSwitch'),
                        value: settings.enabled,
                        onChanged: _busy
                            ? null
                            : (value) async {
                                setState(() => _busy = true);
                                final ok = await ref
                                    .read(reminderControllerProvider.notifier)
                                    .setEnabled(value);
                                if (!context.mounted) return;
                                setState(() => _busy = false);
                                if (!ok) _showPermissionDeniedSnackBar(context);
                              },
                      ),
                    ],
                  ),
                  if (_busy) ...<Widget>[
                    const SizedBox(height: 10),
                    const LinearProgressIndicator(minHeight: 3),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '주기',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _DropdownField<int>(
                          label: '반복 간격',
                          value: settings.intervalMinutes,
                          items: const <int>[15, 30, 45, 60, 90, 120, 180],
                          labelFor: (m) => '$m분',
                          onChanged: (value) async {
                            if (value == null) return;
                            await ref
                                .read(reminderControllerProvider.notifier)
                                .updateSettings(
                                  settings.copyWith(intervalMinutes: value),
                                );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StepperField(
                          label: '하루 최대',
                          value: settings.maxPerDay,
                          min: 1,
                          max: 64,
                          onChanged: (value) async {
                            await ref
                                .read(reminderControllerProvider.notifier)
                                .updateSettings(
                                  settings.copyWith(maxPerDay: value),
                                );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '조용한 시간',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _TimeField(
                          label: '시작',
                          minutes: settings.quietStartMinutes,
                          onPick: (value) async {
                            await ref
                                .read(reminderControllerProvider.notifier)
                                .updateSettings(
                                  settings.copyWith(quietStartMinutes: value),
                                );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TimeField(
                          label: '끝',
                          minutes: settings.quietEndMinutes,
                          onPick: (value) async {
                            await ref
                                .read(reminderControllerProvider.notifier)
                                .updateSettings(
                                  settings.copyWith(quietEndMinutes: value),
                                );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: settings.skipWeekends,
                    onChanged: (value) async {
                      await ref
                          .read(reminderControllerProvider.notifier)
                          .updateSettings(
                            settings.copyWith(skipWeekends: value),
                          );
                    },
                    title: const Text('주말 쉬기'),
                    subtitle: const Text('토/일에는 예약하지 않음'),
                  ),
                  const SizedBox(height: 6),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.info_outline_rounded, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '알림은 소리 없이 조용히 표시됩니다.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.black.withValues(alpha: 0.70),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (asyncSettings.isLoading) ...<Widget>[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }

  void _showPermissionDeniedSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('알림 권한이 필요합니다. 설정에서 허용해주세요.'),
        action: SnackBarAction(
          label: '설정',
          onPressed: () {
            try {
              AppSettings.openAppSettings(type: AppSettingsType.notification);
            } catch (_) {
              AppSettings.openAppSettings();
            }
          },
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.labelFor,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T) labelFor;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: [
            for (final item in items)
              DropdownMenuItem<T>(value: item, child: Text(labelFor(item))),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _StepperField extends StatelessWidget {
  const _StepperField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final canMinus = value > min;
    final canPlus = value < max;

    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: canMinus ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_rounded),
          ),
          Expanded(
            child: Center(
              child: Text(
                '$value',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          IconButton(
            onPressed: canPlus ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.minutes,
    required this.onPick,
  });

  final String label;
  final int minutes;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          helpText: '$label 시간 선택',
        );
        if (picked == null) return;
        onPick(picked.hour * 60 + picked.minute);
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: <Widget>[
              Expanded(
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
                      '$hh:$mm',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: GtgColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.schedule_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
