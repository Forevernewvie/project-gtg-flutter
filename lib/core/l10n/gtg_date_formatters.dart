import 'package:intl/intl.dart';

abstract final class GtgDateFormatters {
  static String monthLabel(DateTime month, String localeName) {
    return DateFormat.yMMMM(localeName).format(month);
  }

  /// ko: "2월 14일 (토)"
  /// en: "Feb 14 (Sat)"
  static String monthDayWithWeekday(DateTime date, String localeName) {
    if (localeName.toLowerCase().startsWith('ko')) {
      return DateFormat('M월 d일 (E)', localeName).format(date);
    }
    return DateFormat('MMM d (EEE)', localeName).format(date);
  }

  /// Returns weekday labels starting from Sunday (Sun..Sat / 일..토).
  static List<String> weekdayLabelsSunFirst(String localeName) {
    final fmt = DateFormat.E(localeName);

    // 2023-01-01 is a Sunday.
    final base = DateTime.utc(2023, 1, 1);
    return List<String>.generate(
      7,
      (i) => fmt.format(base.add(Duration(days: i))),
      growable: false,
    );
  }

  static String timeHm(DateTime dateTime, String localeName) {
    return DateFormat.Hm(localeName).format(dateTime);
  }

  static String monthDay(DateTime dateTime, String localeName) {
    return DateFormat.Md(localeName).format(dateTime);
  }
}
