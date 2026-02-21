import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/models/reminder_settings.dart';
import '../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    final asyncSettings = ref.watch(reminderControllerProvider);
    final settings = asyncSettings.asData?.value ?? ReminderSettings.defaults;
    final plannedTimes = ref.watch(plannedReminderTimesProvider);
    final now = ref.watch(clockProvider).now();
    final nextTime = plannedTimes.isNotEmpty ? plannedTimes.first : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.remindersTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
        children: <Widget>[
          Text(
            l10n.remindersHeadline,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.remindersSubheadline,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                              l10n.enableRemindersTitle,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _buildEnabledSubtitle(
                                now: now,
                                enabled: settings.enabled,
                                nextTime: nextTime,
                                plannedCount: plannedTimes.length,
                              ),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
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
                    l10n.scheduleSectionTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 360;

                      final intervalField = _DropdownField<int>(
                        label: l10n.intervalLabel,
                        value: settings.intervalMinutes,
                        items: const <int>[15, 30, 45, 60, 90, 120, 180],
                        labelFor: l10n.minutesShort,
                        onChanged: (value) async {
                          if (value == null) return;
                          await ref
                              .read(reminderControllerProvider.notifier)
                              .updateSettings(
                                settings.copyWith(intervalMinutes: value),
                              );
                        },
                      );

                      final maxPerDayField = _StepperField(
                        label: l10n.maxPerDayLabel,
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
                      );

                      if (isCompact) {
                        return Column(
                          children: <Widget>[
                            intervalField,
                            const SizedBox(height: 12),
                            maxPerDayField,
                          ],
                        );
                      }

                      return Row(
                        children: <Widget>[
                          Expanded(child: intervalField),
                          const SizedBox(width: 12),
                          Expanded(child: maxPerDayField),
                        ],
                      );
                    },
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
                    l10n.quietHoursTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 360;

                      final startField = _TimeField(
                        label: l10n.startLabel,
                        minutes: settings.quietStartMinutes,
                        onPick: (value) async {
                          await ref
                              .read(reminderControllerProvider.notifier)
                              .updateSettings(
                                settings.copyWith(quietStartMinutes: value),
                              );
                        },
                      );

                      final endField = _TimeField(
                        label: l10n.endLabel,
                        minutes: settings.quietEndMinutes,
                        onPick: (value) async {
                          await ref
                              .read(reminderControllerProvider.notifier)
                              .updateSettings(
                                settings.copyWith(quietEndMinutes: value),
                              );
                        },
                      );

                      if (isCompact) {
                        return Column(
                          children: <Widget>[
                            startField,
                            const SizedBox(height: 12),
                            endField,
                          ],
                        );
                      }

                      return Row(
                        children: <Widget>[
                          Expanded(child: startField),
                          const SizedBox(width: 12),
                          Expanded(child: endField),
                        ],
                      );
                    },
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
                    title: Text(l10n.weekendsOffTitle),
                    subtitle: Text(l10n.weekendsOffSubtitle),
                  ),
                  const SizedBox(height: 6),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
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
                              l10n.silentNotificationsInfo,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
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
    final l10n = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.permissionDenied),
        action: SnackBarAction(
          label: l10n.openSettings,
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

  String _buildEnabledSubtitle({
    required DateTime now,
    required bool enabled,
    required DateTime? nextTime,
    required int plannedCount,
  }) {
    final l10n = AppLocalizations.of(context)!;

    if (!enabled) return l10n.enableRemindersOffSubtitle;
    if (nextTime == null) {
      return l10n.enableRemindersNoSlotsSubtitle;
    }

    final label = _formatNextTime(now, nextTime, l10n);
    return l10n.enableRemindersNextScheduledSubtitle(label, plannedCount);
  }

  String _formatNextTime(DateTime now, DateTime next, AppLocalizations l10n) {
    final time = TimeOfDay.fromDateTime(next);
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');

    final sameDay =
        now.year == next.year && now.month == next.month && now.day == next.day;
    if (sameDay) return '$hh:$mm';

    final tomorrow = now.add(const Duration(days: 1));
    final isTomorrow =
        tomorrow.year == next.year &&
        tomorrow.month == next.month &&
        tomorrow.day == next.day;

    if (isTomorrow) return l10n.tomorrowAt('$hh:$mm');
    return '${next.month}/${next.day} $hh:$mm';
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
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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
    final l10n = AppLocalizations.of(context)!;

    final time = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          helpText: l10n.pickTimeHelp(label),
        );
        if (picked == null) return;
        onPick(picked.hour * 60 + picked.minute);
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
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
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$hh:$mm',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface,
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
