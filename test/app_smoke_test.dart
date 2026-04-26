import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:project_gtg/app/gtg_app.dart';

void main() {
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher
        .clearLocalesTestValue();
  });

  testWidgets('app shows bottom navigation destinations', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: GtgApp(locale: Locale('ko'))),
    );
    await tester.pumpAndSettle();

    expect(find.text('홈'), findsOneWidget);
    expect(find.text('캘린더'), findsOneWidget);
    expect(find.text('설정'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('app keeps selected navigation label visible at large text', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;

    await tester.pumpWidget(
      const ProviderScope(child: GtgApp(locale: Locale('ko'))),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('홈'), findsOneWidget);
  });

  testWidgets('app falls back to English for non-Korean device locales', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [
      Locale('ja', 'JP'),
      Locale('fr', 'FR'),
    ];

    await tester.pumpWidget(const ProviderScope(child: GtgApp()));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('app keeps Korean when device locale list includes Korean', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [
      Locale('ja', 'JP'),
      Locale('ko', 'KR'),
    ];

    await tester.pumpWidget(const ProviderScope(child: GtgApp()));
    await tester.pumpAndSettle();

    expect(find.text('홈'), findsOneWidget);
    expect(find.text('캘린더'), findsOneWidget);
    expect(find.text('설정'), findsOneWidget);
  });
}
