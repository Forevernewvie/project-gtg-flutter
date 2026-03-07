import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/ads/gtg_banner_ad.dart';
import '../../core/app_links.dart';
import '../../core/app_link_policy.dart';
import '../../core/logging/logger_provider.dart';
import '../../core/models/app_theme_preference.dart';
import '../../core/ui/gtg_ui.dart';
import '../../l10n/app_localizations.dart';
import 'state/theme_preference_controller.dart';

/// Collects settings-screen layout rules and interaction logging labels.
abstract final class _SettingsPolicy {
  static const String invalidPrivacyUrlLog =
      'Settings privacy policy URL failed validation.';
  static const String failedPrivacyLaunchLog =
      'Settings privacy policy could not be launched.';
  static const String failedThemePreferenceLog =
      'Failed to update theme preference from settings.';
}

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

  /// Opens the privacy policy URL after validating secure HTTPS scheme and host.
  Future<void> _openPrivacyPolicy(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final logger = ref.read(appLoggerProvider);
    final uri = AppLinkPolicy.parseExternalHttpsUri(AppLinks.privacyPolicyUrl);
    if (uri == null) {
      logger.warning(_SettingsPolicy.invalidPrivacyUrlLog);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.invalidLink)));
      return;
    }

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      logger.warning(_SettingsPolicy.failedPrivacyLaunchLog);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.cannotOpenBrowser)));
    }
  }

  /// Persists a theme preference change while keeping failures visible in logs.
  Future<void> _setThemePreference(
    WidgetRef ref,
    AppThemePreference preference,
  ) async {
    try {
      await ref
          .read(themePreferenceControllerProvider.notifier)
          .setPreference(preference);
    } catch (error, stackTrace) {
      ref
          .read(appLoggerProvider)
          .error(
            _SettingsPolicy.failedThemePreferenceLog,
            error: error,
            stackTrace: stackTrace,
          );
    }
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                l10n.settingsTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Text(
                  currentThemeLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              children: <Widget>[
                _SettingsActionTile(
                  icon: Icons.notifications_active_rounded,
                  title: l10n.remindersTitle,
                  subtitle: l10n.remindersSubtitle,
                  accent: colorScheme.primary,
                  onTap: () => context.push('/settings/reminders'),
                ),
                const SizedBox(height: 8),
                _SettingsActionTile(
                  icon: Icons.list_alt_rounded,
                  title: l10n.allLogsTitle,
                  subtitle: l10n.allLogsSubtitle,
                  accent: colorScheme.secondary,
                  onTap: () => context.push('/settings/logs'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.palette_outlined,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.settingsThemeTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Text(
                          currentThemeLabel,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.settingsThemeSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: _ThemePreferenceGroup(
                      options: themeOptions,
                      selectedPreference: themePreference,
                      enabled: !themePreferenceAsync.isLoading,
                      onSelected: (preference) async {
                        await _setThemePreference(ref, preference);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.aboutTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _SettingsActionTile(
                  icon: Icons.privacy_tip_outlined,
                  title: l10n.privacyPolicyTitle,
                  subtitle: l10n.privacyPolicySubtitle,
                  accent: colorScheme.primary,
                  trailingIcon: Icons.open_in_new_rounded,
                  onTap: () => _openPrivacyPolicy(context, ref),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        const GtgBannerAd(),
      ],
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
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withValues(alpha: 0.18)),
          ),
          child: ListTile(
            onTap: onTap,
            contentPadding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
            minLeadingWidth: 0,
            leading: DecoratedBox(
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
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
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = selected
        ? Color.alphaBlend(
            colorScheme.primary.withValues(alpha: 0.14),
            colorScheme.surface,
          )
        : colorScheme.surface;
    final borderColor = selected
        ? colorScheme.primary
        : colorScheme.outlineVariant;
    final iconColor = selected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;
    final trailingIcon = selected
        ? Icons.check_circle_rounded
        : Icons.radio_button_unchecked_rounded;

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('settings.theme.option.${option.preference.name}'),
          borderRadius: BorderRadius.circular(18),
          onTap: enabled ? onTap : null,
          child: Ink(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor, width: selected ? 1.4 : 1),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: <Widget>[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: selected
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(9),
                      child: Icon(option.icon, color: iconColor, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(trailingIcon, color: iconColor, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
