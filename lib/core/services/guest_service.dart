/// Guest management business logic service
/// Handles all guest validation rules and operations
library;

import '../models/guest.dart';

/// Service for handling guest management business logic
class GuestService {
  /// Validate if all guests have required waivers
  bool allGuestsHaveWaivers(List<Guest> guests) {
    if (guests.isEmpty) return true;

    for (final guest in guests) {
      // Require waivers only for Visitors and New Players; Dependents and Club Members are exempt
      if ((guest.type == GuestType.visitor || guest.type == GuestType.newPlayer) && !guest.waiverSigned) {
        return false;
      }
    }
    return true;
  }

  /// Validate if a guest can be added
  bool canAddGuest({
    required String? name,
    required bool waiverSigned,
  }) {
    return name != null && 
           name.trim().isNotEmpty && 
           waiverSigned;
  }

  /// Get validation error for guest addition
  String? getGuestValidationError({
    required String? name,
    required bool waiverSigned,
  }) {
    if (name == null || name.trim().isEmpty) {
      return 'Guest name is required';
    }
    
    if (!waiverSigned) {
      return 'Guest must sign waiver before being added';
    }
    
    return null;
  }

  /// Check if guest list is valid for RSVP completion
  bool isGuestListValidForRSVP(List<Guest> guests) {
    return allGuestsHaveWaivers(guests);
  }

  /// Get guest list validation error message
  String? getGuestListValidationError(List<Guest> guests) {
    if (!allGuestsHaveWaivers(guests)) {
      return 'All guests must have signed waivers before completing RSVP';
    }
    return null;
  }

  /// Calculate guest statistics
  Map<String, int> calculateGuestStats(List<Guest> guests) {
    return {
      'totalGuests': guests.length,
      'guestsWithWaivers': guests.where((g) => g.waiverSigned).length,
      'guestsWithoutWaivers': guests.where((g) => !g.waiverSigned).length,
    };
  }

  /// Validate guest name format
  bool isValidGuestName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return false;
    }
    
    // Basic name validation - at least 2 characters, no special characters
    final trimmedName = name.trim();
    return trimmedName.length >= 2 && 
           RegExp(r'^[a-zA-Z\s\-\.]+$').hasMatch(trimmedName);
  }

  /// Get formatted guest name
  String formatGuestName(String name) {
    return name.trim().split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Check if maximum guest limit is reached
  bool isMaxGuestLimitReached(List<Guest> guests, {int maxGuests = 10}) {
    return guests.length >= maxGuests;
  }

  /// Get guest limit warning message
  String? getGuestLimitWarning(List<Guest> guests, {int maxGuests = 10}) {
    if (guests.length >= maxGuests) {
      return 'Maximum guest limit of $maxGuests reached';
    }
    
    if (guests.length >= maxGuests - 2) {
      final remaining = maxGuests - guests.length;
      return 'Only $remaining guest${remaining == 1 ? '' : 's'} can be added';
    }
    
    return null;
  }
}

/// Static instance for easy access throughout the app
final guestService = GuestService();
