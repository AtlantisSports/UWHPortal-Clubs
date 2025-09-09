/// Club model matching uwhportal backend structure
library;

import 'base_model.dart';
import 'practice.dart';

class Club extends BaseModel {
  final String name; // Keep for backwards compatibility
  final String shortName;
  final String longName;
  final String description;
  final String? logoUrl;
  final String location;
  final String contactEmail;
  final String? website;
  final bool isActive;
  final List<String> tags;
  final int memberCount;
  final List<Practice> upcomingPractices;
  
  Club({
    required super.id,
    required this.name,
    required this.shortName,
    required this.longName,
    required this.description,
    this.logoUrl,
    required this.location,
    required this.contactEmail,
    this.website,
    super.createdAt,
    super.updatedAt,
    this.isActive = true,
    this.tags = const [],
    this.memberCount = 0,
    this.upcomingPractices = const [],
  });
  
  /// Create Club from JSON (compatible with uwhportal API response)
  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String? ?? json['name'] as String, // Fallback to name if shortName not provided
      longName: json['longName'] as String? ?? json['name'] as String, // Fallback to name if longName not provided
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
        ?.map((practiceJson) => Practice.fromJson(practiceJson as Map<String, dynamic>))
        .toList() ?? [],
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'name': name,
      'shortName': shortName,
      'longName': longName,
      'description': description,
      'logoUrl': logoUrl,
      'location': location,
      'contactEmail': contactEmail,
      'website': website,
      'isActive': isActive,
      'tags': tags,
      'memberCount': memberCount,
      'upcomingPractices': upcomingPractices.map((practice) => practice.toJson()).toList(),
    };
  }
  
  @override
  Club copyWith({
    String? name,
    String? shortName,
    String? longName,
    String? description,
    String? logoUrl,
    String? location,
    String? contactEmail,
    String? website,
    bool? isActive,
    List<String>? tags,
    int? memberCount,
    List<Practice>? upcomingPractices,
  }) {
    return Club(
      id: id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      longName: longName ?? this.longName,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      location: location ?? this.location,
      contactEmail: contactEmail ?? this.contactEmail,
      website: website ?? this.website,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isActive: isActive ?? this.isActive,
      tags: tags ?? this.tags,
      memberCount: memberCount ?? this.memberCount,
      upcomingPractices: upcomingPractices ?? this.upcomingPractices,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Club && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
