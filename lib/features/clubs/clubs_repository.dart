/// Repository pattern implementation for clubs data
///
/// This abstracts data sources and provides caching, offline support,
/// and consistent data access patterns.
library;

import '../../core/models/club.dart';
import '../../core/models/practice.dart';
import '../../core/data/mock_data_service.dart';
import '../../core/repositories/interfaces/club_repository.dart';
import 'clubs_service.dart';

/// Legacy ClubsRepository - now extends unified ClubRepository interface
///
/// This maintains backward compatibility while adopting the standardized interface.
/// The implementation is now consistent with the unified repository pattern.
abstract class ClubsRepository extends ClubRepository {
  // All methods inherited from ClubRepository
  // Legacy method signatures maintained for backward compatibility

  /// Legacy method - delegates to getClubById for consistency
  Future<Club> getClub(String clubId) async {
    final club = await getClubById(clubId);
    if (club == null) {
      throw Exception('Club not found: $clubId');
    }
    return club;
  }
}



/// Implementation of clubs repository with caching
class ClubsRepositoryImpl implements ClubsRepository {
  final ClubsService _clubsService;

  // Simple in-memory cache
  List<Club>? _cachedClubs;
  DateTime? _lastCacheTime;
  static const Duration _cacheExpiration = Duration(minutes: 5);

  ClubsRepositoryImpl({required ClubsService clubsService})
      : _clubsService = clubsService;

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

    // Use ClubsService instead of direct MockDataService access
    final clubs = await _clubsService.getClubs(
      page: page,
      limit: limit,
      search: search,
      location: location,
      tags: tags,
    );

    // Cache basic results
    if (search == null && location == null && (tags == null || tags.isEmpty) && page == 1) {
      _cachedClubs = clubs;
      _lastCacheTime = DateTime.now();
    }

    return clubs;
  }

  @override
  Future<Club?> getClubById(String clubId) async {
    // Check cache first
    if (_cachedClubs != null) {
      try {
        return _cachedClubs!.firstWhere((club) => club.id == clubId);
      } catch (e) {
        // Not found in cache, fetch from service
      }
    }

    try {
      return await _clubsService.getClub(clubId);
    } catch (e) {
      // Return null if club not found (consistent with interface)
      return null;
    }
  }

  @override
  Future<Club> getClub(String clubId) async {
    final club = await getClubById(clubId);
    if (club == null) {
      throw Exception('Club not found: $clubId');
    }
    return club;
  }

  @override
  Future<void> refreshClubs() async {
    // Clear cache and fetch fresh data
    _cachedClubs = null;
    _lastCacheTime = null;

    await getClubs(); // This will fetch and cache new data
  }

  @override
  Future<void> updateParticipationStatus(String clubId, String practiceId, ParticipationStatus status) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Update participation status in cached data if available
    if (_cachedClubs != null) {
      for (var club in _cachedClubs!) {
        if (club.id == clubId) {
          for (var practice in club.upcomingPractices) {
            if (practice.id == practiceId) {
              // Update the participation status for current user
              practice.participationResponses[MockDataService.currentUserId] = status;
              break;
            }
          }
          break;
        }
      }
    }

    // In a real implementation, this would call the API
    // await _clubsService.updateParticipationStatus(clubId, practiceId, status);
  }

  @override
  Future<void> updateMemberParticipationStatus(String clubId, String practiceId, String memberId, ParticipationStatus status) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    if (_cachedClubs != null) {
      for (var club in _cachedClubs!) {
        if (club.id == clubId) {
          for (var practice in club.upcomingPractices) {
            if (practice.id == practiceId) {
              practice.participationResponses[memberId] = status;
              break;
            }
          }
          break;
        }
      }
    }
  }

  // === Missing ClubRepository Interface Methods ===

  @override
  Future<List<Club>> getClubsByLocation(String location) async {
    return await getClubs(location: location);
  }

  @override
  Future<List<Club>> searchClubs(String query) async {
    return await getClubs(search: query);
  }

  @override
  Future<List<Club>> getUserClubs(String userId) async {
    // For mock implementation, return all clubs
    // In real implementation, this would filter by user membership
    return await getClubs();
  }

  @override
  Future<bool> joinClub(String userId, String clubId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Mock implementation always succeeds
    // In real implementation, this would make API call
    return true;
  }

  @override
  Future<bool> leaveClub(String userId, String clubId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Mock implementation always succeeds
    return true;
  }

  @override
  Future<bool> updateClub(Club club) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock implementation always succeeds
    // In real implementation, this would call API
    return true;
  }

  @override
  Future<String?> createClub(Club club) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock implementation returns a generated ID
    // In real implementation, this would call API and return actual ID
    return 'club_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<bool> deleteClub(String clubId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock implementation always succeeds
    return true;
  }

  @override
  Future<Map<String, dynamic>> getClubStats(String clubId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Mock implementation returns sample stats
    return {
      'totalMembers': 45,
      'activePractices': 12,
      'averageAttendance': 0.78,
      'monthlyGrowth': 0.15,
    };
  }

  @override
  Future<int> getClubMemberCount(String clubId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Mock implementation returns sample count
    return 45;
  }

  @override
  Future<bool> isClubAdmin(String userId, String clubId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    // Mock implementation - for demo purposes, return true for specific user
    return userId == 'admin_user';
  }

  @override
  Future<List<String>> getClubAdmins(String clubId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Mock implementation returns sample admin IDs
    return ['admin_user', 'club_owner'];
  }

  // === Private Helper Methods ===

  /// Check if cache is still valid
  bool _isCacheValid() {
    if (_cachedClubs == null || _lastCacheTime == null) {
      return false;
    }

    final now = DateTime.now();
    return now.difference(_lastCacheTime!).compareTo(_cacheExpiration) < 0;
  }

  /// Clear all cached data
  void clearCache() {
    _cachedClubs = null;
    _lastCacheTime = null;
  }
}