import 'package:flutter/material.dart';
import '../../../../core/ui/gtg_ui.dart';

void showGtgInfoBottomSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const GtgInfoBottomSheet(),
  );
}

class GtgInfoBottomSheet extends StatelessWidget {
  const GtgInfoBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GtgGlassCard(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      padding: EdgeInsets.fromLTRB(
        GtgUi.sectionPadding,
        24,
        GtgUi.sectionPadding,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GTG 운동법이란?',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '일상 속에서 틈틈이, 꾸준하게.',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '근육이 지칠 때까지 한 번에 몰아서 운동하는 대신, 최대 횟수의 50% 정도만 하루에 여러 번 나누어 진행하는 방식(Grease the Groove)이에요. 몸에 무리를 주지 않으면서도 근력과 신경계를 효과적으로 단련할 수 있습니다.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF), // Neon Cyan
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(
              '확인',
              style: textTheme.labelLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
