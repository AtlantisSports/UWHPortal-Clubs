/// Single source of truth for all mock data.
/// This service provides centralized mock data for development and testing
/// with a clean, generic, club-agnostic architecture.
library;

import '../models/club.dart';
import '../models/practice.dart';
import '../models/practice_pattern.dart';
import '../models/practice_recurrence.dart';
import '../models/guest.dart';

/// Centralized mock data service - single source of truth for all test data
class MockDataService {
  // ===== USER MANAGEMENT =====
  
  /// Current user ID for the application
  static const String currentUserId = 'user123';
  
  /// Additional mock user IDs for participation data
  static const String mockUser2 = 'user456';
  static const String mockUser3 = 'user789';
  static const String mockUser4 = 'user321';
  static const String mockUser5 = 'user654';
  static const String mockUser6 = 'user987';
  
  // ===== CLUB DATA =====
  
  /// All clubs data with their practice patterns - single source of truth
  static final Map<String, Map<String, dynamic>> _clubsData = {
    'denver-uwh': {
      'name': 'Denver UWH',
      'shortName': 'DENVER UWH',
      'longName': 'DENVER AREA UNDERWATER HOCKEY CLUB',
      'description': 'Denver Underwater Hockey - Multiple practice sessions throughout the week at VMAC and Carmody facilities.',
      'location': 'Denver, CO',
      'contactEmail': 'contact@denveruwh.com',
      'website': 'https://www.meetup.com/denver-underwater-hockey/',
      'isActive': true,
      'tags': ['competitive', 'beginner-friendly', 'multi-location'],
      'memberCount': 42,
      'practicePatterns': [
        {
          'patternId': 'denver-mon-2015-vmac-1',
          'id_prefix': 'monday',
          'title': 'Monday Evening',
          'description': 'Mixed-level session with skills development, friendly games, and social time afterward.',
          'day': DateTime.monday,
          'hour': 20,
          'minute': 15,
          'duration': 105, // 8:15 PM - 10:00 PM (1 hour 45 minutes)
          'location': 'VMAC',
          'address': '5310 E 136th Ave, Thornton, CO',
          'tag': 'Intermediate',
        },
        {
          'patternId': 'denver-wed-1900-carmody-1',
          'id_prefix': 'wednesday',
          'title': 'Wednesday Evening',
          'description': 'Multi-level training accommodating all skill levels, featuring basic drills for beginners, intermediate tactical work, and friendly scrimmage games with post-practice social gathering.',
          'day': DateTime.wednesday,
          'hour': 19,
          'minute': 0,
          'duration': 90, // 7:00 PM - 8:30 PM (1 hour 30 minutes)
          'location': 'Carmody',
          'address': '2200 S Kipling St, Lakewood, CO',
          'tag': 'Advanced',
        },
        {
          'patternId': 'denver-thu-2015-vmac-1',
          'id_prefix': 'thursday',
          'title': 'Thursday Evening',
          'description': 'All levels welcome; bring fins & mouthguard.',
          'day': DateTime.thursday,
          'hour': 20,
          'minute': 15,
          'duration': 105, // 8:15 PM - 10:00 PM (1 hour 45 minutes)
          'location': 'VMAC',
          'address': '5310 E 136th Ave, Thornton, CO',
          'tag': 'Open',
        },
        {
          'patternId': 'denver-tue-1800-epic-1',
          'id_prefix': 'tuesday',
          'title': 'Tuesday Evening',
          'description': 'Biweekly mixed-level session',
          'day': DateTime.tuesday,
          'hour': 18,
          'minute': 0,
          'duration': 60, // 6:00 PM - 7:00 PM (1 hour)
          'location': 'EPIC',
          'address': '1801 Riverside Ave, Fort Collins, CO 80525',
          'tag': 'Open',
          'recurrence': 'biweekly', // Every 2 weeks
        },
        {
          'patternId': 'denver-sun-1100-vmac-1',
          'id_prefix': 'sunday-morning',
          'title': 'Sunday Morning',
          'description': 'Inclusive community session welcoming players of all skill levels, featuring separate instruction tracks for beginners and experienced players, mixed-level scrimmage games, equipment sharing program, and social gathering with refreshments afterward. Perfect for families and newcomers to the sport.',
          'day': DateTime.sunday,
          'hour': 11,
          'minute': 0,
          'duration': 90, // 11:00 AM - 12:30 PM (1 hour 30 minutes)
          'location': 'VMAC',
          'address': '5310 E 136th Ave, Thornton, CO',
          'tag': 'Beginner',
        },
        {
          'patternId': 'denver-sun-1500-carmody-1',
          'id_prefix': 'sunday-afternoon',
          'title': 'Sunday Afternoon',
          'description': 'Mixed-level session with skills development, friendly games, and social time afterward.',
          'day': DateTime.sunday,
          'hour': 15,
          'minute': 0,
          'duration': 90, // 3:00 PM - 4:30 PM (1 hour 30 minutes)
          'location': 'Carmody',
          'address': '2200 S Kipling St, Lakewood, CO',
          'tag': 'Open',
        },
      ],
    },
    'sydney-uwh': {
      'name': 'Sydney Kings',
      'shortName': 'SYDNEY KINGS',
      'longName': 'SYDNEY KINGS UNDERWATER HOCKEY',
      'description': 'Sydney Kings Underwater Hockey Club - All levels welcome; bring fins & mouthguard.',
      'location': 'Sydney, NSW',
      'contactEmail': 'info@sydneykingsuwh.com.au',
      'website': 'https://nswunderwaterhockey.com/clubs/sydney',
      'isActive': true,
      'tags': ['community', 'social', 'beginner-friendly'],
      'memberCount': 18,
      'practicePatterns': [
        {
          'patternId': 'sydney-fri-1900-ryde-1',
          'id_prefix': 'friday',
          'title': 'Friday Evening',
          'description': 'Comprehensive training program including technique refinement, tactical awareness development, and competitive match play suitable for intermediate to advanced players.',
          'day': DateTime.friday,
          'hour': 19,
          'minute': 0,
          'duration': 120, // 7:00 PM - 9:00 PM (2 hours)
          'location': 'Ryde Pool',
          'address': 'Top Ryde City Shopping Centre, NSW',
          'tag': 'Open',
        },
      ],
    },
  };

