import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/ads/gtg_banner_ad.dart';
import '../../core/app_links.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final uri = Uri.tryParse(AppLinks.privacyPolicyUrl);
    if (uri == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.invalidLink)));
      return;
    }

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.cannotOpenBrowser)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      children: <Widget>[
        Text(
          l10n.settingsTitle,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.notifications_active_rounded),
                title: Text(l10n.remindersTitle),
                subtitle: Text(l10n.remindersSubtitle),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/settings/reminders'),
              ),
              Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),
              ListTile(
                leading: const Icon(Icons.list_alt_rounded),
                title: Text(l10n.allLogsTitle),
                subtitle: Text(l10n.allLogsSubtitle),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/settings/logs'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: Text(l10n.aboutTitle),
                subtitle: Text(l10n.appTitle),
                onTap: () {},
              ),
              Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(l10n.privacyPolicyTitle),
                subtitle: Text(l10n.privacyPolicySubtitle),
                trailing: const Icon(Icons.open_in_new_rounded),
                onTap: () => _openPrivacyPolicy(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const GtgBannerAd(),
      ],
    );
  }
}
