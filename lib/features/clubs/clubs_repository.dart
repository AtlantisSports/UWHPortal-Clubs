/// Repository pattern implementation for clubs data
/// 
/// This abstracts data sources and provides caching, offline support,
/// and consistent data access patterns.
library;

import '../../core/models/club.dart';
import '../../core/models/practice.dart';
import 'clubs_service.dart';
import '../../core/di/service_locator.dart';

/// Abstract interface for clubs data access
abstract class ClubsRepository {
  Future<List<Club>> getClubs({
    int page = 1,
    int limit = 20,
    String? search,
    String? location,
    List<String>? tags,
  });
  
  Future<Club> getClub(String clubId);
  Future<void> refreshClubs();
  Future<void> updateRSVP(String clubId, String practiceId, RSVPStatus status);
}

/// Implementation of clubs repository with caching
class ClubsRepositoryImpl implements ClubsRepository {
  final ClubsService _clubsService;
  
  // Simple in-memory cache
  List<Club>? _cachedClubs;
  DateTime? _lastCacheTime;
  static const Duration _cacheExpiration = Duration(minutes: 5);
  
  ClubsRepositoryImpl({ClubsService? clubsService})
      : _clubsService = clubsService ?? ServiceLocator.clubsService;

  @override
  Future<List<Club>> getClubs({
    int page = 1,
    int limit = 20,
    String? search,
    String? location,
    List<String>? tags,
  }) async {
    // Check cache first (only for basic requests without filters)
    if (_isCacheValid() && 
        search == null && 
        location == null && 
        (tags == null || tags.isEmpty) &&
        page == 1) {
      return _cachedClubs!;
    }

    // For development: Generate mock data instead of calling API
    final clubs = await _generateMockClubs();

    // Cache basic results
    if (search == null && location == null && (tags == null || tags.isEmpty) && page == 1) {
      _cachedClubs = clubs;
      _lastCacheTime = DateTime.now();
    }

    return clubs;
  }

  @override
  Future<Club> getClub(String clubId) async {
    // Check cache first
    if (_cachedClubs != null) {
      try {
        return _cachedClubs!.firstWhere((club) => club.id == clubId);
      } catch (e) {
        // Not found in cache, fetch from service
      }
    }

    return await _clubsService.getClub(clubId);
  }

  @override
  Future<void> refreshClubs() async {
    // Clear cache and fetch fresh data
    _cachedClubs = null;
    _lastCacheTime = null;
    
    await getClubs(); // This will fetch and cache new data
  }

  @override
  Future<void> updateRSVP(String clubId, String practiceId, RSVPStatus status) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Update RSVP in cached data if available
    if (_cachedClubs != null) {
      for (var club in _cachedClubs!) {
        if (club.id == clubId) {
          for (var i = 0; i < club.upcomingPractices.length; i++) {
            if (club.upcomingPractices[i].id == practiceId) {
              final practice = club.upcomingPractices[i];
              final updatedRSVPs = Map<String, RSVPStatus>.from(practice.rsvpResponses);
              updatedRSVPs['user123'] = status; // Current user ID
              final updatedPractice = practice.copyWith(rsvpResponses: updatedRSVPs);
              club.upcomingPractices[i] = updatedPractice;
              break;
            }
          }
          break;
        }
      }
    }
    
