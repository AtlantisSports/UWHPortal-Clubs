/// Clubs feature - API service for club-related operations
library;

import '../../core/api/api_client.dart';
import '../../core/models/club.dart';

class ClubsService {
  final ApiClient _apiClient;
  
  ClubsService(this._apiClient);
  
  /// Get list of all clubs with optional filtering
  Future<List<Club>> getClubs({
    int page = 1,
    int limit = 20,
    String? search,
    String? location,
    List<String>? tags,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (location != null && location.isNotEmpty) 'location': location,
      if (tags != null && tags.isNotEmpty) 'tags': tags.join(','),
    };
    
    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
    
    final response = await _apiClient.get('/clubs?$queryString');
    final clubsList = response['data'] as List<dynamic>;
    
    return clubsList.map((json) => Club.fromJson(json)).toList();
  }
  
  /// Get a specific club by ID
  Future<Club> getClub(String clubId) async {
    final response = await _apiClient.get('/clubs/$clubId');
    return Club.fromJson(response);
  }
  
  /// Create a new club
  Future<Club> createClub(Club club) async {
    final response = await _apiClient.post('/clubs', club.toJson());
    return Club.fromJson(response);
  }
  
  /// Update an existing club
  Future<Club> updateClub(Club club) async {
    final response = await _apiClient.put('/clubs/${club.id}', club.toJson());
    return Club.fromJson(response);
  }
  
  /// Delete a club
  Future<void> deleteClub(String clubId) async {
    await _apiClient.delete('/clubs/$clubId');
  }
  
  /// Join a club (for authenticated user)
  Future<void> joinClub(String clubId) async {
    await _apiClient.post('/clubs/$clubId/join', {});
  }
  
  /// Leave a club (for authenticated user)
  Future<void> leaveClub(String clubId) async {
    await _apiClient.post('/clubs/$clubId/leave', {});
  }
  
  /// Get club members
  Future<List<Map<String, dynamic>>> getClubMembers(String clubId) async {
    final response = await _apiClient.get('/clubs/$clubId/members');
    return (response['data'] as List<dynamic>).cast<Map<String, dynamic>>();
  }
}
