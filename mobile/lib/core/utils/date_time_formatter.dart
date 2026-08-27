import 'package:intl/intl.dart';

class DateTimeFormatter {
  DateTimeFormatter._();

  static String formatShortDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
  }
}
