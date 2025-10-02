// Guest models for practice attendance
import 'package:freezed_annotation/freezed_annotation.dart';

part 'guest.freezed.dart';

enum GuestType {
  newPlayer,
  visitor,
  clubMember,
  dependent,
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
      case GuestType.dependent:
        return 'Dependents';
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
      case GuestType.dependent:
        return 'Family members or dependents';
    }
  }
}

@freezed
sealed class Guest with _$Guest {
  const factory Guest.newPlayer({
    required String id,
    required String name,
    @Default(false) bool waiverSigned,
  }) = NewPlayerGuest;

  const factory Guest.visitor({
    required String id,
    required String name,
    String? homeClub,
    @Default(false) bool waiverSigned,
  }) = VisitorGuest;

  const factory Guest.clubMember({
    required String id,
    required String name,
    required String memberId,
    @Default(true) bool hasPermission,
    @Default(true) bool waiverSigned,
  }) = ClubMemberGuest;

  const factory Guest.dependent({
    required String id,
    required String name,
    @Default(false) bool waiverSigned,
  }) = DependentGuest;
}

extension GuestX on Guest {
  GuestType get type => map(
        newPlayer: (_) => GuestType.newPlayer,
        visitor: (_) => GuestType.visitor,
        clubMember: (_) => GuestType.clubMember,
        dependent: (_) => GuestType.dependent,
      );
}

/// Guest management state for a practice
@freezed
abstract class PracticeGuestList with _$PracticeGuestList {
  const factory PracticeGuestList({
    @Default(<Guest>[]) List<Guest> guests,
  }) = _PracticeGuestList;
  const PracticeGuestList._();

  int get totalGuests => guests.length;

  List<Guest> getGuestsByType(GuestType type) =>
      guests.where((g) => g.type == type).toList();

  PracticeGuestList addGuest(Guest guest) =>
      copyWith(guests: [...guests, guest]);

  PracticeGuestList removeGuest(String guestId) => copyWith(
        guests: guests.where((g) => g.id != guestId).toList(),
      );
}