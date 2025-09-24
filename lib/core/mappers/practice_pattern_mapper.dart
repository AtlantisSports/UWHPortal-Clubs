/// Data transformation layer for PracticePattern model
/// 
/// Handles mapping between internal Flutter models and external API formats.
/// This isolates the app from API schema changes and provides a clean
/// integration point for backend services.
library;

import '../models/practice_pattern.dart';
import '../models/practice_recurrence.dart';

/// Mapper for PracticePattern model transformations
class PracticePatternMapper {
  /// Transform API response to internal PracticePattern model
  static PracticePattern fromApiResponse(Map<String, dynamic> json) {
    return PracticePattern(
      id: json['id'] as String,
      clubId: json['clubId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      day: _parsePatternDay(json['day'] as String),
      startTime: _parsePatternTime(json['startTime']),
      duration: Duration(minutes: json['duration'] as int),
      location: json['location'] as String,
      address: json['address'] as String,
      tag: json['tag'] as String?,
      recurrence: _parseRecurrencePattern(json['recurrence']),
      patternStartDate: json['patternStartDate'] != null 
        ? DateTime.parse(json['patternStartDate'] as String)
        : null,
      patternEndDate: json['patternEndDate'] != null
        ? DateTime.parse(json['patternEndDate'] as String)
        : null,
    );
  }

  /// Transform internal PracticePattern model to API request format
  static Map<String, dynamic> toApiRequest(PracticePattern pattern) {
    return {
      'clubId': pattern.clubId,
      'title': pattern.title,
      'description': pattern.description,
      'day': _patternDayToString(pattern.day),
      'startTime': _patternTimeToJson(pattern.startTime),
      'duration': pattern.duration.inMinutes,
      'location': pattern.location,
      'address': pattern.address,
      'tag': pattern.tag,
      'recurrence': _recurrencePatternToJson(pattern.recurrence),
      'patternStartDate': pattern.patternStartDate?.toIso8601String(),
      'patternEndDate': pattern.patternEndDate?.toIso8601String(),
    };
  }

  /// Transform internal PracticePattern model to API update format
  static Map<String, dynamic> toApiUpdateRequest(PracticePattern pattern) {
    final request = toApiRequest(pattern);
    // Add ID for update requests
    request['id'] = pattern.id;
    return request;
  }

  /// Transform list of API responses to internal PracticePattern models
  static List<PracticePattern> fromApiResponseList(List<dynamic> jsonList) {
    return jsonList
      .cast<Map<String, dynamic>>()
      .map((json) => fromApiResponse(json))
      .toList();
  }

  /// Transform list of internal PracticePattern models to API request format
  static List<Map<String, dynamic>> toApiRequestList(List<PracticePattern> patterns) {
    return patterns.map((pattern) => toApiRequest(pattern)).toList();
  }

  /// Parse PatternDay from string
  static PatternDay _parsePatternDay(String dayString) {
    switch (dayString.toLowerCase()) {
      case 'monday':
        return PatternDay.monday;
      case 'tuesday':
        return PatternDay.tuesday;
      case 'wednesday':
        return PatternDay.wednesday;
      case 'thursday':
        return PatternDay.thursday;
      case 'friday':
        return PatternDay.friday;
      case 'saturday':
        return PatternDay.saturday;
      case 'sunday':
        return PatternDay.sunday;
      default:
        throw ArgumentError('Invalid day string: $dayString');
    }
  }

  /// Convert PatternDay to string
  static String _patternDayToString(PatternDay day) {
    return day.name;
  }

  /// Parse PatternTime from JSON
  static PatternTime _parsePatternTime(dynamic timeJson) {
    if (timeJson is Map<String, dynamic>) {
      return PatternTime(
        timeJson['hour'] as int,
        timeJson['minute'] as int,
      );
    }
    throw ArgumentError('Invalid time format: $timeJson');
  }

  /// Convert PatternTime to JSON
  static Map<String, dynamic> _patternTimeToJson(PatternTime time) {
    return {
      'hour': time.hour,
      'minute': time.minute,
    };
  }

  /// Parse RecurrencePattern from JSON
  static RecurrencePattern _parseRecurrencePattern(dynamic recurrenceJson) {
    if (recurrenceJson == null) {
      return const RecurrencePattern.weekly();
    }
    
    if (recurrenceJson is Map<String, dynamic>) {
      final type = recurrenceJson['type'] as String;
      final interval = recurrenceJson['interval'] as int? ?? 1;
      final endDate = recurrenceJson['endDate'] != null 
        ? DateTime.parse(recurrenceJson['endDate'] as String)
        : null;
      
      switch (type.toLowerCase()) {
        case 'weekly':
          return RecurrencePattern(type: RecurrenceType.weekly, interval: interval, endDate: endDate);
        case 'biweekly':
          return const RecurrencePattern.biweekly();
        case 'every3weeks':
          return const RecurrencePattern.every3weeks();
        case 'monthly':
          return RecurrencePattern(type: RecurrenceType.monthly, interval: interval, endDate: endDate);
        case 'custom':
          return RecurrencePattern(type: RecurrenceType.custom, interval: interval, endDate: endDate);
        default:
          return const RecurrencePattern.weekly();
      }
    }
    
    return const RecurrencePattern.weekly();
  }

  /// Convert RecurrencePattern to JSON
  static Map<String, dynamic> _recurrencePatternToJson(RecurrencePattern recurrence) {
    return {
      'type': _recurrenceTypeToString(recurrence.type),
      'interval': recurrence.interval,
      'endDate': recurrence.endDate?.toIso8601String(),
    };
  }

  /// Convert RecurrenceType to string
  static String _recurrenceTypeToString(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.weekly:
        return 'weekly';
      case RecurrenceType.biweekly:
        return 'biweekly';
      case RecurrenceType.every3weeks:
        return 'every3weeks';
      case RecurrenceType.monthly:
        return 'monthly';
      case RecurrenceType.monthlyByWeek:
        return 'monthlyByWeek';
      case RecurrenceType.custom:
        return 'custom';
      case RecurrenceType.none:
        return 'none';
    }
  }

