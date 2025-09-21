import '../models/practice.dart';

/// Utility for managing typical practice schedules
class PracticeScheduleUtils {
  /// Get typical/template practices for a club
  /// This is the single source of truth for typical practice schedules
  static List<Practice> getTypicalPractices(String clubId) {
    final typicalPractices = <Practice>[
      Practice(
        id: 'typical-monday',
        clubId: clubId,
        title: 'Monday Evening',
        description: 'Beginner-friendly; arrive 10 min early.',
        dateTime: DateTime(2025, 1, 6, 20, 15), // Template: Monday 8:15 PM (using first Monday of 2025)
        location: 'VMAC',
        address: '5310 E 136th Ave, Thornton, CO',
        tag: 'Open',
      ),
      Practice(
        id: 'typical-wednesday',
        clubId: clubId,
        title: 'Wednesday Evening',
        description: 'Shallow end reserved. High-level participants only.',
        dateTime: DateTime(2025, 1, 1, 19, 0), // Template: Wednesday 7:00 PM (using first Wednesday of 2025)
        location: 'Carmody',
        address: '2200 S Kipling St, Lakewood, CO',
        tag: 'High-Level',
      ),
      Practice(
        id: 'typical-thursday',
        clubId: clubId,
        title: 'Thursday Evening',
        description: 'Intermediate players welcome.',
        dateTime: DateTime(2025, 1, 2, 20, 0), // Template: Thursday 8:00 PM (using first Thursday of 2025)
        location: 'VMAC',
        address: '5310 E 136th Ave, Thornton, CO',
        tag: 'Intermediate',
      ),
      Practice(
        id: 'typical-sunday-morning',
        clubId: clubId,
        title: 'Sunday Morning',
        description: 'Weekly practice for all skill levels.',
        dateTime: DateTime(2025, 1, 5, 10, 0), // Template: Sunday 10:00 AM (using first Sunday of 2025)
        location: 'Carmody',
        address: '2200 S Kipling St, Lakewood, CO',
        tag: 'Open',
      ),
      Practice(
        id: 'typical-sunday-afternoon',
        clubId: clubId,
        title: 'Sunday Afternoon',
        description: 'Afternoon session.',
        dateTime: DateTime(2025, 1, 5, 15, 0), // Template: Sunday 3:00 PM (using first Sunday of 2025)
        location: 'Carmody',
        address: '2200 S Kipling St, Lakewood, CO',
        tag: 'Open',
      ),
    ];
    
    // Sort by day of week and time
    typicalPractices.sort((a, b) {
      // First sort by day of week
      final dayComparison = a.dateTime.weekday.compareTo(b.dateTime.weekday);
      if (dayComparison != 0) return dayComparison;
      
      // Then sort by time if same day
      return a.dateTime.hour.compareTo(b.dateTime.hour);
    });
    
    return typicalPractices;
  }
}