/// Repository pattern implementation for clubs data
/// 
/// This abstracts data sources and provides caching, offline support,
/// and consistent data access patterns.
library;

import '../../core/models/club.dart';
import '../../core/models/practice.dart';
import '../../core/data/mock_data_service.dart';
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
  Future<void> updateParticipationStatus(String clubId, String practiceId, ParticipationStatus status);
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
  Future<void> updateParticipationStatus(String clubId, String practiceId, ParticipationStatus status) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Update participation status in cached data if available
    if (_cachedClubs != null) {
      for (var club in _cachedClubs!) {
        if (club.id == clubId) {
          for (var practice in club.upcomingPractices) {
            if (practice.id == practiceId) {
              // Update the participation status
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