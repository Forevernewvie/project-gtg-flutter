import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'gtg_persistence.dart';

final persistenceProvider = Provider<GtgPersistence>((ref) {
  return GtgPersistence();
});
