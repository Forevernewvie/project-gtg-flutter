import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:project_gtg/app/gtg_app.dart';

void main() {
  testWidgets('app shows bottom navigation destinations', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: GtgApp()));
    await tester.pumpAndSettle();

    expect(find.text('홈'), findsOneWidget);
    expect(find.text('캘린더'), findsOneWidget);
    expect(find.text('설정'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
