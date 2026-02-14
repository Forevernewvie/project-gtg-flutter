abstract interface class ReminderNotificationClient {
  Future<void> cancelAll();

  Future<void> scheduleBatch({
    required List<DateTime> times,
    required String title,
    required String body,
  });
}

class FakeReminderNotificationClient implements ReminderNotificationClient {
  const FakeReminderNotificationClient();

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> scheduleBatch({
    required List<DateTime> times,
    required String title,
    required String body,
  }) async {}
}
