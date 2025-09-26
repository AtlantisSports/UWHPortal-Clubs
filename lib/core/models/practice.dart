

import 'package:flutter/material.dart';
import 'base_model.dart';
import '../constants/app_constants.dart';

/// Bulk participation status request model for updating multiple practices
class BulkParticipationRequest {
  final List<String> practiceIds;
  final ParticipationStatus newStatus;
  final String clubId;
  final String userId;
  final bool includeDependents;
  final List<String> selectedDependents;
  
  const BulkParticipationRequest({
    required this.practiceIds,
    required this.newStatus,
    required this.clubId,
    required this.userId,
    this.includeDependents = false,
    this.selectedDependents = const [],
  });
  
  Map<String, dynamic> toJson() {
    return {
      'practiceIds': practiceIds,
      'newStatus': newStatus.name,
      'clubId': clubId,
      'userId': userId,
      'includeDependents': includeDependents,
      'selectedDependents': selectedDependents,
    };
  }
}

/// Result of bulk participation status operation
class BulkParticipationResult {
  final List<String> successfulIds;
  final List<String> failedIds;
  final Map<String, String> errors; // practiceId -> error message
  final ParticipationStatus appliedStatus;
  
  const BulkParticipationResult({
    required this.successfulIds,
    required this.failedIds,
    required this.errors,
    required this.appliedStatus,
  });
  
  bool get isFullSuccess => failedIds.isEmpty;
  bool get isPartialSuccess => successfulIds.isNotEmpty && failedIds.isNotEmpty;
  bool get isCompleteFailure => successfulIds.isEmpty;
  int get totalProcessed => successfulIds.length + failedIds.length;
  
  String get summaryText {
    if (isFullSuccess) {
      return '${successfulIds.length} practices updated to ${appliedStatus.displayText}';
    } else if (isPartialSuccess) {
  return '${successfulIds.length}/$totalProcessed practices updated successfully';
    } else {
      return 'Failed to update practices';
    }
  }
}

/// RSVP status enum with circle-based UI design
/// Unified practice participation status enum
/// Handles both RSVP (future) and attendance (past) states
enum ParticipationStatus {
  blank,     // No RSVP response given (default state)
  yes,       // Will attend - Green circle with checkmark
  maybe,     // Unsure - Yellow circle with question mark  
  no,        // Cannot attend - Red circle with X
  attended,  // Confirmed attendance (past practices, admin-only)
  missed     // Did not attend (past practices, admin-only)
}

/// Extension to get display properties for participation status
extension ParticipationStatusExtension on ParticipationStatus {
  /// Get the color for this participation status
  Color get color {
    switch (this) {
      case ParticipationStatus.blank:
        return const Color(0xFF6B7280); // Gray
      case ParticipationStatus.yes:
        return AppColors.success; // Green
      case ParticipationStatus.maybe:
        return AppColors.maybe; // Yellow
      case ParticipationStatus.no:
        return AppColors.error; // Red
      case ParticipationStatus.attended:
        return AppColors.primary; // System blue
      case ParticipationStatus.missed:
        return AppColors.primary; // System blue
    }
  }
  
  /// Get the overlay icon for this participation status
  IconData get overlayIcon {
    switch (this) {
      case ParticipationStatus.blank:
        return Icons.radio_button_unchecked;
      case ParticipationStatus.yes:
        return Icons.check;
      case ParticipationStatus.maybe:
        return Icons.question_mark; // Plain question mark
      case ParticipationStatus.no:
        return Icons.close; // X mark for "no"
      case ParticipationStatus.attended:
        return Icons.check_circle; // Filled check for confirmed attendance
      case ParticipationStatus.missed:
        return Icons.cancel; // Filled X for confirmed absence
    }
  }
  
  /// Get the display text for this participation status
  String get displayText {
    switch (this) {
      case ParticipationStatus.blank:
        return 'Not responded yet';
      case ParticipationStatus.yes:
        return 'Yes, I\'ll attend';
      case ParticipationStatus.maybe:
        return 'Maybe, not sure yet';
      case ParticipationStatus.no:
        return 'No, can\'t make it';
      case ParticipationStatus.attended:
        return 'Attended';
      case ParticipationStatus.missed:
        return 'Did not attend';
    }
  }
  
  /// Get the toast message for this participation status change
  String get toastMessage {
    switch (this) {
      case ParticipationStatus.blank:
        return 'RSVP status cleared';
      case ParticipationStatus.yes:
        return 'RSVP changed to: Yes, I\'ll attend';
      case ParticipationStatus.maybe:
        return 'RSVP changed to: Maybe, not sure yet';
      case ParticipationStatus.no:
        return 'RSVP changed to: No, can\'t make it';
      case ParticipationStatus.attended:
        return 'Marked as attended';
      case ParticipationStatus.missed:
        return 'Marked as missed';
    }
  }
  
  /// Check if this is an RSVP state (for future practices)
  bool get isRSVPState => [
    ParticipationStatus.blank,
    ParticipationStatus.yes,
    ParticipationStatus.maybe,
    ParticipationStatus.no,
  ].contains(this);
  
  /// Check if this is an attendance state (for past practices)
  bool get isAttendanceState => [
    ParticipationStatus.attended,
    ParticipationStatus.missed,
  ].contains(this);
  
  /// Check if this status indicates attendance/willingness to attend
  bool get indicatesAttendance => [
    ParticipationStatus.yes,
    ParticipationStatus.attended,
  ].contains(this);
  
