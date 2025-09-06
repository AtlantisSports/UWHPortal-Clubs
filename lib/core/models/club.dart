/// Club model matching uwhportal backend structure
library;

import 'base_model.dart';

class Club extends BaseModel {
  final String id;
  final String name;
  final String description;
  final String? logoUrl;
  final String location;
  final String contactEmail;
  final String? website;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final List<String> tags;
  
  Club({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl,
    required this.location,
    required this.contactEmail,
    this.website,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.tags = const [],
  });
  
  /// Create Club from JSON (compatible with uwhportal API response)
  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      logoUrl: json['logoUrl'] as String?,
      location: json['location'] as String,
      contactEmail: json['contactEmail'] as String,
      website: json['website'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'location': location,
      'contactEmail': contactEmail,
      'website': website,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'tags': tags,
    };
  }
  
  @override
  Club copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    String? location,
    String? contactEmail,
    String? website,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    List<String>? tags,
  }) {
    return Club(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      location: location ?? this.location,
      contactEmail: contactEmail ?? this.contactEmail,
      website: website ?? this.website,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      tags: tags ?? this.tags,
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
