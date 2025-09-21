/// Practice pattern model - template for recurring practices with NO date references
library;

import 'practice_recurrence.dart';

/// Days of the week for practice patterns (no date, just day identifier)
enum PatternDay {
  monday,
  tuesday, 
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  /// Get display name
  String get displayName {
    switch (this) {
      case PatternDay.monday: return 'Monday';
      case PatternDay.tuesday: return 'Tuesday';
      case PatternDay.wednesday: return 'Wednesday';
      case PatternDay.thursday: return 'Thursday';
      case PatternDay.friday: return 'Friday';
      case PatternDay.saturday: return 'Saturday';
      case PatternDay.sunday: return 'Sunday';
    }
  }

  /// Get short display name
  String get shortName {
    switch (this) {
      case PatternDay.monday: return 'Mon';
      case PatternDay.tuesday: return 'Tue';
      case PatternDay.wednesday: return 'Wed';
      case PatternDay.thursday: return 'Thu';
      case PatternDay.friday: return 'Fri';
      case PatternDay.saturday: return 'Sat';
      case PatternDay.sunday: return 'Sun';
    }
  }

  /// Convert to DateTime weekday constant for date calculations
  int get weekdayNumber {
    switch (this) {
      case PatternDay.monday: return DateTime.monday;
      case PatternDay.tuesday: return DateTime.tuesday;
      case PatternDay.wednesday: return DateTime.wednesday;
      case PatternDay.thursday: return DateTime.thursday;
      case PatternDay.friday: return DateTime.friday;
      case PatternDay.saturday: return DateTime.saturday;
      case PatternDay.sunday: return DateTime.sunday;
    }
  }

  /// Create from DateTime weekday
  static PatternDay fromWeekday(int weekday) {
    switch (weekday) {
      case DateTime.monday: return PatternDay.monday;
      case DateTime.tuesday: return PatternDay.tuesday;
      case DateTime.wednesday: return PatternDay.wednesday;
      case DateTime.thursday: return PatternDay.thursday;
      case DateTime.friday: return PatternDay.friday;
      case DateTime.saturday: return PatternDay.saturday;
      case DateTime.sunday: return PatternDay.sunday;
      default: throw ArgumentError('Invalid weekday: $weekday');
    }
  }

  /// Create from string name
  static PatternDay fromString(String dayName) {
    switch (dayName.toLowerCase()) {
      case 'monday': return PatternDay.monday;
      case 'tuesday': return PatternDay.tuesday;
      case 'wednesday': return PatternDay.wednesday;
      case 'thursday': return PatternDay.thursday;
      case 'friday': return PatternDay.friday;
      case 'saturday': return PatternDay.saturday;
      case 'sunday': return PatternDay.sunday;
      default: throw ArgumentError('Invalid day name: $dayName');
    }
  }
}

/// Time of day for practice patterns
class PatternTime {
  final int hour;   // 0-23
  final int minute; // 0-59

  const PatternTime(this.hour, this.minute);

  /// Create from time string like "19:30" or "7:30 PM"
  factory PatternTime.parse(String timeStr) {
    // Handle formats like "7:30 PM", "19:30", etc.
    final cleaned = timeStr.trim().toUpperCase();
    
    if (cleaned.contains('PM') || cleaned.contains('AM')) {
      final isPM = cleaned.contains('PM');
      final timeOnly = cleaned.replaceAll(RegExp(r'[AP]M'), '').trim();
      final parts = timeOnly.split(':');
      var hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      
      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      
      return PatternTime(hour, minute);
    } else {
      final parts = cleaned.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      return PatternTime(hour, minute);
    }
  }

  /// Format as 24-hour time string
  String to24HourString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Format as 12-hour time string
  String to12HourString() {
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final period = hour < 12 ? 'AM' : 'PM';
    final minuteStr = minute == 0 ? '' : ':${minute.toString().padLeft(2, '0')}';
    return '$displayHour$minuteStr $period';
  }

  @override
  String toString() => to12HourString();

  Map<String, dynamic> toJson() => {'hour': hour, 'minute': minute};
  
  factory PatternTime.fromJson(Map<String, dynamic> json) {
    return PatternTime(json['hour'], json['minute']);
  }

  @override
  bool operator ==(Object other) {
    return other is PatternTime && other.hour == hour && other.minute == minute;
  }

  @override
  int get hashCode => Object.hash(hour, minute);
}

