/// Data transformation layer for Practice model
/// 
/// Handles mapping between internal Flutter models and external API formats.
/// This isolates the app from API schema changes and provides a clean
/// integration point for backend services.
library;

import '../models/practice.dart';

/// Mapper for Practice model transformations
class PracticeMapper {
  /// Transform API response to internal Practice model
  static Practice fromApiResponse(Map<String, dynamic> json) {
    return Practice(
      id: json['id'] as String,
      clubId: json['clubId'] as String,
      patternId: json['patternId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      location: json['location'] as String,
      address: json['address'] as String,
      duration: Duration(minutes: json['duration'] as int),
      maxParticipants: json['maxParticipants'] as int? ?? 20,
      participants: (json['participants'] as List<dynamic>?)?.cast<String>() ?? [],
      participationResponses: _parseParticipationResponses(json['participationResponses']),
      isRecurring: json['isRecurring'] as bool? ?? false,
      tag: json['tag'] as String?,
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'] as String)
        : null,
      updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'] as String)
        : null,
    );
  }

  /// Transform internal Practice model to API request format
  static Map<String, dynamic> toApiRequest(Practice practice) {
    return {
      'clubId': practice.clubId,
      'patternId': practice.patternId,
      'title': practice.title,
      'description': practice.description,
      'dateTime': practice.dateTime.toIso8601String(),
      'location': practice.location,
      'address': practice.address,
      'duration': practice.duration.inMinutes,
      'maxParticipants': practice.maxParticipants,
      'isRecurring': practice.isRecurring,
      'tag': practice.tag,
    };
  }

  /// Transform internal Practice model to API update format
  static Map<String, dynamic> toApiUpdateRequest(Practice practice) {
    final request = toApiRequest(practice);
    // Add ID for update requests
    request['id'] = practice.id;
    if (practice.updatedAt != null) {
      request['updatedAt'] = practice.updatedAt!.toIso8601String();
    }
    return request;
  }

  /// Transform list of API responses to internal Practice models
  static List<Practice> fromApiResponseList(List<dynamic> jsonList) {
    return jsonList
      .cast<Map<String, dynamic>>()
      .map((json) => fromApiResponse(json))
      .toList();
  }

  /// Transform list of internal Practice models to API request format
  static List<Map<String, dynamic>> toApiRequestList(List<Practice> practices) {
    return practices.map((practice) => toApiRequest(practice)).toList();
  }

  /// Parse participation responses from API format
  static Map<String, ParticipationStatus> _parseParticipationResponses(dynamic responses) {
    if (responses == null) return {};
    
    final Map<String, dynamic> responseMap = responses as Map<String, dynamic>;
    final Map<String, ParticipationStatus> result = {};
    
    responseMap.forEach((userId, statusString) {
      final status = _parseParticipationStatus(statusString as String);
      if (status != null) {
        result[userId] = status;
      }
    });
    
    return result;
  }

  /// Parse participation status from string
  static ParticipationStatus? _parseParticipationStatus(String statusString) {
    switch (statusString.toLowerCase()) {
      case 'yes':
        return ParticipationStatus.yes;
      case 'no':
        return ParticipationStatus.no;
      case 'maybe':
        return ParticipationStatus.maybe;
      case 'blank':
        return ParticipationStatus.blank;
      case 'attended':
        return ParticipationStatus.attended;
      case 'missed':
        return ParticipationStatus.missed;
      default:
        return ParticipationStatus.blank; // Default to blank instead of null
    }
  }

  /// Convert participation status to API string format
  static String participationStatusToApi(ParticipationStatus status) {
    switch (status) {
      case ParticipationStatus.yes:
        return 'yes';
      case ParticipationStatus.no:
        return 'no';
      case ParticipationStatus.maybe:
        return 'maybe';
      case ParticipationStatus.blank:
        return 'blank';
      case ParticipationStatus.attended:
        return 'attended';
      case ParticipationStatus.missed:
        return 'missed';
    }
  }

  // Note: Field transformation methods (_transformApiFields, _transformForApi)
  // can be added here when needed for specific API integration requirements

  /// Create a Practice from mock data (for development)
  /// This ensures mock data goes through the same transformation pipeline
  static Practice fromMockData(Map<String, dynamic> mockJson) {
    // Mock data is already in the correct format, but we still
    // run it through the transformation to ensure consistency
    return fromApiResponse(mockJson);
  }

  /// Validate API response structure
  /// Helps catch API contract violations early
  static bool isValidApiResponse(Map<String, dynamic> json) {
    final requiredFields = ['id', 'clubId', 'title', 'description', 'dateTime', 'location', 'address'];
    
    for (final field in requiredFields) {
      if (!json.containsKey(field) || json[field] == null) {
        return false;
      }
    }
    
    // Validate dateTime format
    try {
      DateTime.parse(json['dateTime'] as String);
    } catch (e) {
      return false;
    }
    
    return true;
  }

  /// Create error-safe Practice from potentially malformed API response
  static Practice? fromApiResponseSafe(Map<String, dynamic> json) {
    try {
      if (!isValidApiResponse(json)) {
        return null;
      }
      return fromApiResponse(json);
    } catch (e) {
      // Log error in production - replace with proper logging framework
      // logger.error('PracticeMapper: Failed to parse API response: $e');
      return null;
    }
  }

  /// Transform RSVP request to API format
  static Map<String, dynamic> rsvpToApiRequest({
    required String userId,
    required String practiceId,
    required ParticipationStatus status,
    List<Map<String, dynamic>>? guests,
  }) {
    return {
      'userId': userId,
      'practiceId': practiceId,
      'status': participationStatusToApi(status),
      if (guests != null) 'guests': guests,
    };
  }

  /// Transform bulk RSVP request to API format
  static Map<String, dynamic> bulkRsvpToApiRequest({
    required String userId,
    required List<String> practiceIds,
    required ParticipationStatus status,
    String? timeframe,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return {
      'userId': userId,
      'practiceIds': practiceIds,
      'status': participationStatusToApi(status),
      if (timeframe != null) 'timeframe': timeframe,
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
    };
  }
}
