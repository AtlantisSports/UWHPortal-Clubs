/// Guest models for practice attendance
library;

enum GuestType {
  newPlayer,
  visitor,
  clubMember,
}

extension GuestTypeExtension on GuestType {
  String get displayName {
    switch (this) {
      case GuestType.newPlayer:
        return 'New Player';
      case GuestType.visitor:
        return 'Visitor';
      case GuestType.clubMember:
        return 'Club Member';
    }
  }
  
  String get description {
    switch (this) {
      case GuestType.newPlayer:
        return 'Someone new to underwater hockey';
      case GuestType.visitor:
        return 'Guest visiting from another club/location';
      case GuestType.clubMember:
        return 'Current member of this club';
    }
  }
}

/// Base guest class
abstract class Guest {
  final String id;
  final String name;
  final GuestType type;
  final bool waiverSigned;
  
  const Guest({
    required this.id,
    required this.name,
    required this.type,
    this.waiverSigned = false,
  });
}

/// New player guest
class NewPlayerGuest extends Guest {
  const NewPlayerGuest({
    required super.id,
    required super.name,
    super.waiverSigned = false,
  }) : super(type: GuestType.newPlayer);
}

/// Visitor guest  
class VisitorGuest extends Guest {
  final String? homeClub;
  
  const VisitorGuest({
    required super.id,
    required super.name,
    this.homeClub,
    super.waiverSigned = false,
  }) : super(type: GuestType.visitor);
}

/// Club member guest
class ClubMemberGuest extends Guest {
  final String memberId;
  final bool hasPermission;
  
  const ClubMemberGuest({
    required super.id,
    required super.name,
    required this.memberId,
    this.hasPermission = true,
  }) : super(type: GuestType.clubMember, waiverSigned: true);
}

/// Guest management state for a practice
class PracticeGuestList {
  final List<Guest> guests;
  
  const PracticeGuestList({
    this.guests = const [],
  });
  
  PracticeGuestList copyWith({
    List<Guest>? guests,
  }) {
    return PracticeGuestList(
      guests: guests ?? this.guests,
    );
  }
  
  PracticeGuestList addGuest(Guest guest) {
    return copyWith(guests: [...guests, guest]);
  }
  
  PracticeGuestList removeGuest(String guestId) {
    return copyWith(
      guests: guests.where((g) => g.id != guestId).toList(),
    );
  }
  
  int get totalGuests => guests.length;
  
  List<Guest> getGuestsByType(GuestType type) {
    return guests.where((g) => g.type == type).toList();
  }
}