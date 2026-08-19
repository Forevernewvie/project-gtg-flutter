import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wear/wear.dart';

import 'core/theme/watch_theme.dart';
import 'features/log_button/presentation/log_button_screen.dart';
import 'features/rhythm_heatmap/presentation/rhythm_heatmap_screen.dart';

void main() {
  runApp(const ProviderScope(child: GTGWearApp()));
}

class GTGWearApp extends StatelessWidget {
  const GTGWearApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GTG Watch',
      theme: WatchTheme.darkTheme,
      home: const WatchRootScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WatchRootScreen extends StatefulWidget {
  const WatchRootScreen({super.key});

  @override
  State<WatchRootScreen> createState() => _WatchRootScreenState();
}

class _WatchRootScreenState extends State<WatchRootScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Ambient Mode 지원: AOD 상태일 때 UI 번인 방지 및 흑백 처리
    return AmbientMode(
      builder: (context, mode, child) {
        final isAmbient = mode == WearMode.ambient;

        // 2. Round Screen 클리핑 방지 여백 설정
        return WatchShape(
          builder: (context, shape, child) {
            return Scaffold(
              backgroundColor: isAmbient
                  ? Colors.black
                  : WatchTheme.darkBackground,
              body: PageView(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                // 스와이프 및 디지털 크라운 회전(스크롤)을 기본 지원
                physics: const BouncingScrollPhysics(),
                children: [
                  LogButtonScreen(isAmbient: isAmbient),
                  RhythmHeatmapScreen(isAmbient: isAmbient),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
