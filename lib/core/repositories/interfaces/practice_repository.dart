/// Practice repository interface
/// Defines the contract for practice data access
library;

import '../../models/practice.dart';
import '../../models/practice_pattern.dart';

/// Unified interface for practice data operations
///
/// This interface provides a comprehensive API for all practice-related operations,
/// following the standardized repository pattern.
abstract class PracticeRepository {
  /// Get all practices for a club
  Future<List<Practice>> getClubPractices(String clubId);
  
  /// Get practices within a date range
  Future<List<Practice>> getPracticesInRange({
    required String clubId,
    required DateTime startDate,
    required DateTime endDate,
  });
  
  /// Get upcoming practices for a club
  Future<List<Practice>> getUpcomingPractices(String clubId, {int? limit});
  
  /// Get past practices for a club
  Future<List<Practice>> getPastPractices(String clubId, {int? limit});
  
  /// Get a specific practice by ID
  Future<Practice?> getPracticeById(String practiceId);
  
  /// Get practices by pattern ID
  Future<List<Practice>> getPracticesByPattern(String patternId);
  
  /// Create a new practice
  Future<String?> createPractice(Practice practice);
  
  /// Update practice information
  Future<bool> updatePractice(Practice practice);
  
  /// Cancel a practice
  Future<bool> cancelPractice(String practiceId, String reason);
  
  /// Delete a practice
  Future<bool> deletePractice(String practiceId);
  
  /// Get practice patterns for a club
  Future<List<PracticePattern>> getClubPracticePatterns(String clubId);
  
  /// Create a new practice pattern
  Future<String?> createPracticePattern(PracticePattern pattern);
  
  /// Update practice pattern
  Future<bool> updatePracticePattern(PracticePattern pattern);
  
  /// Delete practice pattern
  Future<bool> deletePracticePattern(String patternId);
  
  /// Generate practices from pattern
  Future<List<Practice>> generatePracticesFromPattern({
    required String patternId,
    required DateTime startDate,
    required DateTime endDate,
  });
  
  /// Get practice locations for a club
  Future<List<String>> getClubLocations(String clubId);
  
  /// Get practice levels/tags for a club
  Future<List<String>> getClubLevels(String clubId);
  
  /// Search practices
  Future<List<Practice>> searchPractices({
    required String clubId,
    String? location,
    String? level,
    DateTime? startDate,
    DateTime? endDate,
  });
}
