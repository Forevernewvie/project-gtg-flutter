import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_gtg/core/clock.dart';
import 'package:project_gtg/core/logging/app_logger.dart';
import 'package:project_gtg/core/logging/logger_provider.dart';
import 'package:project_gtg/core/models/reminder_settings.dart';
import 'package:project_gtg/core/ui/gtg_ui.dart';
import 'package:project_gtg/features/reminders/reminder_ui_policy.dart';
import 'package:project_gtg/features/reminders/state/reminder_controller.dart';
import 'package:project_gtg/features/reminders/state/reminder_providers.dart';
import 'package:project_gtg/l10n/app_localizations.dart';

/// Displays reminder controls and schedule tuning without changing reminder business logic.
class ReminderSettingsScreen extends ConsumerStatefulWidget {
  const ReminderSettingsScreen({super.key});

  /// Creates state that coordinates reminder mutations and busy indicators.
  @override
  ConsumerState<ReminderSettingsScreen> createState() =>
      _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState
    extends ConsumerState<ReminderSettingsScreen> {
  static const String _enableRemindersFailureLog =
      'Failed to toggle reminder enablement.';
  static const String _updateReminderSettingsFailureLog =
      'Failed to update reminder settings.';
  static const String _openAppSettingsFallbackLog =
      'Notification settings route unavailable, opening generic app settings.';

  bool _busy = false;

  ReminderController get _controller =>
      ref.read(reminderControllerProvider.notifier);

  /// Toggles the enabled flag and logs failures without crashing the screen.
  Future<void> _setEnabled(bool value) async {
    setState(() => _busy = true);

    try {
      final ok = await _controller.setEnabled(value);
      if (!mounted) return;
      if (!ok) _showPermissionDeniedSnackBar(context);
    } catch (error, stackTrace) {
      _logger.error(
        _enableRemindersFailureLog,
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  /// Persists reminder settings changes while keeping UI callbacks lightweight.
  Future<void> _updateSettings(ReminderSettings updated) async {
    try {
      await _controller.updateSettings(updated);
    } catch (error, stackTrace) {
      _logger.error(
        _updateReminderSettingsFailureLog,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Builds reminder settings sections (toggle, schedule, quiet hours) from reactive state.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final asyncSettings = ref.watch(reminderControllerProvider);
    final settings = asyncSettings.asData?.value ?? ReminderSettings.defaults;
    final plannedTimes = ref.watch(plannedReminderTimesProvider);
    final now = ref.watch(clockProvider).now();
    final nextTime = plannedTimes.isNotEmpty ? plannedTimes.first : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.remindersTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          GtgUi.screenHorizontalPadding,
          GtgUi.screenTopPadding,
          GtgUi.screenHorizontalPadding,
          GtgUi.screenBottomPadding + 4,
        ),
        children: <Widget>[
          GtgPageIntro(
            title: l10n.remindersHeadline,
            subtitle: l10n.remindersSubheadline,
          ),
          const SizedBox(height: GtgUi.primarySectionSpacing),
          GtgSectionCard(
            icon: Icons.notifications_active_rounded,
            accent: colorScheme.primary,
            title: l10n.enableRemindersTitle,
            subtitle: ReminderUiPolicy.buildEnabledSubtitle(
              l10n: l10n,
              now: now,
              enabled: settings.enabled,
              nextTime: nextTime,
              plannedCount: plannedTimes.length,
            ),
            trailing: Switch(
              key: const Key('reminders.enabledSwitch'),
              value: settings.enabled,
              onChanged: _busy ? null : _setEnabled,
            ),
            child: _busy
                ? const LinearProgressIndicator(minHeight: 3)
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: GtgUi.primarySectionSpacing),
          GtgSectionCard(
            icon: Icons.tune_rounded,
            accent: colorScheme.primary,
            title: l10n.scheduleSectionTitle,
            child: _ScheduleFields(
              settings: settings,
              onChanged: _updateSettings,
            ),
          ),
          const SizedBox(height: GtgUi.primarySectionSpacing),
          GtgSectionCard(
            icon: Icons.bedtime_rounded,
            accent: colorScheme.secondary,
            title: l10n.quietHoursTitle,
            child: Column(
              children: <Widget>[
                _QuietHoursFields(
                  settings: settings,
                  onChanged: _updateSettings,
                ),
                const SizedBox(height: GtgUi.controlSpacing),
                _WeekendsToggleRow(
                  settings: settings,
                  onChanged: _updateSettings,
                ),
                const SizedBox(height: 8),
                const _ReminderInfoBanner(),
              ],
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

  /// Shows a snackbar when notification permission is denied and offers app-settings shortcut.
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
            } catch (error, stackTrace) {
              _logger.warning(
                _openAppSettingsFallbackLog,
                error: error,
                stackTrace: stackTrace,
              );
              AppSettings.openAppSettings();
            }
          },
        ),
      ),
    );
  }

  /// Exposes the injected logger so UI callbacks remain implementation-agnostic.
  AppLogger get _logger => ref.read(appLoggerProvider);
}

class _ScheduleFields extends StatelessWidget {
  const _ScheduleFields({required this.settings, required this.onChanged});

  final ReminderSettings settings;
  final ValueChanged<ReminderSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GtgResponsivePair(
      primary: _DropdownField<int>(
        label: l10n.intervalLabel,
        value: settings.intervalMinutes,
        items: ReminderUiPolicy.intervalOptions,
        labelFor: l10n.minutesShort,
        onChanged: (value) {
          if (value == null) return;
          onChanged(settings.copyWith(intervalMinutes: value));
        },
      ),
      secondary: _StepperField(
        label: l10n.maxPerDayLabel,
        value: settings.maxPerDay,
        min: ReminderUiPolicy.minMaxPerDay,
        max: ReminderUiPolicy.maxMaxPerDay,
        onChanged: (value) => onChanged(settings.copyWith(maxPerDay: value)),
      ),
    );
  }
}

class _QuietHoursFields extends StatelessWidget {
  const _QuietHoursFields({required this.settings, required this.onChanged});

  final ReminderSettings settings;
  final ValueChanged<ReminderSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GtgResponsivePair(
      primary: _TimeField(
        label: l10n.startLabel,
        minutes: settings.quietStartMinutes,
        onPick: (value) {
          onChanged(settings.copyWith(quietStartMinutes: value));
        },
      ),
      secondary: _TimeField(
        label: l10n.endLabel,
        minutes: settings.quietEndMinutes,
        onPick: (value) {
          onChanged(settings.copyWith(quietEndMinutes: value));
        },
      ),
    );
  }
}

class _WeekendsToggleRow extends StatelessWidget {
  const _WeekendsToggleRow({required this.settings, required this.onChanged});

