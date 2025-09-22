/// Utility class for verifying data consistency between different practice views
library;

import 'package:flutter/foundation.dart';
import '../models/practice.dart';

class PracticeDataConsistencyVerifier {
  /// Verify that recurring practices and bulk RSVP practices have consistent patternIds
  static bool verifyConsistency({
    required List<Practice> recurringPractices,
    required List<Practice> bulkRSVPPractices,
    required String clubId,
  }) {
    final recurringPatternIds = recurringPractices.map((p) => p.id).toSet();
    final bulkRSVPPatternIds = bulkRSVPPractices.map((p) => p.id).toSet();
    
    // Check if pattern IDs match
    final isConsistent = recurringPatternIds == bulkRSVPPatternIds;
    
    if (!isConsistent) {
      debugPrint('WARNING: Pattern ID mismatch for club $clubId');
      debugPrint('Recurring practices: $recurringPatternIds');
      debugPrint('Bulk RSVP practices: $bulkRSVPPatternIds');
      
      // Find missing patterns
      final missingInBulkRSVP = recurringPatternIds.difference(bulkRSVPPatternIds);
      final missingInRecurring = bulkRSVPPatternIds.difference(recurringPatternIds);
      
      if (missingInBulkRSVP.isNotEmpty) {
        debugPrint('Missing in bulk RSVP: $missingInBulkRSVP');
      }
      if (missingInRecurring.isNotEmpty) {
        debugPrint('Missing in recurring practices: $missingInRecurring');
      }
    } else {
      debugPrint('✓ Practice data consistency verified for club $clubId');
    }
    
    return isConsistent;
  }
  
  /// Get pattern ID for a practice, handling both recurring and actual practices
  static String? getPatternId(Practice practice) {
    // For recurring practices, the ID is the patternId
    // For actual practices, check the patternId field
    return practice.patternId ?? practice.id;
  }
  
  /// Verify that a practice has a valid pattern ID structure
  static bool hasValidPatternId(Practice practice) {
    final patternId = getPatternId(practice);
    if (patternId == null || patternId.isEmpty) return false;
    
    // Pattern ID should have format: club-day-time-location-count
    // e.g., "denver-sun-1100-vmac-1"
    final parts = patternId.split('-');
    return parts.length >= 5; // At least club, day, time, location, count
  }
  
  /// Extract human-readable info from pattern ID for debugging
  static Map<String, String> parsePatternId(String patternId) {
    final parts = patternId.split('-');
    if (parts.length < 5) {
      return {'error': 'Invalid pattern ID format'};
    }
    
    return {
      'club': parts[0],
      'day': parts[1],
      'time': parts[2],
      'location': parts[3],
      'count': parts[4],
      'full': patternId,
    };
  }
  
  /// Log practice list with pattern IDs for debugging
  static void logPracticeList(List<Practice> practices, String context) {
    debugPrint('=== $context ===');
    for (final practice in practices) {
      final patternId = getPatternId(practice);
      final isValid = hasValidPatternId(practice);
      debugPrint('${practice.title}: $patternId ${isValid ? '✓' : '✗'}');
    }
    debugPrint('=== End $context ===');
  }
}