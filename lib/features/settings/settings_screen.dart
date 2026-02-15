import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/ads/gtg_banner_ad.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      children: <Widget>[
        Text(
          '설정',
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
                title: const Text('리마인더'),
                subtitle: const Text('반복 주기, 조용한 시간, 주말 쉬기'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/settings/reminders'),
              ),
              Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),
              ListTile(
                leading: const Icon(Icons.list_alt_rounded),
                title: const Text('전체 기록'),
                subtitle: const Text('날짜별/종목별로 모아보기'),
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
                title: const Text('앱 정보'),
                subtitle: const Text('PROJECT GTG'),
                onTap: () {},
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