/// Practice pattern - template for recurring practices (NO dates, just patterns)
class PracticePattern {
  final String id;              // Unique pattern ID (e.g., "denver-sun-1100-vmac-1")
  final String clubId;          // Club this pattern belongs to
  final String title;           // Display title (e.g., "Sunday Morning")
  final String description;     // Practice description
  final PatternDay day;         // Day of week (NO date reference)
  final PatternTime startTime;  // Start time (NO date reference)
  final Duration duration;      // How long the practice lasts
  final String location;        // Location name
  final String address;         // Full address
  final String? tag;            // Practice level/type tag
  final RecurrencePattern recurrence; // How often this pattern repeats
  final DateTime? patternStartDate;   // When this pattern first started (for recurrence calculations)
  final DateTime? patternEndDate;     // When this pattern ends (optional)
  
  const PracticePattern({
    required this.id,
    required this.clubId,
    required this.title,
    required this.description,
    required this.day,
    required this.startTime,
    required this.duration,
    required this.location,
    required this.address,
    this.tag,
    this.recurrence = const RecurrencePattern.weekly(),
    this.patternStartDate,
    this.patternEndDate,
  });

  /// Get end time for this pattern
  PatternTime get endTime {
    final endMinutes = startTime.hour * 60 + startTime.minute + duration.inMinutes;
    final endHour = (endMinutes ~/ 60) % 24;
    final endMin = endMinutes % 60;
    return PatternTime(endHour, endMin);
  }

  /// Format time range string
  String get timeRangeString {
    return '${startTime.to12HourString()} - ${endTime.to12HourString()}';
  }

  /// Get full display string
  String get fullDisplayString {
    return '${day.displayName} $timeRangeString • $location';
  }

  /// Check if this pattern should generate a practice on a given date
  bool shouldGeneratePracticeOn(DateTime date) {
    // Check if pattern is active
    if (patternStartDate != null && date.isBefore(patternStartDate!)) return false;
    if (patternEndDate != null && date.isAfter(patternEndDate!)) return false;
    
    // Check if date matches this pattern's day
    if (date.weekday != day.weekdayNumber) return false;
    
    // Check recurrence pattern
    final startDate = patternStartDate ?? DateTime(2025, 9, 1); // Default start
    return recurrence.shouldOccurOn(date, startDate);
  }

  /// Generate a practice instance for a specific date
  /// NOTE: This returns a Map that can be used to create a Practice object
  Map<String, dynamic> generatePracticeData(DateTime date) {
    final practiceDateTime = DateTime(
      date.year,
      date.month, 
      date.day,
      startTime.hour,
      startTime.minute,
    );

    return {
      'id': '${id.replaceAll('-', '_')}_${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}',
      'clubId': clubId,
      'patternId': id,
      'title': title,
      'description': description,
      'dateTime': practiceDateTime.toIso8601String(),
      'location': location,
      'address': address,
      'duration': duration.inMinutes,
      'tag': tag,
    };
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clubId': clubId,
      'title': title,
      'description': description,
      'day': day.name,
      'startTime': startTime.toJson(),
      'duration': duration.inMinutes,
      'location': location,
      'address': address,
      if (tag != null) 'tag': tag,
      'recurrence': recurrence.toJson(),
      if (patternStartDate != null) 'patternStartDate': patternStartDate!.toIso8601String(),
      if (patternEndDate != null) 'patternEndDate': patternEndDate!.toIso8601String(),
    };
  }

  /// Create from JSON
  factory PracticePattern.fromJson(Map<String, dynamic> json) {
    return PracticePattern(
      id: json['id'],
      clubId: json['clubId'],
      title: json['title'],
      description: json['description'],
      day: PatternDay.values.firstWhere((d) => d.name == json['day']),
      startTime: PatternTime.fromJson(json['startTime']),
      duration: Duration(minutes: json['duration']),
      location: json['location'],
      address: json['address'],
      tag: json['tag'],
      recurrence: json['recurrence'] != null 
        ? RecurrencePattern.fromJson(json['recurrence'])
        : const RecurrencePattern.weekly(),
      patternStartDate: json['patternStartDate'] != null 
        ? DateTime.parse(json['patternStartDate']) 
        : null,
      patternEndDate: json['patternEndDate'] != null 
        ? DateTime.parse(json['patternEndDate']) 
        : null,
    );
  }

  /// Create a copy with modifications
  PracticePattern copyWith({
    String? id,
    String? clubId,
    String? title,
    String? description,
    PatternDay? day,
    PatternTime? startTime,
    Duration? duration,
    String? location,
    String? address,
    String? tag,
    RecurrencePattern? recurrence,
    DateTime? patternStartDate,
    DateTime? patternEndDate,
  }) {
    return PracticePattern(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      title: title ?? this.title,
      description: description ?? this.description,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      location: location ?? this.location,
      address: address ?? this.address,
      tag: tag ?? this.tag,
      recurrence: recurrence ?? this.recurrence,
      patternStartDate: patternStartDate ?? this.patternStartDate,
      patternEndDate: patternEndDate ?? this.patternEndDate,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PracticePattern && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PracticePattern($fullDisplayString, ${recurrence.description})';
  }
}