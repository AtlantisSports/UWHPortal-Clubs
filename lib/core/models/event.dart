/// Event model matching uwhportal backend structure
library;

import 'base_model.dart';

class Event extends BaseModel {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String? imageUrl;
  final String clubId;
  final int maxParticipants;
  final int currentParticipants;
  final double? price;
  final EventStatus status;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    this.imageUrl,
    required this.clubId,
    required this.maxParticipants,
    this.currentParticipants = 0,
    this.price,
    this.status = EventStatus.upcoming,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Create Event from JSON (compatible with uwhportal API response)
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      location: json['location'] as String,
      imageUrl: json['imageUrl'] as String?,
      clubId: json['clubId'] as String,
      maxParticipants: json['maxParticipants'] as int,
      currentParticipants: json['currentParticipants'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble(),
      status: EventStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => EventStatus.upcoming,
      ),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'location': location,
      'imageUrl': imageUrl,
      'clubId': clubId,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'price': price,
      'status': status.name,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  @override
  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? imageUrl,
    String? clubId,
    int? maxParticipants,
    int? currentParticipants,
    double? price,
    EventStatus? status,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      clubId: clubId ?? this.clubId,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      price: price ?? this.price,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Check if event has available spots
  bool get hasAvailableSpots => currentParticipants < maxParticipants;
  
  /// Check if event is free
  bool get isFree => price == null || price == 0;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

enum EventStatus {
  upcoming,
  ongoing,
  completed,
  cancelled,
}
