import 'package:intl/intl.dart';

class DateUtils {
  // Format date for display
  static String formatDate(DateTime date, {String format = 'MMM dd, yyyy'}) {
    return DateFormat(format).format(date);
  }

  // Format date with day name
  static String formatDateWithDay(DateTime date) {
    return DateFormat('EEE, MMM dd, yyyy').format(date);
  }

  // Format time
  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  // Get days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  // Check if two dates are the same day
  static bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  // Add days to date
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  // Subtract days from date
  static DateTime subtractDays(DateTime date, int days) {
    return date.subtract(Duration(days: days));
  }

  // Get cycle day (day number in cycle starting from period start)
  static int getCycleDay(DateTime periodStartDate, DateTime currentDate) {
    return daysBetween(periodStartDate, currentDate) + 1;
  }

  // Get week number in pregnancy
  static int getPregnancyWeek(DateTime conceptionDate, DateTime currentDate) {
    final days = daysBetween(conceptionDate, currentDate);
    return (days / 7).floor();
  }

  // Get days in month
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  // Get first day of month
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Get last day of month
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  // Format relative date (e.g., "Today", "Yesterday", "2 days ago")
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = startOfDay(now);
    final dateDay = startOfDay(date);
    final difference = daysBetween(dateDay, today);

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference == -1) {
      return 'Tomorrow';
    } else if (difference > 1 && difference <= 7) {
      return '$difference days ago';
    } else if (difference < -1 && difference >= -7) {
      return 'In ${-difference} days';
    } else {
      return formatDate(date);
    }
  }

  // Get month name
  static String getMonthName(int month) {
    return DateFormat('MMMM').format(DateTime(2024, month));
  }

  // Get short month name
  static String getShortMonthName(int month) {
    return DateFormat('MMM').format(DateTime(2024, month));
  }

  // Get day name
  static String getDayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  // Get short day name
  static String getShortDayName(DateTime date) {
    return DateFormat('EEE').format(date);
  }
}