  /// Check if this status indicates non-attendance
  bool get indicatesNonAttendance => [
    ParticipationStatus.no,
    ParticipationStatus.missed,
  ].contains(this);
}

/// Practice session model
class Practice extends BaseModel {
  final String clubId;
  final String? patternId; // Links to the practice pattern this instance belongs to
  final String title;
  final String description;
  final DateTime dateTime;
  final String location;
  final String address;
  final Duration duration;
  final int maxParticipants;
  final List<String> participants;
  final Map<String, ParticipationStatus> participationResponses;
  // Per-user conditional-yes threshold (presence implies user selected Conditional Yes)
  final Map<String, int> conditionalYesThresholds;
  final bool isRecurring;
  final String? recurringPattern;
  final String? tag; // Practice level/type tag (e.g., "Open", "High-Level", "Intermediate")

  Practice({
    required super.id,
    required this.clubId,
    this.patternId,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.address,
    this.duration = const Duration(hours: 2),
    this.maxParticipants = 20,
    this.participants = const [],
    this.participationResponses = const {},
    this.conditionalYesThresholds = const {},
    this.isRecurring = false,
    this.recurringPattern,
    this.tag,
    super.createdAt,
    super.updatedAt,
  });

  /// Get participation status for a specific user
  ParticipationStatus getParticipationStatus(String userId) {
    return participationResponses[userId] ?? ParticipationStatus.blank;
  }
  
  /// Get count of each participation status
  Map<ParticipationStatus, int> getParticipationCounts() {
    final counts = <ParticipationStatus, int>{
      ParticipationStatus.blank: 0,
      ParticipationStatus.yes: 0,
      ParticipationStatus.maybe: 0,
      ParticipationStatus.no: 0,
      ParticipationStatus.attended: 0,
      ParticipationStatus.missed: 0,
    };
    
    for (final status in participationResponses.values) {
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
  
  /// Get Google Maps URL for the location
  String get mapsUrl {
    final encodedAddress = Uri.encodeComponent(address.isNotEmpty ? address : location);
    return 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
  }
  
  /// Check if RSVP window is still open (until 30 min after practice starts)
  bool get isRSVPWindowOpen {
    final now = DateTime.now();
    final rsvpDeadline = dateTime.add(const Duration(minutes: 30));
    return now.isBefore(rsvpDeadline);
  }
  
  /// Check if practice is in "past mode" (attendance can be recorded)
  bool get isInPastMode {
    final now = DateTime.now();
    final practiceEnd = dateTime.add(duration);
    return now.isAfter(practiceEnd);
  }
  
  /// Check if practice is currently happening
  bool get isCurrentlyHappening {
    final now = DateTime.now();
    final practiceEnd = dateTime.add(duration);
    return now.isAfter(dateTime) && now.isBefore(practiceEnd);
  }
  
  /// Get available participation statuses for this practice based on timing and user role
  List<ParticipationStatus> getAvailableStatuses({bool isAdmin = false}) {
    if (isAdmin) {
      // Admins can always set attendance status for past practices
      if (isInPastMode) {
        return [ParticipationStatus.attended, ParticipationStatus.missed];
      }
      // Admins can also manage RSVP for future practices
      return [
        ParticipationStatus.blank,
        ParticipationStatus.yes,
        ParticipationStatus.maybe,
        ParticipationStatus.no,
      ];
    } else {
      // Regular users can only RSVP if window is open
      if (isRSVPWindowOpen) {
        return [
          ParticipationStatus.blank,
          ParticipationStatus.yes,
          ParticipationStatus.maybe,
          ParticipationStatus.no,
        ];
      }
      // No options available for regular users if RSVP window closed
      return [];
    }
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'clubId': clubId,
      'patternId': patternId,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'address': address,
      'duration': duration.inMinutes,
      'maxParticipants': maxParticipants,
      'participants': participants,
      'participationResponses': participationResponses.map((key, value) => MapEntry(key, value.name)),
      'conditionalYesThresholds': conditionalYesThresholds,
      'isRecurring': isRecurring,
      'recurringPattern': recurringPattern,
    };
  }
  
  factory Practice.fromJson(Map<String, dynamic> json) {
    return Practice(
      id: json['id'] as String,
      clubId: json['clubId'] as String,
      patternId: json['patternId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      location: json['location'] as String,
      address: json['address'] as String,
      duration: Duration(minutes: json['duration'] as int? ?? 120),
      maxParticipants: json['maxParticipants'] as int? ?? 20,
      participants: List<String>.from(json['participants'] as List? ?? []),
      participationResponses: (json['participationResponses'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, ParticipationStatus.values.firstWhere(
          (status) => status.name == value,
          orElse: () => ParticipationStatus.blank,
        )),
      ) ?? {},
      conditionalYesThresholds: (json['conditionalYesThresholds'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, (value as num).toInt()),
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
    String? patternId,
    String? title,
    String? description,
    DateTime? dateTime,
    String? location,
    String? address,
    Duration? duration,
    int? maxParticipants,
    List<String>? participants,
    Map<String, ParticipationStatus>? participationResponses,
    Map<String, int>? conditionalYesThresholds,
    bool? isRecurring,
    String? recurringPattern,
    String? tag,
  }) {
    return Practice(
      id: id,
      clubId: clubId ?? this.clubId,
      patternId: patternId ?? this.patternId,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      address: address ?? this.address,
      duration: duration ?? this.duration,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participants: participants ?? this.participants,
      participationResponses: participationResponses ?? this.participationResponses,
      conditionalYesThresholds: conditionalYesThresholds ?? this.conditionalYesThresholds,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      tag: tag ?? this.tag,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
