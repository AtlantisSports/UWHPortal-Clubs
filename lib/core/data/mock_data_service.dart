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
          'patternId': 'denver-uwh-mon-2015-vmac-1',
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
          'patternId': 'denver-uwh-wed-1900-carmody-1',
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
          'patternId': 'denver-uwh-thu-2015-vmac-1',
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
          'patternId': 'denver-uwh-tue-1800-epic-1',
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
            'patternStartDate': DateTime(2025, 9, 2), // Start on first Tuesday of September 2025
        },
        {
          'patternId': 'denver-uwh-sun-1100-vmac-1',
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
          'patternId': 'denver-uwh-sun-1500-carmody-1',
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
        {
          'patternId': 'sydney-tue-1800-olympic-3week',
          'id_prefix': 'tuesday_3week',
          'title': 'Tuesday Advanced (Every 3 Weeks)',
          'description': 'Intensive training sessions focusing on advanced techniques and competitive strategies. Runs every 3 weeks on Tuesday evenings.',
          'day': DateTime.tuesday,
          'hour': 18,
          'minute': 0,
          'duration': 150, // 6:00 PM - 8:30 PM (2.5 hours)
          'location': 'Gong',
          'address': 'Olympic Boulevard, Sydney Olympic Park NSW',
          'tag': 'Advanced',
          'recurrence': {
            'type': 'every3weeks',
            'interval': 3,
          },
          'patternStartDate': DateTime(2025, 1, 7), // First Tuesday in January 2025
        },
        {
          'patternId': 'sydney-sun-1400-homebush-monthly',
          'id_prefix': 'sunday_monthly',
          'title': 'Sunday Monthly Skills (2nd Sunday)',
          'description': 'Monthly skills development session focusing on fundamental techniques and team building. Perfect for players looking to improve their game.',
          'day': DateTime.sunday,
          'hour': 14,
          'minute': 0,
          'duration': 180, // 2:00 PM - 5:00 PM (3 hours)
          'location': 'Gunyama',
          'address': '1 Bennelong Parkway, Sydney Olympic Park NSW',
          'tag': 'Skills',
          'recurrence': {
            'type': 'monthlyByWeek',
            'weekOfMonth': 2, // 2nd occurrence of the weekday in the month
          },
          'patternStartDate': DateTime(2025, 1, 12), // 2nd Sunday in January 2025
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

  /// Get recurring practice patterns for display - just the raw template data
  static List<Map<String, dynamic>> getRecurringPracticePatterns(String clubId) {
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
      
      // Determine recurrence pattern - handle both string and map formats
      String recurrenceType = 'weekly';
      int? weekOfMonth;
      
      final recurrenceData = pattern['recurrence'];
      if (recurrenceData is String) {
        recurrenceType = recurrenceData;
      } else if (recurrenceData is Map<String, dynamic>) {
        recurrenceType = recurrenceData['type'] as String? ?? 'weekly';
        weekOfMonth = recurrenceData['weekOfMonth'] as int?;
      }
      
      RecurrencePattern recurrence;
      switch (recurrenceType) {
        case 'biweekly':
          recurrence = const RecurrencePattern.biweekly();
          break;
        case 'every3weeks':
          recurrence = const RecurrencePattern.every3weeks();
          break;
        case 'monthlyByWeek':
          final week = weekOfMonth ?? pattern['weekOfMonth'] as int? ?? 2; // Default to 2nd week
          recurrence = RecurrencePattern.monthlyByWeek(week);
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
        patternStartDate: pattern['patternStartDate'] as DateTime? ?? DateTime(2025, 9, 1), // Use pattern start date or default
      );
    }).toList();
  }

  /// Get recurring/template practices for a club - DEPRECATED - use getPracticePatterns instead
  /// NOTE: This creates Practice objects for backward compatibility, but recurring practices
  /// should ideally use getPracticePatterns() for template display
  static List<Practice> getRecurringPractices(String clubId) {
    final clubData = _clubsData[clubId];
    if (clubData == null) {
      return _getDefaultRecurringPractices(clubId);
    }
    
    final practicePatterns = clubData['practicePatterns'] as List<Map<String, dynamic>>;
    return practicePatterns.map((pattern) {
      // For recurring practices, use a fixed arbitrary date since we only care about time and pattern ID
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

  /// Get recurring schedule for calendar widget - derives from club data
  static List<Map<String, dynamic>> getCalendarRecurringSchedule(String clubId) {
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
      // Handle both string and map formats for recurrence
      String recurrenceType = 'weekly';
      final recurrenceData = pattern['recurrence'];
      if (recurrenceData is String) {
        recurrenceType = recurrenceData;
      } else if (recurrenceData is Map<String, dynamic>) {
        recurrenceType = recurrenceData['type'] as String? ?? 'weekly';
      }
      
      final dates = _getRecurringPracticeDates(
        pattern['day'] as int,
        pattern['hour'] as int,
        pattern['minute'] as int,
        recurrence: recurrenceType,
        startDate: pattern['patternStartDate'] as DateTime?,
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
  static List<Practice> _getDefaultRecurringPractices(String clubId) {
    return [
      Practice(
        id: 'recurring-default',
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
    
    // Calculate the transition point: 30 minutes after practice starts
    final transitionPoint = practiceDate.add(const Duration(minutes: 30));
    
    // For practices that have passed the 30-minute mark: Show attended/missed status (mock data for demo)
    if (now.isAfter(transitionPoint)) {
      // Default deterministic assignment based on hash
      if (practiceId.hashCode % 3 == 0) {
        responses[currentUserId] = ParticipationStatus.attended;
      } else {
        responses[currentUserId] = ParticipationStatus.missed;
      }
    } else {
      // Practices that haven't reached the 30-minute transition: Show RSVP status (blank for future practices)
      responses[currentUserId] = ParticipationStatus.blank;
    }

    // Add some other users for context
    responses[mockUser2] = ParticipationStatus.maybe;
    responses[mockUser3] = ParticipationStatus.blank;
    responses[mockUser4] = ParticipationStatus.yes;
    responses[mockUser5] = ParticipationStatus.no;

    return responses;
  }

  /// Get recurring practice dates in a rolling window around "now"
  /// Generates dates from ~2 months back through ~3 months ahead to
  /// keep the calendar populated regardless of the current date.
  static List<DateTime> _getRecurringPracticeDates(
    int dayOfWeek,
    int hour,
    int minute, {
    String recurrence = 'weekly',
    DateTime? startDate,
  }) {
    final dates = <DateTime>[];

    // Rolling window: start ~60 days back from the first of that month, end ~90 days ahead
    final now = DateTime.now();
    final startWindow = DateTime(now.year, now.month, 1).subtract(const Duration(days: 60));
    final endWindow = now.add(const Duration(days: 90));

    DateTime current;

    if (startDate != null) {
      // Respect provided pattern start but clamp to the rolling window
      final effectiveStart = startDate.isAfter(startWindow) ? startDate : startWindow;
      current = DateTime(effectiveStart.year, effectiveStart.month, effectiveStart.day, hour, minute);
    } else {
      // Find first occurrence of the target weekday starting from the rolling window month
      final defaultStartDate = DateTime(startWindow.year, startWindow.month, 1);
      current = defaultStartDate;
      while (current.weekday != dayOfWeek && current.month == defaultStartDate.month) {
        current = current.add(const Duration(days: 1));
      }

      // If not found in that month, find it in the next month
      if (current.month != defaultStartDate.month) {
        current = DateTime(defaultStartDate.year, defaultStartDate.month + 1, 1);
        while (current.weekday != dayOfWeek) {
          current = current.add(const Duration(days: 1));
        }
      }

      // Set the time
      current = DateTime(current.year, current.month, current.day, hour, minute);
    }

    // Generate all occurrences until end of window based on recurrence pattern
    int intervalDays;
    switch (recurrence) {
      case 'biweekly':
        intervalDays = 14; // Every 2 weeks
        break;
      case 'every3weeks':
        intervalDays = 21; // Every 3 weeks
        break;
      case 'weekly':
      default:
        intervalDays = 7; // Every week
        break;
    }

    // Generate dates based on recurrence type
    if (recurrence == 'monthlyByWeek') {
      // Special handling for monthly by week patterns
      dates.addAll(_generateMonthlyByWeekDates(current, endWindow, dayOfWeek));
    } else {
      // Standard weekly/biweekly/3-weekly patterns
      while (current.isBefore(endWindow) || current.isAtSameMomentAs(endWindow)) {
        dates.add(current);
        current = current.add(Duration(days: intervalDays));
      }
    }

    return dates;
  }

  /// Generate dates for monthly by week patterns (e.g., 2nd Sunday of each month)
  static List<DateTime> _generateMonthlyByWeekDates(DateTime startDate, DateTime endDate, int targetWeekday) {
    final dates = <DateTime>[];
    
    // Start from the month of the start date
    var currentMonth = DateTime(startDate.year, startDate.month, 1);
    
    while (currentMonth.isBefore(endDate) || currentMonth.month == endDate.month) {
      // Find the 2nd occurrence of the target weekday in this month
      var firstOccurrence = currentMonth;
      while (firstOccurrence.weekday != targetWeekday) {
        firstOccurrence = firstOccurrence.add(const Duration(days: 1));
      }
      
      // Get the 2nd occurrence (add 7 days)
      final secondOccurrence = firstOccurrence.add(const Duration(days: 7));
      
      // Make sure it's still in the same month and set the correct time
      if (secondOccurrence.month == currentMonth.month) {
        final practiceDate = DateTime(
          secondOccurrence.year,
          secondOccurrence.month,
          secondOccurrence.day,
          startDate.hour,
          startDate.minute,
        );
        
        if (practiceDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
            (practiceDate.isBefore(endDate) || practiceDate.isAtSameMomentAs(endDate))) {
          dates.add(practiceDate);
        }
      }
      
      // Move to next month
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
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

  /// Get mock guests for a practice (only for past practices where user attended)
  static PracticeGuestList getMockGuestsForPractice(String practiceId, DateTime practiceDate) {
    final now = DateTime.now();
    
    // Only generate guests for past practices
    if (practiceDate.isAfter(now) || practiceDate.isAtSameMomentAs(now)) {
      return const PracticeGuestList();
    }
    
    // Use practice ID hash to deterministically decide attendance and guests
    final hash = practiceId.hashCode;

    // Determine recent Denver day-of-week categories for adjusted probabilities
    final recentCutoff = now.subtract(const Duration(days: 30));
    final isRecentPast = practiceDate.isBefore(now) && practiceDate.isAfter(recentCutoff);
    final isDenver = practiceId.startsWith('denver-uwh-');
    final isDenverSundayRecent = isDenver && practiceDate.weekday == DateTime.sunday && isRecentPast;
    final isDenverThursdayRecent = isDenver && practiceDate.weekday == DateTime.thursday && isRecentPast;

    // Use SAME logic as _generateParticipationForPractice for attendance (no overrides)
    bool userAttended = (hash % 3) == 0; // Default deterministic

    if (!userAttended) {
      return const PracticeGuestList(); // No guests if user didn't attend (has MISSED status)
    }

    // Now check if attended practice has guests (30% for recent Denver Sun/Thu, otherwise 25%)
    bool shouldHaveGuests;
    if (isDenverSundayRecent || isDenverThursdayRecent) {
      // 30% chance
      shouldHaveGuests = (hash % 10) < 3;
    } else {
      // default 25%
      shouldHaveGuests = (hash % 4) == 0;
    }

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