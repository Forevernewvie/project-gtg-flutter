abstract interface class ReminderPermissionClient {
  Future<bool> requestPermission();
}

class FakeReminderPermissionClient implements ReminderPermissionClient {
  const FakeReminderPermissionClient({required this.granted});

  final bool granted;

  @override
  Future<bool> requestPermission() async {
    return granted;
  }
}
