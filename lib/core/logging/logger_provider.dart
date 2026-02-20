import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_logger.dart';

/// Provides a shared app logger instance for dependency injection.
final appLoggerProvider = Provider<AppLogger>((ref) {
  return const DebugAppLogger();
});
