/// Data transformation layer for Club model
/// 
/// Handles mapping between internal Flutter models and external API formats.
/// This isolates the app from API schema changes and provides a clean
/// integration point for backend services.
library;

import '../models/club.dart';
import 'practice_mapper.dart';

/// Mapper for Club model transformations
class ClubMapper {
  /// Transform API response to internal Club model
  static Club fromApiResponse(Map<String, dynamic> json) {
    return Club(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String? ?? json['name'] as String,
      longName: json['longName'] as String? ?? json['name'] as String,
      description: json['description'] as String,
      logoUrl: json['logoUrl'] as String?,
      location: json['location'] as String,
      contactEmail: json['contactEmail'] as String,
      website: json['website'] as String?,
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'] as String)
        : null,
      updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'] as String)
        : null,
      isActive: json['isActive'] as bool? ?? true,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      memberCount: json['memberCount'] as int? ?? 0,
      upcomingPractices: (json['upcomingPractices'] as List<dynamic>?)
        ?.map((practiceJson) => PracticeMapper.fromApiResponse(practiceJson as Map<String, dynamic>))
        .toList() ?? [],
    );
  }

  /// Transform internal Club model to API request format
  static Map<String, dynamic> toApiRequest(Club club) {
    return {
      'name': club.name,
      'shortName': club.shortName,
      'longName': club.longName,
      'description': club.description,
      'logoUrl': club.logoUrl,
      'location': club.location,
      'contactEmail': club.contactEmail,
      'website': club.website,
      'isActive': club.isActive,
      'tags': club.tags,
      'memberCount': club.memberCount,
      // Note: upcomingPractices typically not sent in club creation/update requests
    };
  }

  /// Transform internal Club model to API update format
  static Map<String, dynamic> toApiUpdateRequest(Club club) {
    final request = toApiRequest(club);
    // Add ID for update requests
    request['id'] = club.id;
    if (club.updatedAt != null) {
      request['updatedAt'] = club.updatedAt!.toIso8601String();
    }
    return request;
  }

  /// Transform list of API responses to internal Club models
  static List<Club> fromApiResponseList(List<dynamic> jsonList) {
    return jsonList
      .cast<Map<String, dynamic>>()
      .map((json) => fromApiResponse(json))
      .toList();
  }

  /// Transform list of internal Club models to API request format
  static List<Map<String, dynamic>> toApiRequestList(List<Club> clubs) {
    return clubs.map((club) => toApiRequest(club)).toList();
  }

  // Note: Field transformation methods (_transformApiFields, _transformForApi)
  // can be added here when needed for specific API integration requirements

  /// Create a Club from mock data (for development)
  /// This ensures mock data goes through the same transformation pipeline
  static Club fromMockData(Map<String, dynamic> mockJson) {
    // Mock data is already in the correct format, but we still
    // run it through the transformation to ensure consistency
    return fromApiResponse(mockJson);
  }

  /// Validate API response structure
  /// Helps catch API contract violations early
  static bool isValidApiResponse(Map<String, dynamic> json) {
    final requiredFields = ['id', 'name', 'description', 'location', 'contactEmail'];
    
    for (final field in requiredFields) {
      if (!json.containsKey(field) || json[field] == null) {
        return false;
      }
    }
    
    return true;
  }

  /// Create error-safe Club from potentially malformed API response
  static Club? fromApiResponseSafe(Map<String, dynamic> json) {
    try {
      if (!isValidApiResponse(json)) {
        return null;
      }
      return fromApiResponse(json);
    } catch (e) {
      // Log error in production - replace with proper logging framework
      // logger.error('ClubMapper: Failed to parse API response: $e');
      return null;
    }
  }
}
