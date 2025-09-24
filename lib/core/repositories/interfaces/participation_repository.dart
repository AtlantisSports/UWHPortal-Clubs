/// Participation repository interface
/// Defines the contract for RSVP and participation data access
library;

import '../../models/practice.dart';
import '../../models/guest.dart';

/// Interface for participation/RSVP data operations
abstract class IParticipationRepository {
  /// Get user's participation status for a practice
  Future<ParticipationStatus?> getParticipationStatus({
    required String userId,
    required String practiceId,
  });
  
  /// Update user's participation status for a practice
  Future<bool> updateParticipationStatus({
    required String userId,
    required String practiceId,
    required ParticipationStatus status,
  });
  
  /// Bulk update participation status for multiple practices
  Future<bool> bulkUpdateParticipationStatus({
    required String userId,
    required List<String> practiceIds,
    required ParticipationStatus status,
  });
  
  /// Clear user's RSVP for a practice
  Future<bool> clearParticipationStatus({
    required String userId,
    required String practiceId,
  });
  
  /// Clear all future RSVPs for a user in a club
  Future<bool> clearAllFutureRSVPs({
    required String userId,
    required String clubId,
  });
  
  /// Get all participants for a practice
  Future<Map<String, ParticipationStatus>> getPracticeParticipants(String practiceId);
  
  /// Get participation summary for a practice
  Future<Map<ParticipationStatus, int>> getParticipationSummary(String practiceId);
  
  /// Get user's participation history for a club
  Future<Map<String, ParticipationStatus>> getUserParticipationHistory({
    required String userId,
    required String clubId,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  /// Get guests for a practice and user
  Future<List<Guest>> getPracticeGuests({
    required String userId,
    required String practiceId,
  });
  
  /// Update guests for a practice and user
  Future<bool> updatePracticeGuests({
    required String userId,
    required String practiceId,
    required List<Guest> guests,
  });
  
  /// Get bring guest state for a practice and user
  Future<bool> getBringGuestState({
    required String userId,
    required String practiceId,
  });
  
  /// Update bring guest state for a practice and user
  Future<bool> updateBringGuestState({
    required String userId,
    required String practiceId,
    required bool bringGuest,
  });
  
  /// Get dependents for a user
  Future<List<String>> getUserDependents(String userId);
  
  /// Update user's dependents list
  Future<bool> updateUserDependents({
    required String userId,
    required List<String> dependents,
  });
  
  /// Get participation statistics for a user in a club
  Future<Map<String, dynamic>> getUserParticipationStats({
    required String userId,
    required String clubId,
  });
  
  /// Get club participation statistics
  Future<Map<String, dynamic>> getClubParticipationStats(String clubId);
}
