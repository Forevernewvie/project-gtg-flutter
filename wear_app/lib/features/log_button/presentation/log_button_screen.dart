import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/watch_theme.dart';
import '../../../core/wear_os/watch_sync_client.dart';

class LogButtonState extends Notifier<bool> {
  @override
  bool build() => false;
  void setState(bool value) => state = value;
}
final logButtonStateProvider = NotifierProvider<LogButtonState, bool>(() => LogButtonState());

class LogErrorState extends Notifier<String?> {
  @override
  String? build() => null;
  void setState(String? value) => state = value;
}
final logErrorProvider = NotifierProvider<LogErrorState, String?>(() => LogErrorState());

class LogButtonScreen extends ConsumerWidget {
  final bool isAmbient;
  const LogButtonScreen({Key? key, required this.isAmbient}) : super(key: key);

  Future<void> _handleLog(WidgetRef ref) async {
    if (isAmbient) return;

    final isLoading = ref.read(logButtonStateProvider);
    if (isLoading) return;

    HapticFeedback.lightImpact();
    ref.read(logButtonStateProvider.notifier).setState(true);
    ref.read(logErrorProvider.notifier).setState(null);
    
    try {
      await ref.read(watchSyncClientProvider).sendLogSet();
    } catch (e) {
      ref.read(logErrorProvider.notifier).setState("폰 연결 끊김");
      HapticFeedback.vibrate();
    } finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        ref.read(logButtonStateProvider.notifier).setState(false);
        Future.delayed(const Duration(seconds: 2), () {
          ref.read(logErrorProvider.notifier).setState(null);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(logButtonStateProvider);
    final errorMsg = ref.watch(logErrorProvider);

    return Scaffold(
      backgroundColor: isAmbient ? Colors.black : WatchTheme.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _handleLog(ref),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                // 3. 터치 타깃 48dp 이상 확보 (현재 160dp)
                width: isAmbient ? 160 : (isLoading ? 140 : 160),
                height: isAmbient ? 160 : (isLoading ? 140 : 160),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // 앰비언트 모드 번인 방지: 속을 비우고 테두리만
                  color: isAmbient ? Colors.transparent : WatchTheme.slateGray,
                  border: isAmbient ? Border.all(color: Colors.white54, width: 2) : null,
                  boxShadow: (isAmbient || isLoading) ? [] : [
                    BoxShadow(
                      color: WatchTheme.neonMint.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    '+1',
                    style: TextStyle(
                      color: isAmbient ? Colors.white54 : WatchTheme.neonMint,
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                    ),
                  ),
                ),
              ),
            ),
            // 에러 메시지 공간 (폰 연결 끊김 등)
            if (errorMsg != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorMsg,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
