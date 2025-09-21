import '../models/practice.dart';
import '../data/mock_data_service.dart';

/// Utility for managing typical practice schedules
/// Now delegates to MockDataService as single source of truth
class PracticeScheduleUtils {
  /// Get typical/template practices for a club
  /// Delegates to MockDataService for single source of truth
  static List<Practice> getTypicalPractices(String clubId) {
    return MockDataService.getTypicalPractices(clubId);
  }
}