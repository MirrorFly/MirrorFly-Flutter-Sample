part of 'utils.dart';

class DateTimeUtils {

  /// Converts a Duration object to a formatted string representation of time.
  ///
  /// @param duration The Duration object to be converted.
  /// @return A string representing the duration in the format "HH:MM:SS".
  static String durationToString(Duration duration) {
    debugPrint("duration conversion $duration");
    String hours = (duration.inHours == 00) ? "" : "${duration.inHours
        .toStringAsFixed(0).padLeft(2, '0')}:"; // Get hours
    int minutes = duration.inMinutes % 60; // Get minutes
    var seconds = ((duration.inSeconds % 60)).toStringAsFixed(0).padLeft(
        2, '0');
    return '$hours${minutes.toStringAsFixed(0).padLeft(2, '0')}:$seconds';
  }


  /// Converts a timestamp represented as microseconds since epoch to a formatted date string.
  /// @param microseconds The timestamp to convert, represented in microseconds since epoch.
  /// @param format The desired format of the output date string.
  /// @return The formatted date string representing the converted timestamp.
  static String convertTimeStampToDateString(int microseconds, String format) {
    var calendar = DateTime.fromMicrosecondsSinceEpoch(microseconds);
    return DateFormat(format).format(calendar);
  }

  /// Returns the name of the month corresponding to the given integer.
  ///
  /// @param num The integer representing the month (0 for January, 1 for February, etc.).
  /// @return The name of the month as a string, or an empty string if the input is out of range.
  static String getMonth(int num) {
    var month = "";
    var dateFormatSymbols = DateFormat().dateSymbols.STANDALONEMONTHS;
    var months = dateFormatSymbols;
    if (num <= 11) {
      month = months[num];
    }
    return month;
  }

  /// Generates a header message indicating the date of a message based on its sending time,
  /// allowing customization of the date format.
  ///
  /// @param messageSentTime The timestamp of the message sending time.
  /// @param format Optional parameter that specifies the format of the date string.
  ///               Defaults to "MMMM dd, yyyy".
  /// @return A string representing the date of the message formatted according to the given
  ///         format or the default format if no format is specified.
  static String getDateHeaderMessage({required int messageSentTime, String format = "MMMM dd, yyyy"}) {
    // Convert message sending time to date string
    return getDateString(messageSentTime, format);
  }

  /// Generates a Date String indicating the date of a call based on its call log time.
  ///
  /// @param microSeconds The timestamp of the call log time.
  /// @return A string representing the date of the call, or a translated string indicating
  ///         'Today', 'Yesterday', or an DateString(dd-MMM) string if the call log date is not relevant.
  static String getCallLogDate({required int microSeconds, String format = "dd-MMM"}) {
    return getDateString(microSeconds, format);
  }

  /// Converts a timestamp in microseconds to a formatted date string according to the specified format.
  ///
  /// @param microSeconds The timestamp in microseconds.
  /// @param format The format of the date string to be returned.
  /// @return The formatted date string or an empty string if the date is not today, yesterday, or a valid date.
  static String getDateString(int microSeconds, String format) {
    // Convert the timestamp to a date string
    var date = convertTimeStampToDateString(microSeconds, format);

    // Check if the message date is today
    if (isToday(microSeconds)) {
      return getTranslated("today");
    }
    // Check if the message date is yesterday
    else if (isYesterday(microSeconds)) {
      return getTranslated("yesterday");
    }
    // Check if the message date is not a default value
    else if (!date.contains("1970")) {
      return date;
    }
    // Return an empty string if none of the conditions are met
    return "";
  }


  /// Checks if the given [microseconds] value corresponds to the current date.
  ///
  /// Returns true if the date extracted from the [microseconds] value matches
  /// the current date; otherwise, returns false.
  ///
  /// Parameters:
  /// - [microseconds]: The microseconds value representing a specific date and time.
  ///
  /// Returns:
  /// - true if the date matches today's date; false otherwise.
  static bool isToday(int microseconds) {
    var calendar = DateTime.fromMicrosecondsSinceEpoch(microseconds);
    final now = DateTime.now();
    return now.day == calendar.day && now.month == calendar.month && now.year == calendar.year;
  }

  /// Checks if the provided microseconds represent a date that occurred yesterday
  ///
  /// Takes a [microseconds] value and converts it into a [DateTime] object.
  /// Compares this date with yesterday's date to determine if they match
  /// in terms of day, month, and year.
  ///
  /// Returns true if the date represented by [microseconds] is yesterday;
  /// otherwise, returns false.
  static bool isYesterday(int microseconds) {
    var calendar = DateTime.fromMicrosecondsSinceEpoch(microseconds);
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.day == calendar.day &&
        yesterday.month == calendar.month &&
        yesterday.year == calendar.year;
  }



  /// Checks if the given integer represents a two-digit date, and returns it in a standardized format.
  /// If the integer is not two digits long, it prefixes a '0' to the date.
  ///
  /// @param date The integer representation of the date to be checked and formatted.
  /// @return A string representing the date in a two-digit format, with a leading '0' if necessary.
  static String convertTwoDigitsForDate(int date) {
    if (date.toString().length != 2) {
      return "0$date";
    } else {
      return date.toString();
    }
  }


  static String getRecentChatTime(BuildContext context, int? epochTime) {
    if (epochTime == null) return "";
    if (epochTime == 0) return "";
    var convertedTime = epochTime; // / 1000;
    //messageDate.time = convertedTime
    var hourTime = manipulateMessageTime(context, DateTime.fromMicrosecondsSinceEpoch(convertedTime));
    var currentYear = DateTime.now().year;
    var calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
    var time = (currentYear == calendar.year)
        ? DateFormat("dd-MMM").format(calendar)
        : DateFormat("yyyy/MM/dd").format(calendar);
    return (equalsWithYesterday(calendar, getTranslated("today")))
        ? hourTime
        : (equalsWithYesterday(calendar, getTranslated("yesterday")))
        ? getTranslated("yesterday").toUpperCase()
        : time;
  }

}