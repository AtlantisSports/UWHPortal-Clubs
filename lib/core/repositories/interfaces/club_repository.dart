/// Club repository interface
/// Defines the contract for club data access
library;

import '../../models/club.dart';

/// Interface for club data operations
abstract class IClubRepository {
  /// Get all clubs
  Future<List<Club>> getAllClubs();
  
  /// Get a specific club by ID
  Future<Club?> getClubById(String clubId);
  
  /// Get clubs by location/region
  Future<List<Club>> getClubsByLocation(String location);
  
  /// Search clubs by name or description
  Future<List<Club>> searchClubs(String query);
  
  /// Get user's joined clubs
  Future<List<Club>> getUserClubs(String userId);
  
  /// Join a club
  Future<bool> joinClub(String userId, String clubId);
  
  /// Leave a club
  Future<bool> leaveClub(String userId, String clubId);
  
  /// Update club information (admin only)
  Future<bool> updateClub(Club club);
  
  /// Create a new club (admin only)
  Future<String?> createClub(Club club);
  
  /// Delete a club (admin only)
  Future<bool> deleteClub(String clubId);
  
  /// Get club statistics
  Future<Map<String, dynamic>> getClubStats(String clubId);
  
  /// Get club member count
  Future<int> getClubMemberCount(String clubId);
  
  /// Check if user is club admin
  Future<bool> isClubAdmin(String userId, String clubId);
  
  /// Get club admins
  Future<List<String>> getClubAdmins(String clubId);
}
