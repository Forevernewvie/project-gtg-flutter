import 'package:flutter/foundation.dart';

/// Defines a minimal logging contract for app-level observability.
abstract interface class AppLogger {
  /// Records an informational event used for flow tracing.
  void info(String message);

  /// Records a non-fatal issue that may require follow-up.
  void warning(String message, {Object? error, StackTrace? stackTrace});

  /// Records a critical failure that impacts expected behavior.
  void error(String message, {Object? error, StackTrace? stackTrace});
}

/// Default logger implementation that writes structured messages via debugPrint.
class DebugAppLogger implements AppLogger {
  const DebugAppLogger();

  @override
  void info(String message) {
    _write('INFO', message);
  }

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _write('WARN', message, error: error, stackTrace: stackTrace);
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _write('ERROR', message, error: error, stackTrace: stackTrace);
  }

  /// Writes one log line plus optional error details in debug mode.
  void _write(
    String level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;

    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp][$level] $message');
    if (error != null) {
      debugPrint('[$timestamp][$level] error=$error');
    }
    if (stackTrace != null) {
      debugPrint('[$timestamp][$level] stackTrace=$stackTrace');
    }
  }
}
