/// Utility functions for time formatting across the app
class TimeUtils {
  /// Format a time range with sophisticated styling
  /// Example: "7 - 9 PM", "8:15 AM - 12:30 PM"
  static String formatTimeRange(DateTime startTime, DateTime endTime) {
    final startHour = startTime.hour;
    final startMinute = startTime.minute;
    final startPeriod = startHour >= 12 ? 'PM' : 'AM';
    final startDisplayHour = startHour > 12 ? startHour - 12 : (startHour == 0 ? 12 : startHour);
    
    final endHour = endTime.hour;
    final endMinute = endTime.minute;
    final endPeriod = endHour >= 12 ? 'PM' : 'AM';
    final endDisplayHour = endHour > 12 ? endHour - 12 : (endHour == 0 ? 12 : endHour);
    
    // Format time without trailing zeros
    String formatTimeComponent(int hour, int minute, bool includePeriod, String period) {
      final minuteStr = minute == 0 ? '' : ':${minute.toString().padLeft(2, '0')}';
      final periodStr = includePeriod ? ' $period' : '';
      return '$hour$minuteStr$periodStr';
    }
    
    // Check if we span from morning to afternoon/evening (AM to PM)
    final spansAmPm = startPeriod != endPeriod;
    
    final startTimeStr = formatTimeComponent(startDisplayHour, startMinute, spansAmPm, startPeriod);
    final endTimeStr = formatTimeComponent(endDisplayHour, endMinute, true, endPeriod);
    
    return '$startTimeStr - $endTimeStr';
  }
  
  /// Format a time range using start time and duration
  /// Example: "7 - 9 PM", "8:15 AM - 12:30 PM"
  static String formatTimeRangeWithDuration(DateTime startTime, Duration duration) {
    final endTime = startTime.add(duration);
    return formatTimeRange(startTime, endTime);
  }
  
  /// Format a full practice date and time
  /// Example: "Mon, Jan 15 • 7 - 9 PM"
  static String formatPracticeDateTime(DateTime dateTime, Duration duration) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    final weekday = weekdays[dateTime.weekday - 1];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    
    final timeRange = formatTimeRangeWithDuration(dateTime, duration);
    
    return '$weekday, $month $day • $timeRange';
  }
  
  /// Format just the day name from weekday number
  /// Example: "Monday" from DateTime.weekday
  static String formatDayName(int weekday) {
    const dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return dayNames[weekday - 1];
  }
  
  /// Format short day name from weekday number  
  /// Example: "Mon" from DateTime.weekday
  static String formatShortDayName(int weekday) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return dayNames[weekday - 1];
  }
}