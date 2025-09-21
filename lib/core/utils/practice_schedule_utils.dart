import '../models/practice.dart';

/// Utility for managing typical practice schedules
class PracticeScheduleUtils {
  /// Get typical/template practices for a club
  /// This is the single source of truth for typical practice schedules
  static List<Practice> getTypicalPractices(String clubId) {
    // Define club-specific typical practices
    switch (clubId) {
      case 'denver-uwh':
        return _getDenverTypicalPractices();
      case 'sydney-uwh':
        return _getSydneyTypicalPractices();
      default:
        return _getDefaultTypicalPractices(clubId);
    }
  }

  /// Denver UWH typical practices - Colorado locations and times
  static List<Practice> _getDenverTypicalPractices() {
    final typicalPractices = <Practice>[
      Practice(
        id: 'typical-monday',
        clubId: 'denver-uwh',
        title: 'Monday Evening',
        description: 'Beginner-friendly; arrive 10 min early.',
        dateTime: DateTime(2025, 1, 6, 20, 15), // Monday 8:15 PM
        location: 'VMAC',
        address: '5310 E 136th Ave, Thornton, CO',
        tag: 'Open',
      ),
      Practice(
        id: 'typical-wednesday',
        clubId: 'denver-uwh',
        title: 'Wednesday Evening',
        description: 'Shallow end reserved. High-level participants only.',
        dateTime: DateTime(2025, 1, 1, 19, 0), // Wednesday 7:00 PM
        location: 'Carmody',
        address: '2200 S Kipling St, Lakewood, CO',
        tag: 'High-Level',
      ),
      Practice(
        id: 'typical-thursday',
        clubId: 'denver-uwh',
        title: 'Thursday Evening',
        description: 'Scrimmage heavy. High-level participants only.',
        dateTime: DateTime(2025, 1, 2, 20, 15), // Thursday 8:15 PM
        location: 'VMAC',
        address: '5310 E 136th Ave, Thornton, CO',
        tag: 'High-Level',
      ),
      Practice(
        id: 'typical-sunday-morning',
        clubId: 'denver-uwh',
        title: 'Sunday Morning',
        description: 'Drills + conditioning.',
        dateTime: DateTime(2025, 1, 5, 10, 0), // Sunday 10:00 AM
        location: 'VMAC',
        address: '5310 E 136th Ave, Thornton, CO',
        tag: 'Intermediate',
      ),
      Practice(
        id: 'typical-sunday-afternoon',
        clubId: 'denver-uwh',
        title: 'Sunday Afternoon',
        description: 'Afternoon session.',
        dateTime: DateTime(2025, 1, 5, 15, 0), // Sunday 3:00 PM
        location: 'Carmody',
        address: '2200 S Kipling St, Lakewood, CO',
        tag: 'Open',
      ),
    ];
    
    return _sortTypicalPractices(typicalPractices);
  }

  /// Sydney Kings typical practices - NSW locations and times
  static List<Practice> _getSydneyTypicalPractices() {
    final typicalPractices = <Practice>[
      Practice(
        id: 'typical-friday',
        clubId: 'sydney-uwh',
        title: 'Friday Evening',
        description: 'All levels; bring fins & mouthguard.',
        dateTime: DateTime(2025, 1, 3, 19, 0), // Friday 7:00 PM
        location: 'Ryde Pool',
        address: '504 Victoria Rd, Ryde, NSW',
        tag: 'Open',
      ),
    ];
    
    return _sortTypicalPractices(typicalPractices);
  }

  /// Default/fallback typical practices for unknown clubs
  static List<Practice> _getDefaultTypicalPractices(String clubId) {
    final typicalPractices = <Practice>[
      Practice(
        id: 'typical-default',
        clubId: clubId,
        title: 'Weekly Practice',
        description: 'Regular training session.',
        dateTime: DateTime(2025, 1, 1, 19, 0), // Default: Wednesday 7:00 PM
        location: 'Local Pool',
        address: 'Contact club for details',
        tag: 'Open',
      ),
    ];
    
    return _sortTypicalPractices(typicalPractices);
  }

  /// Sort typical practices by day of week and time
  static List<Practice> _sortTypicalPractices(List<Practice> practices) {
    practices.sort((a, b) {
      // First sort by day of week
      final dayComparison = a.dateTime.weekday.compareTo(b.dateTime.weekday);
      if (dayComparison != 0) return dayComparison;
      
      // Then sort by time if same day
      return a.dateTime.hour.compareTo(b.dateTime.hour);
    });
    
    return practices;
  }
}