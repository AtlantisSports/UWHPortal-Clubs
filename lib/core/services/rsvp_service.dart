/// RSVP business logic service
/// Handles all RSVP validation rules and operations
library;

import '../models/practice.dart';

/// Service for handling RSVP business logic and validation
class RSVPService {
  /// Validate if bulk RSVP can be applied
  bool canApplyBulkRSVP({
    required List<String> selectedPracticeIds,
    required ParticipationStatus? selectedChoice,
  }) {
    return selectedPracticeIds.isNotEmpty && selectedChoice != null;
  }

  /// Filter practices based on timeframe selection
  /// Uses the same logic as the bulk RSVP manager
  List<Practice> filterPracticesByTimeframe({
    required List<Practice> practices,
    required String timeframe,
    DateTime? customStartDate,
    DateTime? customEndDate,
    DateTime? announcedCutoff,
  }) {
    switch (timeframe) {
      case 'only_announced':
        // Filter for upcoming announced practices only (bounded by mock announced cutoff)
        return practices.where((p) {
          final now = DateTime.now();
          final cutoff = announcedCutoff ?? DateTime.now().add(const Duration(days: 30));
          final dt = p.dateTime;
          return dt.isAfter(now) && (dt.isBefore(cutoff) || dt.isAtSameMomentAs(cutoff));
        }).toList();

      case 'custom':
        // Custom date range
        if (customStartDate == null || customEndDate == null) {
          return [];
        }
        return practices.where((p) {
          final practiceDate = DateTime(p.dateTime.year, p.dateTime.month, p.dateTime.day);
          final startDate = DateTime(customStartDate.year, customStartDate.month, customStartDate.day);
          final endDate = DateTime(customEndDate.year, customEndDate.month, customEndDate.day);
          return practiceDate.isAtSameMomentAs(startDate) ||
                 practiceDate.isAtSameMomentAs(endDate) ||
                 (practiceDate.isAfter(startDate) && practiceDate.isBefore(endDate));
        }).toList();

      case 'all_future':
        // All future practices from today
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        return practices.where((p) {
          final practiceDate = DateTime(p.dateTime.year, p.dateTime.month, p.dateTime.day);
          return practiceDate.isAtSameMomentAs(todayDate) || practiceDate.isAfter(todayDate);
        }).toList();

      default:
        return practices;
    }
  }

  /// Validate custom date range
  bool isValidDateRange({
    required DateTime? startDate,
    required DateTime? endDate,
  }) {
    if (startDate == null || endDate == null) {
      return false;
    }
    return startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate);
  }

  /// Get validation error message for date range
  String? getDateRangeError({
    required DateTime? startDate,
    required DateTime? endDate,
  }) {
    if (startDate == null || endDate == null) {
      return 'Please select both start and end dates';
    }
    
    if (startDate.isAfter(endDate)) {
      return 'Start date must be before or equal to end date';
    }
    
    return null;
  }

  /// Check if RSVP choice requires additional validation
  bool requiresAdditionalValidation(ParticipationStatus choice) {
    // For now, all choices are straightforward
    // This can be extended for future business rules
    return false;
  }

  /// Get display text for timeframe selection
  String getTimeframeDisplayText(String timeframe) {
    switch (timeframe) {
      case 'only_announced':
        return 'Only announced practices';
      case 'custom':
        return 'Custom date range';
      case 'all_future':
        return 'All future practices';
      default:
        return 'Unknown timeframe';
    }
  }

  /// Calculate summary statistics for bulk RSVP
  Map<String, int> calculateBulkRSVPSummary({
    required List<Practice> selectedPractices,
    required ParticipationStatus choice,
  }) {
    return {
      'totalPractices': selectedPractices.length,
      'upcomingPractices': selectedPractices.where((p) => 
        p.dateTime.isAfter(DateTime.now())).length,
      'pastPractices': selectedPractices.where((p) => 
        p.dateTime.isBefore(DateTime.now())).length,
    };
  }
}

/// Static instance for easy access throughout the app
final rsvpService = RSVPService();
