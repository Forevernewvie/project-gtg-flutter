/// Coalesces concurrent async startup work and memoizes successful completion.
final class AsyncOnce {
  bool _completed = false;
  Future<void>? _pending;

  /// Runs [action] at most once successfully.
  ///
  /// Concurrent callers share the same in-flight future. Failures are not
  /// memoized so a later caller can retry initialization.
  Future<void> run(Future<void> Function() action) async {
    if (_completed) return;

    final pending = _pending;
    if (pending != null) {
      await pending;
      return;
    }

    final future = action();
    _pending = future;

    try {
      await future;
      _completed = true;
    } finally {
      if (!_completed && identical(_pending, future)) {
        _pending = null;
      }
    }
  }
}
