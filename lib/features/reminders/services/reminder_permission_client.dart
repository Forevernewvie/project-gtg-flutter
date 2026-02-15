abstract interface class ReminderPermissionClient {
  /// Returns whether notifications are currently enabled for the app.
  ///
  /// Must NOT trigger any system permission prompts.
  Future<bool> hasPermission();

  Future<bool> requestPermission();
}

class FakeReminderPermissionClient implements ReminderPermissionClient {
  const FakeReminderPermissionClient({required this.granted});

  final bool granted;

  @override
  Future<bool> hasPermission() async {
    return granted;
  }

  @override
  Future<bool> requestPermission() async {
    return granted;
  }
}
