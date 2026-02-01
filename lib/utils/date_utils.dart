import 'package:intl/intl.dart';
import 'constants.dart';

class DateUtils {
  /// Format DateTime to display format (dd/MM/yyyy)
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.displayDateFormat).format(date);
  }
  
  /// Format DateTime to database format (yyyy-MM-dd)
  static String formatDateForDatabase(DateTime date) {
    return DateFormat(AppConstants.databaseDateFormat).format(date);
  }
  
  /// Parse database date string to DateTime
  static DateTime? parseDatabaseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateFormat(AppConstants.databaseDateFormat).parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  /// Format time to display format (HH:mm)
  static String formatTime(DateTime time) {
    return DateFormat(AppConstants.displayTimeFormat).format(time);
  }
  
  /// Format DateTime to display format with time
  static String formatDateTime(DateTime dateTime) {
    return DateFormat(AppConstants.displayDateTimeFormat).format(dateTime);
  }
  
  /// Get today's date at midnight
  static DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
  
  /// Get yesterday's date at midnight
  static DateTime get yesterday {
    return today.subtract(const Duration(days: 1));
  }
  
  /// Get date for last week (7 days ago)
  static DateTime get lastWeek {
    return today.subtract(const Duration(days: 7));
  }
  
  /// Get start of week (Monday)
  static DateTime getStartOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }
  
  /// Get end of week (Sunday)
  static DateTime getEndOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.add(Duration(days: 7 - weekday));
  }
  
  /// Get start of month
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
  
  /// Get end of month
  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }
  
  /// Get start of year
  static DateTime getStartOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }
  
  /// Get end of year
  static DateTime getEndOfYear(DateTime date) {
    return DateTime(date.year, 12, 31);
  }
  
  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  /// Get date range for period type
  static DateRange getDateRangeForPeriod(String period, DateTime selectedDate) {
    switch (period.toLowerCase()) {
      case 'daily':
        return DateRange(selectedDate, selectedDate);
      case 'weekly':
        return DateRange(
          getStartOfWeek(selectedDate),
          getEndOfWeek(selectedDate),
        );
      case 'monthly':
        return DateRange(
          getStartOfMonth(selectedDate),
          getEndOfMonth(selectedDate),
        );
      case 'yearly':
        return DateRange(
          getStartOfYear(selectedDate),
          getEndOfYear(selectedDate),
        );
      default:
        return DateRange(selectedDate, selectedDate);
    }
  }
}

class DateRange {
  final DateTime start;
  final DateTime end;
  
  DateRange(this.start, this.end);
  
  bool contains(DateTime date) {
    return (date.isAfter(start) || isSameDay(date, start)) &&
           (date.isBefore(end) || isSameDay(date, end));
  }
  
  bool isSameDay(DateTime date1, DateTime date2) {
    return DateUtils.isSameDay(date1, date2);
  }
  
  int get dayCount {
    return end.difference(start).inDays + 1;
  }
}
