import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_gtg/core/ads/ad_privacy_manager.dart';
import 'package:project_gtg/core/ads/gtg_banner_ad.dart';
import 'package:project_gtg/core/ui/gtg_ui.dart';
import 'package:project_gtg/features/settings/state/settings_action_service.dart';
import 'package:project_gtg/l10n/app_localizations.dart';

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

  /// Builds reminders/logs/policy settings UI without theme preference controls.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
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
        GtgPageIntro(title: l10n.settingsTitle),
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
