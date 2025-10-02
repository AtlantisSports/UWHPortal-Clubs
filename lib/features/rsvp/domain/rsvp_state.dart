import 'package:flutter/foundation.dart';

import '../../../core/models/guest.dart';
import '../../../core/models/practice.dart';

/// Minimal RSVP state model used by the RSVP facade.
class RsvpState {
  final ParticipationStatus status;
  final List<Guest> guests;
  final bool isWindowOpen;
  final bool isLoading;
  final String? error;

  const RsvpState({
    required this.status,
    required this.guests,
    required this.isWindowOpen,
    this.isLoading = false,
    this.error,
  });

  RsvpState copyWith({
    ParticipationStatus? status,
    List<Guest>? guests,
    bool? isWindowOpen,
    bool? isLoading,
    String? error, // pass empty string to clear
  }) {
    return RsvpState(
      status: status ?? this.status,
      guests: guests ?? this.guests,
      isWindowOpen: isWindowOpen ?? this.isWindowOpen,
      isLoading: isLoading ?? this.isLoading,
      error: error == null ? this.error : (error.isEmpty ? null : error),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RsvpState &&
            runtimeType == other.runtimeType &&
            status == other.status &&
            listEquals(guests, other.guests) &&
            isWindowOpen == other.isWindowOpen &&
            isLoading == other.isLoading &&
            error == other.error;
  }

  @override
  int get hashCode => Object.hash(status, Object.hashAll(guests), isWindowOpen, isLoading, error);
}