  final ReminderSettings settings;
  final ValueChanged<ReminderSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return GtgResponsivePair(
      primary: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.weekendsOffTitle,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.weekendsOffSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      secondary: Switch(
        value: settings.skipWeekends,
        onChanged: (value) {
          onChanged(settings.copyWith(skipWeekends: value));
        },
      ),
      expandSecondary: false,
      compactSecondaryAlignment: Alignment.centerRight,
    );
  }
}

class _ReminderInfoBanner extends StatelessWidget {
  const _ReminderInfoBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(GtgUi.controlRadius),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _reminderFieldDecoration(String label) {
  return InputDecoration(
    labelText: label,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(GtgUi.controlRadius),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );
}

/// Reusable dropdown field for schedule values with outlined input styling.
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

  /// Builds a labeled dropdown input that expands to avoid compact-layout overflow.
  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: _reminderFieldDecoration(label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
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

/// Reusable numeric stepper field for bounded integer configuration.
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

  /// Builds a minus/value/plus control with guard rails for min/max boundaries.
  @override
  Widget build(BuildContext context) {
    final canMinus = value > min;
    final canPlus = value < max;

    return InputDecorator(
      decoration: _reminderFieldDecoration(label),
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

/// Reusable time picker field for quiet-hour boundaries.
class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.minutes,
    required this.onPick,
  });

  final String label;
  final int minutes;
  final ValueChanged<int> onPick;

  /// Builds tappable time tile and writes picked minutes back through callback.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final time = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');

    return InkWell(
      borderRadius: BorderRadius.circular(GtgUi.controlRadius),
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
          borderRadius: BorderRadius.circular(GtgUi.controlRadius),
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
