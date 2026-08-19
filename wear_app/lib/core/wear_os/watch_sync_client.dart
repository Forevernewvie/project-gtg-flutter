import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watch_connectivity/watch_connectivity.dart';

class WatchSyncClient {
  final WatchConnectivity _watch = WatchConnectivity();

  Future<void> sendLogSet() async {
    // Send message to the phone app
    await _watch.sendMessage({'action': 'log_set'});
  }
}

final watchSyncClientProvider = Provider<WatchSyncClient>((ref) {
  return WatchSyncClient();
});
