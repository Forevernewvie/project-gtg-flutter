import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_gtg/core/ads/ad_privacy_manager.dart';
import 'package:project_gtg/core/ads/gtg_banner_ad.dart';
import 'package:project_gtg/core/models/app_theme_preference.dart';
import 'package:project_gtg/core/ui/gtg_ui.dart';
import 'package:project_gtg/features/settings/state/settings_action_service.dart';
import 'package:project_gtg/features/settings/state/theme_preference_controller.dart';
import 'package:project_gtg/l10n/app_localizations.dart';

/// Describes one selectable theme option shown in settings.
final class _ThemeOption {
  const _ThemeOption({
    required this.preference,
    required this.label,
    required this.icon,
  });

  final AppThemePreference preference;
  final String label;
  final IconData icon;
}

/// Renders top-level settings while keeping navigation and feature flows intact.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// Opens the privacy policy flow and maps side-effect outcomes into snackbar feedback.
  Future<void> _openPrivacyPolicy(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await ref
        .read(settingsActionServiceProvider)
        .openPrivacyPolicy();
    if (!context.mounted || result == PrivacyPolicyLaunchResult.opened) {
      return;
    }

    final message = result == PrivacyPolicyLaunchResult.invalidUrl
        ? l10n.invalidLink
        : l10n.cannotOpenBrowser;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openAdPrivacyChoices(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await ref
        .read(settingsActionServiceProvider)
        .openAdPrivacyChoices();
    if (!context.mounted || result == AdPrivacyChoicesResult.opened) {
      return;
    }

    final message = result == AdPrivacyChoicesResult.unavailable
        ? l10n.adPrivacyChoicesUnavailable
        : l10n.cannotOpenBrowser;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Persists a theme preference change through the settings action service.
  Future<void> _setThemePreference(
    WidgetRef ref,
    AppThemePreference preference,
  ) async {
    await ref
        .read(settingsActionServiceProvider)
        .setThemePreference(preference);
  }

  /// Returns the ordered theme options used by the settings selector.
  List<_ThemeOption> _buildThemeOptions(AppLocalizations l10n) {
    return <_ThemeOption>[
      _ThemeOption(
        preference: AppThemePreference.system,
        label: l10n.settingsThemeSystem,
        icon: Icons.brightness_auto_rounded,
      ),
      _ThemeOption(
        preference: AppThemePreference.light,
        label: l10n.settingsThemeLight,
        icon: Icons.light_mode_rounded,
      ),
      _ThemeOption(
        preference: AppThemePreference.dark,
        label: l10n.settingsThemeDark,
        icon: Icons.dark_mode_rounded,
      ),
    ];
  }

  /// Builds reminders/logs/theme/policy settings UI using persisted app preferences.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final themePreferenceAsync = ref.watch(themePreferenceControllerProvider);
    final themePreference =
        themePreferenceAsync.asData?.value ?? AppThemePreference.system;
    final currentThemeLabel = switch (themePreference) {
      AppThemePreference.system => l10n.settingsThemeSystem,
      AppThemePreference.light => l10n.settingsThemeLight,
      AppThemePreference.dark => l10n.settingsThemeDark,
    };
    final themeOptions = _buildThemeOptions(l10n);

    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(
        GtgUi.screenHorizontalPadding,
        GtgUi.screenTopPadding - 2,
        GtgUi.screenHorizontalPadding,
        GtgUi.screenBottomPadding,
      ),
      children: <Widget>[
        GtgPageIntro(
          title: l10n.settingsTitle,
          trailing: _SettingsStatusPill(label: currentThemeLabel),
        ),
        const SizedBox(height: GtgUi.primarySectionSpacing),
        _SettingsActionsSection(
          primaryAccent: colorScheme.primary,
          secondaryAccent: colorScheme.secondary,
          coachTitle: l10n.settingsCoachTitle,
          coachSubtitle: l10n.settingsCoachSubtitle,
          remindersTitle: l10n.remindersTitle,
          remindersSubtitle: l10n.remindersSubtitle,
          allLogsTitle: l10n.allLogsTitle,
          allLogsSubtitle: l10n.allLogsSubtitle,
          onOpenCoach: () => context.push('/settings/coach'),
          onOpenReminders: () => context.push('/settings/reminders'),
          onOpenLogs: () => context.push('/settings/logs'),
        ),
        const SizedBox(height: GtgUi.primarySectionSpacing),
        _SettingsThemeSection(
          accent: colorScheme.primary,
          title: l10n.settingsThemeTitle,
          subtitle: l10n.settingsThemeSubtitle,
          options: themeOptions,
          selectedPreference: themePreference,
          enabled: !themePreferenceAsync.isLoading,
          onSelected: (preference) async {
            await _setThemePreference(ref, preference);
          },
        ),
        const SizedBox(height: GtgUi.primarySectionSpacing),
        _SettingsAboutSection(
          accent: colorScheme.primary,
          title: l10n.aboutTitle,
          privacyTitle: l10n.privacyPolicyTitle,
          privacySubtitle: l10n.privacyPolicySubtitle,
          adPrivacyChoicesTitle: l10n.adPrivacyChoicesTitle,
          adPrivacyChoicesSubtitle: l10n.adPrivacyChoicesSubtitle,
          privacyOptionsRequiredListenable:
              AdPrivacyManager.instance.privacyOptionsRequiredListenable,
          onOpenAdPrivacyChoices: () => _openAdPrivacyChoices(context, ref),
          onOpenPrivacyPolicy: () => _openPrivacyPolicy(context, ref),
        ),
        const SizedBox(height: GtgUi.primarySectionSpacing),
        const GtgBannerAd(),
      ],
    );
  }
}

