/// Practice model for club practice sessions
library;

import 'package:flutter/material.dart';
import 'base_model.dart';

/// RSVP status enum with circle-based UI design
enum RSVPStatus {
  yes,     // Green circle with checkmark
  maybe,   // Yellow circle with plain question mark  
  no,      // Red circle with X
  pending  // Default state - empty circle outline
}

/// Extension to get display properties for RSVP status
extension RSVPStatusExtension on RSVPStatus {
  /// Get the color for this RSVP status
  Color get color {
    switch (this) {
      case RSVPStatus.yes:
        return const Color(0xFF10B981); // Green
      case RSVPStatus.maybe:
        return const Color(0xFFF59E0B); // Yellow
      case RSVPStatus.no:
        return const Color(0xFFEF4444); // Red
      case RSVPStatus.pending:
        return const Color(0xFF6B7280); // Gray
    }
  }
  
  /// Get the overlay icon for this RSVP status
  IconData get overlayIcon {
    switch (this) {
      case RSVPStatus.yes:
        return Icons.check;
      case RSVPStatus.maybe:
        return Icons.help; // Plain question mark without any circle
      case RSVPStatus.no:
        return Icons.close; // X mark for "no"
      case RSVPStatus.pending:
        return Icons.radio_button_unchecked;
    }
  }
  
  /// Get the display text for this RSVP status
  String get displayText {
    switch (this) {
      case RSVPStatus.yes:
        return 'Yes, I\'ll attend';
      case RSVPStatus.maybe:
        return 'Maybe, not sure yet';
      case RSVPStatus.no:
        return 'No, can\'t make it';
      case RSVPStatus.pending:
        return 'Not responded yet';
    }
  }
}

/// Practice session model
class Practice extends BaseModel {
  final String clubId;
  final String title;
  final String description;
  final DateTime dateTime;
  final String location;
  final String address;
  final Duration duration;
  final int maxParticipants;
  final List<String> participants;
  final Map<String, RSVPStatus> rsvpResponses;
  final bool isRecurring;
  final String? recurringPattern;
  
  Practice({
    required super.id,
    required this.clubId,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.address,
    this.duration = const Duration(hours: 2),
    this.maxParticipants = 20,
    this.participants = const [],
    this.rsvpResponses = const {},
    this.isRecurring = false,
    this.recurringPattern,
    super.createdAt,
    super.updatedAt,
  });
  
  /// Get RSVP status for a specific user
  RSVPStatus getRSVPStatus(String userId) {
    return rsvpResponses[userId] ?? RSVPStatus.pending;
  }
  
  /// Get count of each RSVP status
  Map<RSVPStatus, int> getRSVPCounts() {
    final counts = <RSVPStatus, int>{
      RSVPStatus.yes: 0,
      RSVPStatus.maybe: 0,
      RSVPStatus.no: 0,
      RSVPStatus.pending: 0,
    };
    
    for (final status in rsvpResponses.values) {
      counts[status] = (counts[status] ?? 0) + 1;
    }
    
    return counts;
  }
  
  /// Check if practice is upcoming (in the future)
  bool get isUpcoming => dateTime.isAfter(DateTime.now());
  
  /// Check if practice is happening today
  bool get isToday {
    final now = DateTime.now();
    final practiceDate = dateTime;
    return now.year == practiceDate.year &&
           now.month == practiceDate.month &&
           now.day == practiceDate.day;
  }
  
  /// Get formatted time string
  String get formattedTime {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
  
  /// Get formatted date string
  String get formattedDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return '${weekdays[dateTime.weekday - 1]}, ${months[dateTime.month - 1]} ${dateTime.day}';
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'clubId': clubId,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'address': address,
      'duration': duration.inMinutes,
      'maxParticipants': maxParticipants,
      'participants': participants,
      'rsvpResponses': rsvpResponses.map((key, value) => MapEntry(key, value.name)),
      'isRecurring': isRecurring,
      'recurringPattern': recurringPattern,
    };
  }
  
  factory Practice.fromJson(Map<String, dynamic> json) {
    return Practice(
      id: json['id'] as String,
      clubId: json['clubId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      location: json['location'] as String,
      address: json['address'] as String,
      duration: Duration(minutes: json['duration'] as int? ?? 120),
      maxParticipants: json['maxParticipants'] as int? ?? 20,
      participants: List<String>.from(json['participants'] as List? ?? []),
      rsvpResponses: (json['rsvpResponses'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, RSVPStatus.values.firstWhere(
          (status) => status.name == value,
          orElse: () => RSVPStatus.pending,
        )),
      ) ?? {},
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringPattern: json['recurringPattern'] as String?,
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'] as String)
        : null,
      updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'] as String) 
        : null,
    );
  }
  
  @override
  Practice copyWith({
    String? clubId,
    String? title,
    String? description,
    DateTime? dateTime,
    String? location,
    String? address,
    Duration? duration,
    int? maxParticipants,
    List<String>? participants,
    Map<String, RSVPStatus>? rsvpResponses,
    bool? isRecurring,
    String? recurringPattern,
  }) {
    return Practice(
      id: id,
      clubId: clubId ?? this.clubId,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      address: address ?? this.address,
      duration: duration ?? this.duration,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participants: participants ?? this.participants,
      rsvpResponses: rsvpResponses ?? this.rsvpResponses,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