    // TODO: In real implementation, make API call to update RSVP
  }

  /// Check if cached data is still valid
  bool _isCacheValid() {
    return _cachedClubs != null &&
           _lastCacheTime != null &&
           DateTime.now().difference(_lastCacheTime!) < _cacheExpiration;
  }

  /// Clear all cached data
  void clearCache() {
    _cachedClubs = null;
    _lastCacheTime = null;
  }

  /// Generate mock clubs data for development (same as previous implementation)
  Future<List<Club>> _generateMockClubs() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    final now = DateTime.now();
    return [
      // Denver UWH - from portal-rsvp-demo repository
      Club(
        id: 'denver-uwh',
        name: 'Denver UWH',
        shortName: 'DENVER UWH',
        longName: 'DENVER AREA UNDERWATER HOCKEY CLUB',
        description: 'Denver Underwater Hockey - Multiple practice sessions throughout the week at VMAC and Carmody facilities.',
        location: 'Denver, CO',
        contactEmail: 'contact@denveruwh.com',
        website: 'https://www.meetup.com/denver-underwater-hockey/',
        createdAt: now.subtract(const Duration(days: 500)),
        updatedAt: now,
        isActive: true,
        tags: const ['competitive', 'beginner-friendly', 'multi-location'],
        memberCount: 42,
        upcomingPractices: [
          Practice(
            id: 'denver-monday',
            clubId: 'denver-uwh',
            title: 'Monday Evening',
            description: 'Beginner-friendly; arrive 10 min early.',
            dateTime: _getNextPracticeDate(now, DateTime.monday, 20, 15), // 8:15 PM
            location: 'VMAC',
            address: '5310 E 136th Ave, Thornton, CO',
            rsvpResponses: {
              'user123': RSVPStatus.pending, // Current user starts with no selection
              'user456': RSVPStatus.maybe,
              'user789': RSVPStatus.pending,
              'user101': RSVPStatus.yes,
              'user202': RSVPStatus.no,
            },
          ),
          Practice(
            id: 'denver-wednesday',
            clubId: 'denver-uwh',
            title: 'Wednesday Evening',
            description: 'Shallow end reserved. High-level participants only.',
            dateTime: _getNextPracticeDate(now, DateTime.wednesday, 19, 0), // 7:00 PM
            location: 'Carmody',
            address: '2200 S Kipling St, Lakewood, CO',
            rsvpResponses: {
              'user123': RSVPStatus.pending,
              'user456': RSVPStatus.yes,
              'user789': RSVPStatus.maybe,
              'user101': RSVPStatus.no,
            },
          ),
          Practice(
            id: 'denver-thursday',
            clubId: 'denver-uwh',
            title: 'Thursday Evening',
            description: 'Scrimmage heavy. High-level participants only.',
            dateTime: _getNextPracticeDate(now, DateTime.thursday, 20, 15), // 8:15 PM
            location: 'VMAC',
            address: '5310 E 136th Ave, Thornton, CO',
            rsvpResponses: {
              'user123': RSVPStatus.pending, // Current user starts with no selection
              'user456': RSVPStatus.yes,
              'user789': RSVPStatus.yes,
              'user101': RSVPStatus.pending,
              'user202': RSVPStatus.yes,
            },
          ),
          Practice(
            id: 'denver-sunday-morning',
            clubId: 'denver-uwh',
            title: 'Sunday Morning',
            description: 'Drills + conditioning.',
            dateTime: _getNextPracticeDate(now, DateTime.sunday, 10, 0), // 10:00 AM
            location: 'VMAC',
            address: '5310 E 136th Ave, Thornton, CO',
            rsvpResponses: {
              'user123': RSVPStatus.pending, // Current user starts with no selection
              'user456': RSVPStatus.pending,
              'user789': RSVPStatus.yes,
              'user101': RSVPStatus.maybe,
            },
          ),
          Practice(
            id: 'denver-sunday-afternoon',
            clubId: 'denver-uwh',
            title: 'Sunday Afternoon',
            description: 'Afternoon session.',
            dateTime: _getNextPracticeDate(now, DateTime.sunday, 15, 0), // 3:00 PM
            location: 'Carmody',
            address: '2200 S Kipling St, Lakewood, CO',
            rsvpResponses: {
              'user123': RSVPStatus.pending, // Current user starts with no selection
              'user456': RSVPStatus.yes,
              'user789': RSVPStatus.maybe,
            },
          ),
        ],
      ),
      // Sydney Kings UWH - from portal-rsvp-demo repository
      Club(
        id: 'sydney-uwh',
        name: 'Sydney Kings',
        shortName: 'SYDNEY KINGS',
        longName: 'SYDNEY KINGS UNDERWATER HOCKEY',
        description: 'Sydney Kings Underwater Hockey Club - All levels welcome; bring fins & mouthguard.',
        location: 'Sydney, NSW',
        contactEmail: 'info@sydneykingsuwh.com.au',
        website: 'https://nswunderwaterhockey.com/clubs/sydney',
        createdAt: now.subtract(const Duration(days: 300)),
        updatedAt: now,
        isActive: true,
        tags: const ['all-levels', 'community', 'friday-night'],
        memberCount: 28,
        upcomingPractices: [
          Practice(
            id: 'sydney-friday',
            clubId: 'sydney-uwh',
            title: 'Friday Evening',
            description: 'All levels; bring fins & mouthguard.',
            dateTime: _getNextPracticeDate(now, DateTime.friday, 19, 0), // 7:00 PM
            location: 'Ryde Pool',
            address: '504 Victoria Rd, Ryde, NSW',
            rsvpResponses: {
              'user123': RSVPStatus.pending,
              'user456': RSVPStatus.yes,
              'user789': RSVPStatus.maybe,
              'user101': RSVPStatus.yes,
              'user202': RSVPStatus.no,
              'user303': RSVPStatus.yes,
            },
          ),
        ],
      ),
    ];
  }

  /// Helper method to calculate next practice date for a given day of week
  DateTime _getNextPracticeDate(DateTime now, int targetDayOfWeek, int hour, int minute) {
    int daysToAdd = targetDayOfWeek - now.weekday;
    if (daysToAdd <= 0) {
      daysToAdd += 7; // Next week
    }

    DateTime targetDate = now.add(Duration(days: daysToAdd));
    return DateTime(targetDate.year, targetDate.month, targetDate.day, hour, minute);
  }
}