class _SettingsActionsSection extends StatelessWidget {
  const _SettingsActionsSection({
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.coachTitle,
    required this.coachSubtitle,
    required this.remindersTitle,
    required this.remindersSubtitle,
    required this.allLogsTitle,
    required this.allLogsSubtitle,
    required this.onOpenCoach,
    required this.onOpenReminders,
    required this.onOpenLogs,
  });

  final Color primaryAccent;
  final Color secondaryAccent;
  final String coachTitle;
  final String coachSubtitle;
  final String remindersTitle;
  final String remindersSubtitle;
  final String allLogsTitle;
  final String allLogsSubtitle;
  final VoidCallback onOpenCoach;
  final VoidCallback onOpenReminders;
  final VoidCallback onOpenLogs;

  @override
  Widget build(BuildContext context) {
    return GtgSectionCard(
      child: Column(
        children: <Widget>[
          _SettingsActionTile(
            icon: Icons.track_changes_rounded,
            title: coachTitle,
            subtitle: coachSubtitle,
            accent: primaryAccent,
            onTap: onOpenCoach,
          ),
          const SizedBox(height: GtgUi.secondarySectionSpacing),
          _SettingsActionTile(
            icon: Icons.notifications_active_rounded,
            title: remindersTitle,
            subtitle: remindersSubtitle,
            accent: primaryAccent,
            onTap: onOpenReminders,
          ),
          const SizedBox(height: GtgUi.secondarySectionSpacing),
          _SettingsActionTile(
            icon: Icons.list_alt_rounded,
            title: allLogsTitle,
            subtitle: allLogsSubtitle,
            accent: secondaryAccent,
            onTap: onOpenLogs,
          ),
        ],
      ),
    );
  }
}

class _SettingsThemeSection extends StatelessWidget {
  const _SettingsThemeSection({
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selectedPreference,
    required this.enabled,
    required this.onSelected,
  });

  final Color accent;
  final String title;
  final String subtitle;
  final List<_ThemeOption> options;
  final AppThemePreference selectedPreference;
  final bool enabled;
  final ValueChanged<AppThemePreference> onSelected;

  @override
  Widget build(BuildContext context) {
    return GtgSectionCard(
      icon: Icons.palette_outlined,
      accent: accent,
      title: title,
      subtitle: subtitle,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(GtgUi.cardRadius - 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: _ThemePreferenceGroup(
            options: options,
            selectedPreference: selectedPreference,
            enabled: enabled,
            onSelected: onSelected,
          ),
        ),
      ),
    );
  }
}

