/// Example practice patterns with different recurrence patterns
library;

import '../models/practice_pattern.dart';
import '../models/practice_recurrence.dart';

class ExamplePracticePatterns {
  /// Example patterns showing different recurrence types
  static List<PracticePattern> getExamplePatterns() {
    return [
      // Weekly practice - most common
      PracticePattern(
        id: 'denver-sun-1100-vmac-1',
        clubId: 'denver-uwh',
        title: 'Sunday Morning',
        description: 'Weekly mixed-level practice with skills development',
        day: PatternDay.sunday,
        startTime: const PatternTime(11, 0),
        duration: const Duration(hours: 2),
        location: 'VMAC',
        address: '5310 E 136th Ave, Thornton, CO',
        tag: 'Open',
        recurrence: const RecurrencePattern.weekly(),
        patternStartDate: DateTime(2025, 9, 1),
      ),

      // Biweekly practice (every 2 weeks)
      PracticePattern(
        id: 'denver-sat-1400-carmody-1',
        clubId: 'denver-uwh',
        title: 'Saturday Intensive',
        description: 'Biweekly high-intensity training session',
        day: PatternDay.saturday,
        startTime: const PatternTime(14, 0),
        duration: const Duration(hours: 3),
        location: 'Carmody Recreation Center',
        address: '1510 W 84th Ave, Westminster, CO',
        tag: 'Advanced',
        recurrence: const RecurrencePattern.biweekly(),
        patternStartDate: DateTime(2025, 9, 7), // First Saturday
      ),

      // Monthly by week (2nd Tuesday of every month)
      PracticePattern(
        id: 'denver-tue-1930-vmac-monthly',
        clubId: 'denver-uwh',
        title: 'Monthly Skills Workshop',
        description: 'Monthly specialized skills workshop',
        day: PatternDay.tuesday,
        startTime: const PatternTime(19, 30),
        duration: const Duration(hours: 2),
        location: 'VMAC',
        address: '5310 E 136th Ave, Thornton, CO',
        tag: 'Skills',
        recurrence: const RecurrencePattern.monthlyByWeek(2), // 2nd Tuesday
        patternStartDate: DateTime(2025, 9, 10), // 2nd Tuesday of September
      ),

      // Monthly by date (15th of every month)
      PracticePattern(
        id: 'denver-fri-2000-carmody-monthly',
        clubId: 'denver-uwh',
        title: 'Mid-Month Scrimmage',
        description: 'Monthly scrimmage and social event',
        day: PatternDay.friday,
        startTime: const PatternTime(20, 0),
        duration: const Duration(hours: 2, minutes: 30),
        location: 'Carmody Recreation Center',
        address: '1510 W 84th Ave, Westminster, CO',
        tag: 'Social',
        recurrence: const RecurrencePattern.monthlyByDate(15), // 15th of month
        patternStartDate: DateTime(2025, 9, 15),
      ),

      // Last Friday of every month
      PracticePattern(
        id: 'denver-fri-1800-vmac-lastfriday',
        clubId: 'denver-uwh',
        title: 'Month-End Tournament Prep',
        description: 'Tournament preparation session on last Friday',
        day: PatternDay.friday,
        startTime: const PatternTime(18, 0),
        duration: const Duration(hours: 2),
        location: 'VMAC',
        address: '5310 E 136th Ave, Thornton, CO',
        tag: 'Tournament',
        recurrence: const RecurrencePattern.monthlyByWeek(-1), // Last Friday
        patternStartDate: DateTime(2025, 9, 27), // Last Friday of September
      ),

      // Custom interval (every 10 days)
      PracticePattern(
        id: 'denver-wed-1600-carmody-custom',
        clubId: 'denver-uwh',
        title: 'Special Training Cycle',
        description: 'Special training following a 10-day cycle',
        day: PatternDay.wednesday,
        startTime: const PatternTime(16, 0),
        duration: const Duration(hours: 1, minutes: 30),
        location: 'Carmody Recreation Center',
        address: '1510 W 84th Ave, Westminster, CO',
        tag: 'Special',
        recurrence: const RecurrencePattern.customDays(10), // Every 10 days
        patternStartDate: DateTime(2025, 9, 4),
        patternEndDate: DateTime(2025, 12, 31), // Ends at year end
      ),

      // One-time event (no recurrence)
      PracticePattern(
        id: 'denver-sat-0900-vmac-tournament',
        clubId: 'denver-uwh',
        title: 'Halloween Tournament',
        description: 'Special Halloween tournament - one time only',
        day: PatternDay.saturday,
        startTime: const PatternTime(9, 0),
        duration: const Duration(hours: 8),
        location: 'VMAC',
        address: '5310 E 136th Ave, Thornton, CO',
        tag: 'Tournament',
        recurrence: const RecurrencePattern.none(),
        patternStartDate: DateTime(2025, 10, 26), // Specific date only
      ),
    ];
  }

  /// Get human-readable descriptions of recurrence patterns
  static Map<String, String> getRecurrenceDescriptions() {
    return {
      'weekly': 'Every week on the same day',
      'biweekly': 'Every 2 weeks on the same day',
      'monthly_by_week': 'Same week and day each month (e.g., 2nd Tuesday)',
      'monthly_by_date': 'Same date each month (e.g., 15th)',
      'custom_days': 'Custom interval in days',
      'none': 'One-time only (special events)',
    };
  }

  /// Generate practice instances for a date range based on patterns
  static List<Map<String, dynamic>> generatePracticeInstances(
    List<PracticePattern> patterns, 
    DateTime startDate, 
    DateTime endDate,
  ) {
    final practices = <Map<String, dynamic>>[];
    
    for (final pattern in patterns) {
      var currentDate = startDate;
      while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
        if (pattern.shouldGeneratePracticeOn(currentDate)) {
          practices.add(pattern.generatePracticeData(currentDate));
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }
    }
    
    // Sort by date
    practices.sort((a, b) {
      final dateA = DateTime.parse(a['dateTime']);
      final dateB = DateTime.parse(b['dateTime']);
      return dateA.compareTo(dateB);
    });
    
    return practices;
  }
}