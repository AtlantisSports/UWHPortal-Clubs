/// Mock implementation of ClubsService for development and testing
/// 
/// This service implements the same interface as ClubsService but returns
/// mock data from MockDataService, maintaining proper architectural layers
/// while preserving UI/UX testing capabilities.
library;

import '../../core/api/api_client.dart';
import '../../core/models/club.dart';
import '../../core/data/mock_data_service.dart';
import 'clubs_service.dart';

class MockClubsService implements ClubsService {
  MockClubsService(ApiClient _); // Accept but don't store unused parameter
  
  @override
  Future<List<Club>> getClubs({
    int page = 1,
    int limit = 20,
    String? search,
    String? location,
    List<String>? tags,
  }) async {
    // Use MockDataService but simulate API behavior
    final allClubs = await MockDataService.getClubs();
    
    // Apply filtering if specified (simulating server-side filtering)
    var filteredClubs = allClubs;
    
    if (search != null && search.isNotEmpty) {
      filteredClubs = filteredClubs.where((club) =>
        club.name.toLowerCase().contains(search.toLowerCase()) ||
        club.description.toLowerCase().contains(search.toLowerCase())
      ).toList();
    }
    
    if (location != null && location.isNotEmpty) {
      filteredClubs = filteredClubs.where((club) =>
        club.location.toLowerCase().contains(location.toLowerCase())
      ).toList();
    }
    
    if (tags != null && tags.isNotEmpty) {
      filteredClubs = filteredClubs.where((club) =>
        club.upcomingPractices.any((practice) =>
          practice.tag != null && tags.any((tag) => practice.tag!.toLowerCase() == tag.toLowerCase())
        )
      ).toList();
    }
    
    // Apply pagination
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    
    if (startIndex >= filteredClubs.length) {
      return [];
    }
    
    return filteredClubs.sublist(
      startIndex,
      endIndex > filteredClubs.length ? filteredClubs.length : endIndex,
    );
  }
  
  @override
  Future<Club> getClub(String clubId) async {
    final clubs = await MockDataService.getClubs();
    try {
      return clubs.firstWhere((club) => club.id == clubId);
    } catch (e) {
      throw Exception('Club not found: $clubId');
    }
  }
  
  @override
  Future<Club> createClub(Club club) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // In a real implementation, this would create the club via API
    // For mock purposes, we just return the club as if it was created
    return club;
  }
  
  @override
  Future<Club> updateClub(Club club) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    // In a real implementation, this would update the club via API
    // For mock purposes, we just return the club as if it was updated
    return club;
  }
  
  @override
  Future<void> deleteClub(String clubId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    // In a real implementation, this would delete the club via API
    // For mock purposes, we just simulate success
  }
  
  @override
  Future<void> joinClub(String clubId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 400));
    
    // In a real implementation, this would join the club via API
    // For mock purposes, we just simulate success
  }
  
  @override
  Future<void> leaveClub(String clubId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 400));
    
    // In a real implementation, this would leave the club via API
    // For mock purposes, we just simulate success
  }
  
  @override
  Future<List<Map<String, dynamic>>> getClubMembers(String clubId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Return mock member list as Map objects
    return [
      {'id': MockDataService.currentUserId, 'name': 'Current User', 'role': 'member'},
      {'id': MockDataService.mockUser2, 'name': 'Mock User 2', 'role': 'member'},
      {'id': MockDataService.mockUser3, 'name': 'Mock User 3', 'role': 'admin'},
      {'id': 'member1@example.com', 'name': 'John Doe', 'role': 'member'},
      {'id': 'member2@example.com', 'name': 'Jane Smith', 'role': 'member'},
    ];
  }
}