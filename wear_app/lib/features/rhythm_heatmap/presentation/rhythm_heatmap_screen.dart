import 'package:flutter/material.dart';
import '../../../core/theme/watch_theme.dart';

class RhythmHeatmapScreen extends StatelessWidget {
  final bool isAmbient;
  const RhythmHeatmapScreen({Key? key, required this.isAmbient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy data matching the mockup
    final List<bool> rhythm = [true, false, true, true, false, true, false];
    final List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Scaffold(
      backgroundColor: isAmbient ? Colors.black : WatchTheme.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'RHYTHM',
              style: TextStyle(
                color: isAmbient ? Colors.white54 : WatchTheme.neonMint,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(7, (index) {
                final isActive = rhythm[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: Column(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isAmbient 
                              ? Colors.transparent 
                              : (isActive ? WatchTheme.neonMint : WatchTheme.slateGray),
                          border: isAmbient 
                              ? Border.all(color: isActive ? Colors.white : Colors.white24) 
                              : null,
                          boxShadow: (!isAmbient && isActive) ? [
                            BoxShadow(
                              color: WatchTheme.neonMint.withOpacity(0.5),
                              blurRadius: 6,
                              spreadRadius: 1,
                            )
                          ] : [],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        days[index],
                        style: TextStyle(
                          color: isAmbient 
                              ? (isActive ? Colors.white : Colors.white24)
                              : (isActive ? WatchTheme.neonMint : Colors.grey),
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Text(
              'ACTIVE DAYS: 4/7',
              style: TextStyle(
                color: isAmbient ? Colors.white54 : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
