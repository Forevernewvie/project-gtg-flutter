/// Date helpers used across features.
///
/// Keep these as pure functions so they're easy to test.
DateTime startOfDay(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

DateTime startOfWeek(DateTime dateTime) {
  final dayStart = startOfDay(dateTime);
  // DateTime.weekday: Mon=1 ... Sun=7
  final daysFromMonday = dayStart.weekday - DateTime.monday;
  return dayStart.subtract(Duration(days: daysFromMonday));
}

DateTime startOfMonth(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, 1);
}

bool isInRange(
  DateTime dateTime,
  DateTime startInclusive,
  DateTime endExclusive,
) {
  return !dateTime.isBefore(startInclusive) && dateTime.isBefore(endExclusive);
}