class _SettingsAboutSection extends StatelessWidget {
  const _SettingsAboutSection({
    required this.accent,
    required this.title,
    required this.privacyTitle,
    required this.privacySubtitle,
    required this.adPrivacyChoicesTitle,
    required this.adPrivacyChoicesSubtitle,
    required this.privacyOptionsRequiredListenable,
    required this.onOpenAdPrivacyChoices,
    required this.onOpenPrivacyPolicy,
  });

  final Color accent;
  final String title;
  final String privacyTitle;
  final String privacySubtitle;
  final String adPrivacyChoicesTitle;
  final String adPrivacyChoicesSubtitle;
  final ValueListenable<bool> privacyOptionsRequiredListenable;
  final VoidCallback onOpenAdPrivacyChoices;
  final VoidCallback onOpenPrivacyPolicy;

  @override
  Widget build(BuildContext context) {
    return GtgSectionCard(
      icon: Icons.info_outline_rounded,
      accent: accent,
      title: title,
      child: Column(
        children: <Widget>[
          _SettingsActionTile(
            icon: Icons.privacy_tip_outlined,
            title: privacyTitle,
            subtitle: privacySubtitle,
            accent: accent,
            trailingIcon: Icons.open_in_new_rounded,
            onTap: onOpenPrivacyPolicy,
          ),
          ValueListenableBuilder<bool>(
            valueListenable: privacyOptionsRequiredListenable,
            builder: (context, required, child) {
              if (!required) {
                return const SizedBox.shrink();
              }
              return Column(
                children: <Widget>[
                  const SizedBox(height: GtgUi.secondarySectionSpacing),
                  _SettingsActionTile(
                    icon: Icons.ads_click_outlined,
                    title: adPrivacyChoicesTitle,
                    subtitle: adPrivacyChoicesSubtitle,
                    accent: accent,
                    onTap: onOpenAdPrivacyChoices,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsStatusPill extends StatelessWidget {
  const _SettingsStatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(GtgUi.pillRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

/// Renders one tappable settings row with icon, copy, and trailing affordance.
class _SettingsActionTile extends StatelessWidget {
  const _SettingsActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
    this.trailingIcon = Icons.chevron_right_rounded,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;
  final IconData trailingIcon;

  /// Builds the action tile and preserves a large touch target for accessibility.
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              accent.withValues(alpha: 0.08),
              colorScheme.surface,
            ),
            borderRadius: BorderRadius.circular(GtgUi.cardRadius - 2),
            border: Border.all(color: accent.withValues(alpha: 0.18)),
          ),
          child: ListTile(
            onTap: onTap,
            contentPadding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
            minLeadingWidth: 0,
            leading: DecoratedBox(
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(GtgUi.controlRadius - 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: Icon(icon, color: accent, size: 18),
              ),
            ),
            title: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            trailing: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  trailingIcon,
                  color: colorScheme.onSurfaceVariant,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Renders the theme options as stable full-width selection tiles.
class _ThemePreferenceGroup extends StatelessWidget {
  const _ThemePreferenceGroup({
    required this.options,
    required this.selectedPreference,
    required this.enabled,
    required this.onSelected,
  });

  final List<_ThemeOption> options;
  final AppThemePreference selectedPreference;
  final bool enabled;
  final ValueChanged<AppThemePreference> onSelected;

  /// Builds a vertically stacked group that remains stable across text scales.
  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('settings.theme.segmented'),
      children: <Widget>[
        for (var index = 0; index < options.length; index++) ...<Widget>[
          _ThemePreferenceTile(
            option: options[index],
            selected: options[index].preference == selectedPreference,
            enabled: enabled,
            onTap: () => onSelected(options[index].preference),
          ),
          if (index != options.length - 1)
            const SizedBox(height: GtgUi.secondarySectionSpacing),
        ],
      ],
    );
  }
}

/// Renders one full-width theme option row with selected-state feedback.
class _ThemePreferenceTile extends StatelessWidget {
  const _ThemePreferenceTile({
    required this.option,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final _ThemeOption option;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  /// Builds a resilient theme-selection tile with clear affordance and status.
  @override
  Widget build(BuildContext context) {
    return GtgSelectableCard(
      key: Key('settings.theme.option.${option.preference.name}'),
      icon: option.icon,
      accent: Theme.of(context).colorScheme.primary,
      title: option.label,
      selected: selected,
      onTap: onTap,
      enabled: enabled,
    );
  }
}