  // Note: Field transformation methods (_transformApiFields, _transformForApi)
  // can be added here when needed for specific API integration requirements

  /// Create a PracticePattern from mock data (for development)
  /// This ensures mock data goes through the same transformation pipeline
  static PracticePattern fromMockData(Map<String, dynamic> mockJson) {
    // Mock data is already in the correct format, but we still
    // run it through the transformation to ensure consistency
    return fromApiResponse(mockJson);
  }

  /// Validate API response structure
  /// Helps catch API contract violations early
  static bool isValidApiResponse(Map<String, dynamic> json) {
    final requiredFields = ['id', 'clubId', 'title', 'description', 'day', 'startTime', 'duration', 'location', 'address'];
    
    for (final field in requiredFields) {
      if (!json.containsKey(field) || json[field] == null) {
        return false;
      }
    }
    
    // Validate day format
    try {
      _parsePatternDay(json['day'] as String);
    } catch (e) {
      return false;
    }
    
    // Validate startTime format
    try {
      _parsePatternTime(json['startTime']);
    } catch (e) {
      return false;
    }
    
    return true;
  }

  /// Create error-safe PracticePattern from potentially malformed API response
  static PracticePattern? fromApiResponseSafe(Map<String, dynamic> json) {
    try {
      if (!isValidApiResponse(json)) {
        return null;
      }
      return fromApiResponse(json);
    } catch (e) {
      // Log error in production - replace with proper logging framework
      // logger.error('PracticePatternMapper: Failed to parse API response: $e');
      return null;
    }
  }

  /// Transform pattern generation request to API format
  static Map<String, dynamic> generatePracticesRequest({
    required String patternId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return {
      'patternId': patternId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}
