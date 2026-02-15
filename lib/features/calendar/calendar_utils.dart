int daysInMonth(DateTime month) {
  // Day 0 of next month is the last day of current month.
  return DateTime(month.year, month.month + 1, 0).day;
}

DateTime addMonths(DateTime monthStart, int deltaMonths) {
  return DateTime(monthStart.year, monthStart.month + deltaMonths, 1);
}

String ymd(DateTime date) {
  final mm = date.month.toString().padLeft(2, '0');
  final dd = date.day.toString().padLeft(2, '0');
  return '${date.year}-$mm-$dd';
}

List<DateTime?> buildMonthGrid(DateTime monthStart) {
  final firstDay = DateTime(monthStart.year, monthStart.month, 1);
  final offset = firstDay.weekday % 7; // Sunday=0 ... Saturday=6
  final count = daysInMonth(firstDay);
  final total = offset + count;
  final padded = ((total + 6) ~/ 7) * 7;

  final cells = List<DateTime?>.filled(padded, null);
  for (var i = 0; i < count; i++) {
    cells[offset + i] = DateTime(monthStart.year, monthStart.month, i + 1);
  }
  return cells;
}
