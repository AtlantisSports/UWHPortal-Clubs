import '../models/practice.dart';
import '../di/service_locator.dart';

/// Utility for managing typical practice schedules
/// Now uses ScheduleService for proper layer separation
class PracticeScheduleUtils {
  /// Get typical/template practices for a club
  /// Uses ScheduleService instead of direct data access
  static List<Practice> getTypicalPractices(String clubId) {
    final scheduleService = ServiceLocator.scheduleService;
    return scheduleService.getTypicalPractices(clubId);
  }
}