  // ===== PUBLIC METHODS =====

  /// Get all mock clubs with complete practice data
  static Future<List<Club>> getClubs() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    final now = DateTime.now();
    
    return _clubsData.entries.map((entry) {
      final clubId = entry.key;
      final clubData = entry.value;
      final practicePatterns = clubData['practicePatterns'] as List<Map<String, dynamic>>;
      
      return Club(
        id: clubId,
        name: clubData['name'] as String,
        shortName: clubData['shortName'] as String,
        longName: clubData['longName'] as String,
        description: clubData['description'] as String,
        location: clubData['location'] as String,
        contactEmail: clubData['contactEmail'] as String,
        website: clubData['website'] as String,
        createdAt: now.subtract(const Duration(days: 500)),
        updatedAt: now,
        isActive: clubData['isActive'] as bool,
        tags: List<String>.from(clubData['tags'] as List),
        memberCount: clubData['memberCount'] as int,
        upcomingPractices: _generatePracticesForClub(clubId, practicePatterns),
      );
    }).toList();
  }

  /// Get typical practice patterns for display - just the raw template data
  static List<Map<String, dynamic>> getTypicalPracticePatterns(String clubId) {
    final clubData = _clubsData[clubId];
    if (clubData == null) {
      return [];
    }
    
    return (clubData['practicePatterns'] as List<Map<String, dynamic>>).map((pattern) {
      return Map<String, dynamic>.from(pattern); // Return a copy of the pattern
    }).toList();
  }

  /// Get practice patterns for a club - NO dates, just day names and times with recurrence
  static List<PracticePattern> getPracticePatterns(String clubId) {
    final clubData = _clubsData[clubId];
    if (clubData == null) {
      return [
        PracticePattern(
          id: 'default-wed-1900-pool-1',
          clubId: clubId,
          title: 'Wednesday Evening',
          description: 'Weekly practice session',
          day: PatternDay.wednesday,
          startTime: const PatternTime(19, 0),
          duration: const Duration(hours: 2),
          location: 'Local Pool',
          address: 'Local Pool Address',
          tag: 'Open',
          recurrence: const RecurrencePattern.weekly(),
        ),
      ];
    }
    
    final practicePatterns = clubData['practicePatterns'] as List<Map<String, dynamic>>;
    return practicePatterns.map((pattern) {
      // Convert DateTime weekday number to PatternDay
      final dayNumber = pattern['day'] as int;
      final patternDay = PatternDay.fromWeekday(dayNumber);
      
      // Determine recurrence pattern
      final recurrenceType = pattern['recurrence'] as String? ?? 'weekly';
      RecurrencePattern recurrence;
      switch (recurrenceType) {
        case 'biweekly':
          recurrence = const RecurrencePattern.biweekly();
          break;
        case 'weekly':
        default:
          recurrence = const RecurrencePattern.weekly();
          break;
      }
      
      return PracticePattern(
        id: pattern['patternId'] as String,
        clubId: clubId,
        title: pattern['title'] as String,
        description: pattern['description'] as String,
        day: patternDay,
        startTime: PatternTime(pattern['hour'] as int, pattern['minute'] as int),
        duration: Duration(minutes: pattern['duration'] as int? ?? 120),
        location: pattern['location'] as String,
        address: pattern['address'] as String,
        tag: pattern['tag'] as String,
        recurrence: recurrence,
        patternStartDate: DateTime(2025, 9, 1), // Default start date
      );
    }).toList();
  }

  /// Get typical/template practices for a club - DEPRECATED - use getPracticePatterns instead
  /// NOTE: This creates Practice objects for backward compatibility, but typical practices
  /// should ideally use getPracticePatterns() for template display
  static List<Practice> getTypicalPractices(String clubId) {
    final clubData = _clubsData[clubId];
    if (clubData == null) {
      return _getDefaultTypicalPractices(clubId);
    }
    
    final practicePatterns = clubData['practicePatterns'] as List<Map<String, dynamic>>;
    return practicePatterns.map((pattern) {
      // For typical practices, use a fixed arbitrary date since we only care about time and pattern ID
      final hour = pattern['hour'] as int;
      final minute = pattern['minute'] as int;
      final arbitraryDate = DateTime(2000, 1, 1, hour, minute); // Fixed date, no weekday logic
      
      return Practice(
        id: pattern['patternId'] as String, // Use the stable pattern ID
        clubId: clubId,
        title: pattern['title'] as String,
        description: pattern['description'] as String,
        dateTime: arbitraryDate, // Arbitrary date - day will be extracted from pattern ID
        location: pattern['location'] as String,
        address: pattern['address'] as String,
        tag: pattern['tag'] as String,
        duration: Duration(minutes: pattern['duration'] as int? ?? 120),
      );
    }).toList();
  }

  /// Get typical schedule for calendar widget - derives from club data
  static List<Map<String, dynamic>> getCalendarTypicalSchedule(String clubId) {
    final clubData = _clubsData[clubId];
    if (clubData == null) {
      return [
        {'day': DateTime.wednesday, 'time': '7:00 PM', 'location': 'Local Pool', 'tag': 'Open'},
      ];
    }
    
    final practicePatterns = clubData['practicePatterns'] as List<Map<String, dynamic>>;
    return practicePatterns.map((pattern) {
      final hour = pattern['hour'] as int;
      final minute = pattern['minute'] as int;
      final timeString = _formatTime(hour, minute);
      
      return {
        'day': pattern['day'] as int,
        'time': timeString,
        'location': pattern['location'] as String,
        'tag': pattern['tag'] as String,
      };
    }).toList();
  }

  // ===== PRIVATE HELPER METHODS =====

  /// Generate all practice instances for a club based on its patterns
  static List<Practice> _generatePracticesForClub(String clubId, List<Map<String, dynamic>> practicePatterns) {
    final List<Practice> practices = [];
    
    // Generate practices for each pattern
    for (final pattern in practicePatterns) {
      final dates = _getRecurringPracticeDates(
        pattern['day'] as int,
        pattern['hour'] as int,
        pattern['minute'] as int,
      );
      
      for (int i = 0; i < dates.length; i++) {
        final date = dates[i];
        final practiceId = '$clubId-${pattern['id_prefix']}-${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        
        practices.add(
          Practice(
            id: practiceId,
            clubId: clubId,
            patternId: pattern['patternId'] as String, // Link to the practice pattern
            title: pattern['title'] as String,
            description: pattern['description'] as String,
            dateTime: date,
            location: pattern['location'] as String,
            address: pattern['address'] as String,
            tag: pattern['tag'] as String,
            duration: Duration(minutes: pattern['duration'] as int? ?? 120), // Use pattern duration or default to 2 hours
            participationResponses: _generateParticipationForPractice(date, practiceId),
          ),
        );
      }
    }
    
    // Sort by date
    practices.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return practices;
  }

  /// Default practice patterns for unknown clubs
  static List<Practice> _getDefaultTypicalPractices(String clubId) {
    return [
      Practice(
        id: 'typical-default',
        clubId: clubId,
        title: 'Weekly Practice',
        description: 'Regular training session.',
        dateTime: DateTime(1970, 1, 1, 19, 0), // Default: Wednesday 7:00 PM
        location: 'Local Pool',
        address: 'Contact club for details',
        tag: 'Open',
        duration: const Duration(hours: 2), // Default 2 hours for unknown clubs
      ),
    ];
  }

  /// Generate participation responses for a practice
  static Map<String, ParticipationStatus> _generateParticipationForPractice(DateTime practiceDate, String practiceId) {
    final Map<String, ParticipationStatus> responses = {};
    final now = DateTime.now();
    
    // For past practices: Show attended/missed status (mock data for demo)
    if (practiceDate.isBefore(now)) {
      // Vary the responses based on practice ID for consistency
      if (practiceId.hashCode % 3 == 0) {
        responses[currentUserId] = ParticipationStatus.attended;
      } else {
        responses[currentUserId] = ParticipationStatus.missed;
      }
    } else {
      // Future practices: Start with blank status (no mock data)
      responses[currentUserId] = ParticipationStatus.blank;
    }
    
    // Add some other users for context
    responses[mockUser2] = ParticipationStatus.maybe;
    responses[mockUser3] = ParticipationStatus.blank;
    responses[mockUser4] = ParticipationStatus.yes;
    responses[mockUser5] = ParticipationStatus.no;
    
    return responses;
  }

  /// Get recurring practice dates from September 2025 through March 2026
  static List<DateTime> _getRecurringPracticeDates(int dayOfWeek, int hour, int minute) {
    final dates = <DateTime>[];
    final startDate = DateTime(2025, 9, 1); // September 1, 2025
    final endDate = DateTime(2026, 3, 31); // March 31, 2026 (6 months of practices)
    
    // Find first occurrence of the target day in the start month
    DateTime current = startDate;
    while (current.weekday != dayOfWeek && current.month == startDate.month) {
      current = current.add(const Duration(days: 1));
    }
    
    // If we didn't find the day in the start month, find it in the next month
    if (current.month != startDate.month) {
      current = DateTime(startDate.year, startDate.month + 1, 1);
      while (current.weekday != dayOfWeek) {
        current = current.add(const Duration(days: 1));
      }
    }
    
    // Set the time
    current = DateTime(current.year, current.month, current.day, hour, minute);
    
    // Generate all occurrences until end date
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      dates.add(current);
      current = current.add(const Duration(days: 7)); // Next week
    }
    
    return dates;
  }

  /// Format hour and minute into display time string
  static String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final minuteString = minute == 0 ? '00' : minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteString $period';
  }

  // ===== MOCK GUEST DATA =====

  /// Get mock guests for a practice (only for past practices)
  static PracticeGuestList getMockGuestsForPractice(String practiceId, DateTime practiceDate) {
    final now = DateTime.now();
    
    // Only generate guests for past practices
    if (practiceDate.isAfter(now) || practiceDate.isAtSameMomentAs(now)) {
      return const PracticeGuestList();
    }
    
    // Use practice ID hash to deterministically decide if this practice has guests
    final hash = practiceId.hashCode;
    final shouldHaveGuests = (hash % 4) == 0; // ~25% of past practices have guests
    
    if (!shouldHaveGuests) {
      return const PracticeGuestList();
    }
    
    // Determine number of guests (1-2)
    final guestCount = (hash % 2) + 1;
    final guests = <Guest>[];
    
    // Mock guest names
    final guestNames = [
      'Alex Chen', 'Sarah Williams', 'Mike Johnson', 'Emma Davis', 'Jordan Kim',
      'Taylor Brown', 'Casey Martinez', 'Riley Anderson', 'Morgan Thompson', 'Avery Wilson'
    ];
    
    // Club names for visitors
    final visitorClubs = [
      'Seattle UWH', 'Portland UWH', 'Vancouver UWH', 'Boulder UWH', 
      'Austin UWH', 'Phoenix UWH', 'Salt Lake UWH'
    ];
    
    for (int i = 0; i < guestCount; i++) {
      // Use hash + index to get deterministic but varied results
      final guestHash = (hash + i * 37) % 1000;
      final nameIndex = guestHash % guestNames.length;
      final guestName = guestNames[nameIndex];
      final guestId = '${practiceId}_guest_$i';
      
      // Determine guest type based on hash
      final typeIndex = guestHash % 4;
      
      switch (typeIndex) {
        case 0:
          // New Player
          guests.add(NewPlayerGuest(
            id: guestId,
            name: guestName,
            waiverSigned: (guestHash % 3) != 0, // ~67% have signed waivers
          ));
          break;
        case 1:
          // Visitor
          final clubIndex = guestHash % visitorClubs.length;
          guests.add(VisitorGuest(
            id: guestId,
            name: guestName,
            homeClub: visitorClubs[clubIndex],
            waiverSigned: (guestHash % 2) == 0, // 50% have signed waivers
          ));
          break;
        case 2:
          // Club Member
          guests.add(ClubMemberGuest(
            id: guestId,
            name: guestName,
            memberId: 'member_${guestHash % 100}',
            hasPermission: true,
          ));
          break;
        case 3:
          // Dependent
          guests.add(DependentGuest(
            id: guestId,
            name: guestName,
            waiverSigned: (guestHash % 2) == 0, // 50% have signed waivers
          ));
          break;
      }
    }
    
    return PracticeGuestList(guests: guests);
  }
}