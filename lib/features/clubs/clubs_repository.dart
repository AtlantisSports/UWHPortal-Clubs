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

    // Fetch from service
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
  Future<void> updateRSVP(String clubId, String practiceId, RSVPStatus status) async {
    // For now, just simulate the update
    // TODO: Make actual API call to update RSVP
    // await _clubsService.updateRSVP(clubId, practiceId, status);
    
    // Update cache if exists
    if (_cachedClubs != null) {
      final clubIndex = _cachedClubs!.indexWhere((club) => club.id == clubId);
      if (clubIndex != -1) {
        // For now, just mark as updated without complex manipulation
        // In a real implementation, we'd update the specific practice RSVP
      }
    }
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
}
