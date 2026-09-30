import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wear_app/core/theme/watch_theme.dart';
import 'package:wear_app/core/wear_os/watch_sync_client.dart';
import 'package:wear_app/features/log_button/presentation/log_button_screen.dart';
import 'package:wear_app/features/rhythm_heatmap/presentation/rhythm_heatmap_screen.dart';

class MockWatchSyncClient implements WatchSyncClient {
  bool sendLogSetCalled = false;
  bool shouldThrow = false;

  @override
  Future<void> sendLogSet() async {
    if (shouldThrow) {
      throw Exception('Phone disconnected');
    }
    sendLogSetCalled = true;
  }
}

void main() {
  group('Wear OS Feature & Widget Tests', () {
    late MockWatchSyncClient mockClient;

    setUp(() {
      mockClient = MockWatchSyncClient();
    });

    testWidgets('LogButtonScreen renders +1 button and handles tap log set', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [watchSyncClientProvider.overrideWithValue(mockClient)],
          child: MaterialApp(
            theme: WatchTheme.darkTheme,
            home: const Scaffold(body: LogButtonScreen(isAmbient: false)),
          ),
        ),
      );

      // Verify +1 button is rendered
      expect(find.text('+1'), findsOneWidget);

      // Tap the +1 button
      await tester.tap(find.text('+1'));
      await tester.pump();

      expect(mockClient.sendLogSetCalled, isTrue);

      // Settle timers for button debounce / reset
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.text('+1'), findsOneWidget);
    });

    testWidgets(
      'LogButtonScreen displays error message when phone sync fails',
      (tester) async {
        mockClient.shouldThrow = true;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [watchSyncClientProvider.overrideWithValue(mockClient)],
            child: MaterialApp(
              theme: WatchTheme.darkTheme,
              home: const Scaffold(body: LogButtonScreen(isAmbient: false)),
            ),
          ),
        );

        await tester.tap(find.text('+1'));
        await tester.pump();

        // Error message "폰 연결 끊김" should be displayed
        expect(find.text('폰 연결 끊김'), findsOneWidget);

        // Settle timers
        await tester.pumpAndSettle(const Duration(seconds: 3));
      },
    );

    testWidgets('LogButtonScreen does not allow tapping in ambient mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [watchSyncClientProvider.overrideWithValue(mockClient)],
          child: MaterialApp(
            theme: WatchTheme.darkTheme,
            home: const Scaffold(body: LogButtonScreen(isAmbient: true)),
          ),
        ),
      );

      await tester.tap(find.text('+1'));
      await tester.pump();

      // In ambient mode, sendLogSet should NOT be called
      expect(mockClient.sendLogSetCalled, isFalse);
    });

    testWidgets('RhythmHeatmapScreen renders RHYTHM title and day indicators', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: WatchTheme.darkTheme,
          home: const Scaffold(body: RhythmHeatmapScreen(isAmbient: false)),
        ),
      );

      expect(find.text('RHYTHM'), findsOneWidget);
      expect(find.text('M'), findsOneWidget);
      expect(find.text('T'), findsWidgets);
      expect(find.text('W'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
      expect(find.text('S'), findsWidgets);
    });
  });
}
