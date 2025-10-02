/// Club repository interface
/// Defines the contract for club data access
library;

import '../../models/club.dart';
import '../../models/practice.dart';

/// Unified interface for club data operations
///
/// This interface combines the best of both legacy ClubsRepository and IClubRepository
/// patterns, providing a comprehensive API for club-related operations.
abstract class ClubRepository {
  // === Core Data Access ===

  /// Get clubs with optional filtering and pagination
  /// Combines the flexibility of legacy ClubsRepository with interface consistency
  Future<List<Club>> getClubs({
    int page = 1,
    int limit = 20,
    String? search,
    String? location,
    List<String>? tags,
  });

  /// Get a specific club by ID
  /// Returns null if club not found (consistent with optional pattern)
  Future<Club?> getClubById(String clubId);

  /// Get clubs by location/region (convenience method)
  Future<List<Club>> getClubsByLocation(String location);

  /// Search clubs by name or description (convenience method)
  Future<List<Club>> searchClubs(String query);

  /// Refresh cached club data
  Future<void> refreshClubs();

  // === User Membership Operations ===

  /// Get user's joined clubs
  Future<List<Club>> getUserClubs(String userId);

  /// Join a club
  Future<bool> joinClub(String userId, String clubId);

  /// Leave a club
  Future<bool> leaveClub(String userId, String clubId);

  // === Participation Integration ===

  /// Update participation status for a practice
  /// Integrates with participation system for consistency
  Future<void> updateParticipationStatus(String clubId, String practiceId, ParticipationStatus status);

  /// Update participation status for another member (e.g., Club Member guest)
  Future<void> updateMemberParticipationStatus(String clubId, String practiceId, String memberId, ParticipationStatus status);

  // === Admin Operations ===

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
