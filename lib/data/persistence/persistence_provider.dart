import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logging/logger_provider.dart';
import 'gtg_persistence.dart';

final persistenceProvider = Provider<GtgPersistence>((ref) {
  return GtgPersistence(logger: ref.read(appLoggerProvider));
});
