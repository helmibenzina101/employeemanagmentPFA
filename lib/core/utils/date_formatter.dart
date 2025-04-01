import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DateFormatter {
  static const String frenchLocale = 'fr_FR';

  // Format DateTime to String
  static String formatDateTime(DateTime dateTime, {String pattern = 'dd/MM/yyyy HH:mm'}) {
    return DateFormat(pattern, frenchLocale).format(dateTime);
  }

  static String formatDate(DateTime dateTime, {String pattern = 'dd/MM/yyyy'}) {
    return DateFormat(pattern, frenchLocale).format(dateTime);
  }

  static String formatTime(DateTime dateTime, {String pattern = 'HH:mm'}) {
    return DateFormat(pattern, frenchLocale).format(dateTime);
  }

  // Format Timestamp to String
   static String formatTimestamp(Timestamp timestamp, {String pattern = 'dd/MM/yyyy HH:mm'}) {
    return formatDateTime(timestamp.toDate(), pattern: pattern);
  }

   static String formatTimestampDate(Timestamp timestamp, {String pattern = 'dd/MM/yyyy'}) {
    return formatDate(timestamp.toDate(), pattern: pattern);
  }

   static String formatTimestampTime(Timestamp timestamp, {String pattern = 'HH:mm'}) {
    return formatTime(timestamp.toDate(), pattern: pattern);
  }


  // Format Duration to String (e.g., "8h 30m")
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    // String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    int hours = duration.inHours;

    if (hours > 0) {
      return "${hours}h ${twoDigitMinutes}m";
    } else {
      return "${twoDigitMinutes}m";
    }
    // return "${twoDigits(duration.inHours)}h ${twoDigitMinutes}m ${twoDigitSeconds}s";
  }

   // Parse String to DateTime (use with caution, ensure format matches)
   static DateTime? parseDate(String dateString, {String pattern = 'dd/MM/yyyy'}) {
     try {
       return DateFormat(pattern, frenchLocale).parseStrict(dateString);
     } catch (e) {
       return null; // Return null if parsing fails
     }
   }

   // Get Start of Day
   static DateTime startOfDay(DateTime dateTime) {
     return DateTime(dateTime.year, dateTime.month, dateTime.day);
   }

   // Get End of Day
   static DateTime endOfDay(DateTime dateTime) {
      return DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999);
   }
}