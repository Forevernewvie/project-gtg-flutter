import 'package:flutter_test/flutter_test.dart';
import 'package:project_gtg/core/async/async_once.dart';

void main() {
  test('coalesces overlapping calls and memoizes success', () async {
    final once = AsyncOnce();
    var runs = 0;

    Future<void> initialize() async {
      runs += 1;
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }

    await Future.wait<void>([once.run(initialize), once.run(initialize)]);
    await once.run(initialize);

    expect(runs, 1);
  });

  test('allows retry after a failed run', () async {
    final once = AsyncOnce();
    var runs = 0;

    Future<void> initialize() async {
      runs += 1;
      if (runs == 1) {
        throw StateError('first run fails');
      }
    }

    await expectLater(once.run(initialize), throwsStateError);
    await once.run(initialize);

    expect(runs, 2);
  });
}
