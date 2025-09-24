/// Mock implementation of club repository
/// Uses the existing mock data for development and testing
library;

import '../interfaces/club_repository.dart';
import '../../models/club.dart';
import '../../data/mock_data_service.dart';

/// Mock implementation of IClubRepository using existing mock data
class MockClubRepository implements IClubRepository {
  @override
  Future<List<Club>> getAllClubs() async {
    // Use existing mock data service with mapper transformation
    // This demonstrates how API repositories will work
    final clubs = await MockDataService.getClubs();
    // In real API implementation, this would be:
    // final response = await apiClient.get('/clubs');
    // return ClubMapper.fromApiResponseList(response.data);
    return clubs;
  }

  @override
  Future<Club?> getClubById(String clubId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final clubs = await MockDataService.getClubs();
    try {
      return clubs.firstWhere((club) => club.id == clubId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Club>> getClubsByLocation(String location) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final clubs = await MockDataService.getClubs();
    return clubs.where((club) =>
      club.location.toLowerCase().contains(location.toLowerCase())
    ).toList();
  }

  @override
  Future<List<Club>> searchClubs(String query) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final clubs = await MockDataService.getClubs();
    final lowerQuery = query.toLowerCase();
    return clubs.where((club) =>
      club.name.toLowerCase().contains(lowerQuery) ||
      club.description.toLowerCase().contains(lowerQuery) ||
      club.location.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  @override
  Future<List<Club>> getUserClubs(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // For mock implementation, return all clubs
    // In real implementation, this would filter by user membership
    return await MockDataService.getClubs();
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
    // In real implementation, this would validate admin permissions
    return true;
  }

  @override
  Future<String?> createClub(Club club) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // In real API implementation, this would be:
    // final requestData = ClubMapper.toApiRequest(club);
    // final response = await apiClient.post('/clubs', data: requestData);
    // return response.data['id'];
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
    await Future.delayed(const Duration(milliseconds: 150));
    final club = await getClubById(clubId);
    if (club == null) return {};
    
    return {
      'memberCount': club.memberCount,
      'practicesThisMonth': club.upcomingPractices.length,
      'averageAttendance': 0.75, // Mock data
      'totalPractices': club.upcomingPractices.length + 50, // Mock historical data
    };
  }

  @override
  Future<int> getClubMemberCount(String clubId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final club = await getClubById(clubId);
    return club?.memberCount ?? 0;
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
}
