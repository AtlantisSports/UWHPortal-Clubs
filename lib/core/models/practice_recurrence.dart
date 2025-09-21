/// Recurrence pattern definitions for practice scheduling
library;

/// Types of recurrence patterns available
enum RecurrenceType {
  weekly,          // Every week on the same day
  biweekly,        // Every 2 weeks on the same day  
  monthly,         // Same day of month (e.g., 15th of every month)
  monthlyByWeek,   // Same week and day (e.g., 2nd Tuesday of every month)
  custom,          // Custom interval in days
  none,            // One-time only (for special events)
}

/// Recurrence pattern configuration
class RecurrencePattern {
  final RecurrenceType type;
  final int interval; // For weekly: 1=weekly, 2=biweekly, etc. For custom: days between
  final int? weekOfMonth; // For monthlyByWeek: 1=first, 2=second, 3=third, 4=fourth, -1=last
  final int? dayOfMonth; // For monthly: 1-31, day of month
  final DateTime? endDate; // Optional end date for the recurrence
  final int? maxOccurrences; // Optional max number of occurrences
  
  const RecurrencePattern({
    required this.type,
    this.interval = 1,
    this.weekOfMonth,
    this.dayOfMonth,
    this.endDate,
    this.maxOccurrences,
  });

  /// Weekly recurrence (most common)
  const RecurrencePattern.weekly() : this(type: RecurrenceType.weekly, interval: 1);
  
  /// Biweekly recurrence
  const RecurrencePattern.biweekly() : this(type: RecurrenceType.weekly, interval: 2);
  
  /// Monthly on same date (e.g., 15th of every month)
  const RecurrencePattern.monthlyByDate(int dayOfMonth) 
    : this(type: RecurrenceType.monthly, dayOfMonth: dayOfMonth);
  
  /// Monthly by week position (e.g., 2nd Tuesday, 4th Thursday, last Friday)
  const RecurrencePattern.monthlyByWeek(int weekOfMonth) 
    : this(type: RecurrenceType.monthlyByWeek, weekOfMonth: weekOfMonth);
  
  /// Custom interval in days
  const RecurrencePattern.customDays(int days) 
    : this(type: RecurrenceType.custom, interval: days);
  
  /// One-time only (no recurrence)
  const RecurrencePattern.none() : this(type: RecurrenceType.none);

  /// Generate a human-readable description
  String get description {
    switch (type) {
      case RecurrenceType.weekly:
        if (interval == 1) return 'Weekly';
        if (interval == 2) return 'Every 2 weeks';
        return 'Every $interval weeks';
        
      case RecurrenceType.biweekly:
        return 'Every 2 weeks';
        
      case RecurrenceType.monthly:
        if (dayOfMonth != null) {
          return 'Monthly on the ${_ordinal(dayOfMonth!)}';
        }
        return 'Monthly';
        
      case RecurrenceType.monthlyByWeek:
        if (weekOfMonth != null) {
          final weekDesc = weekOfMonth == -1 ? 'last' : _ordinal(weekOfMonth!);
          return 'Monthly on the $weekDesc occurrence';
        }
        return 'Monthly by week';
        
      case RecurrenceType.custom:
        if (interval == 1) return 'Daily';
        return 'Every $interval days';
        
      case RecurrenceType.none:
        return 'One-time only';
    }
  }

  /// Helper to convert numbers to ordinals (1st, 2nd, 3rd, etc.)
  String _ordinal(int number) {
    if (number >= 11 && number <= 13) return '${number}th';
    switch (number % 10) {
      case 1: return '${number}st';
      case 2: return '${number}nd'; 
      case 3: return '${number}rd';
      default: return '${number}th';
    }
  }

  /// Convert to JSON for storage/API
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'interval': interval,
      if (weekOfMonth != null) 'weekOfMonth': weekOfMonth,
      if (dayOfMonth != null) 'dayOfMonth': dayOfMonth,
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      if (maxOccurrences != null) 'maxOccurrences': maxOccurrences,
    };
  }

  /// Create from JSON
  factory RecurrencePattern.fromJson(Map<String, dynamic> json) {
    return RecurrencePattern(
      type: RecurrenceType.values.firstWhere((e) => e.name == json['type']),
      interval: json['interval'] ?? 1,
      weekOfMonth: json['weekOfMonth'],
      dayOfMonth: json['dayOfMonth'],
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      maxOccurrences: json['maxOccurrences'],
    );
  }

  /// Check if this pattern should generate a practice on a given date
  bool shouldOccurOn(DateTime date, DateTime patternStartDate) {
    switch (type) {
      case RecurrenceType.weekly:
        final daysDiff = date.difference(patternStartDate).inDays;
        return daysDiff >= 0 && 
               daysDiff % (7 * interval) == 0 &&
               date.weekday == patternStartDate.weekday;
               
      case RecurrenceType.biweekly:
        final daysDiff = date.difference(patternStartDate).inDays;
        return daysDiff >= 0 && 
               daysDiff % (7 * 2) == 0 &&
               date.weekday == patternStartDate.weekday;
               
      case RecurrenceType.monthly:
        if (dayOfMonth == null) return false;
        return date.day == dayOfMonth &&
               date.isAfter(patternStartDate.subtract(const Duration(days: 1)));
               
      case RecurrenceType.monthlyByWeek:
        if (weekOfMonth == null) return false;
        return _isNthWeekdayOfMonth(date, patternStartDate.weekday, weekOfMonth!) &&
               date.isAfter(patternStartDate.subtract(const Duration(days: 1)));
               
      case RecurrenceType.custom:
        final daysDiff = date.difference(patternStartDate).inDays;
        return daysDiff >= 0 && daysDiff % interval == 0;
        
      case RecurrenceType.none:
        return date.year == patternStartDate.year &&
               date.month == patternStartDate.month &&
               date.day == patternStartDate.day;
    }
  }

  /// Check if a date is the nth occurrence of a weekday in its month
  bool _isNthWeekdayOfMonth(DateTime date, int targetWeekday, int weekOfMonth) {
    if (date.weekday != targetWeekday) return false;
    
    if (weekOfMonth == -1) {
      // Last occurrence of the weekday in the month
      final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
      var lastOccurrence = lastDayOfMonth;
      while (lastOccurrence.weekday != targetWeekday) {
        lastOccurrence = lastOccurrence.subtract(const Duration(days: 1));
      }
      return date.day == lastOccurrence.day;
    } else {
      // Nth occurrence of the weekday
      final firstDayOfMonth = DateTime(date.year, date.month, 1);
      var firstOccurrence = firstDayOfMonth;
      while (firstOccurrence.weekday != targetWeekday) {
        firstOccurrence = firstOccurrence.add(const Duration(days: 1));
      }
      final nthOccurrence = firstOccurrence.add(Duration(days: 7 * (weekOfMonth - 1)));
      return date.day == nthOccurrence.day && nthOccurrence.month == date.month;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecurrencePattern &&
           other.type == type &&
           other.interval == interval &&
           other.weekOfMonth == weekOfMonth &&
           other.dayOfMonth == dayOfMonth &&
           other.endDate == endDate &&
           other.maxOccurrences == maxOccurrences;
  }

  @override
  int get hashCode {
    return Object.hash(type, interval, weekOfMonth, dayOfMonth, endDate, maxOccurrences);
  }

  @override
  String toString() {
    return 'RecurrencePattern($description)';
  }
}