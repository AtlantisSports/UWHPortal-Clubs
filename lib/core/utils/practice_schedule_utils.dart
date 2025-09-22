import '../models/practice.dart';
import '../di/service_locator.dart';

/// Utility for managing recurring practice schedules
/// Now uses ScheduleService for proper layer separation
class PracticeScheduleUtils {
  /// Get recurring/template practices for a club
  /// Uses ScheduleService instead of direct data access
  static List<Practice> getRecurringPractices(String clubId) {
    final scheduleService = ServiceLocator.scheduleService;
    return scheduleService.getRecurringPractices(clubId);
  }
}