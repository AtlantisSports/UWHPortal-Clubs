/// Helper to apply RSVP changes and guest updates based on shared decision
library;

import 'package:flutter/material.dart';
import '../../core/models/guest.dart';
import '../../core/models/practice.dart';
import '../../core/providers/participation_provider.dart';
import '../../base/widgets/shared_rsvp_confirm.dart';

Future<void> applyRSVPChange({
  required BuildContext context,
  required ParticipationProvider provider,
  required String clubId,
  required List<String> practiceIds,
  required ParticipationStatus target,
  required RSVPDecision decision,
}) async {
  for (final practiceId in practiceIds) {
    // 1) Update current user status
    await provider.updateParticipationStatus(clubId, practiceId, target);

    // 2) Conditional Maybe for current user
    if (target == ParticipationStatus.maybe) {
      if (decision.makeConditional && decision.threshold != null) {
        provider.setConditionalMaybe(practiceId, true, threshold: decision.threshold);
      } else {
        provider.clearConditionalMaybe(practiceId);
      }
    } else {
      provider.clearConditionalMaybe(practiceId);
    }

    // 3) Guest updates
    final guests = provider.getPracticeGuests(practiceId).guests;
    final List<Guest> newGuests = [];

    if (target == ParticipationStatus.maybe) {
      for (final g in guests) {
        switch (g.type) {
          case GuestType.newPlayer:
            // Keep New Players on guest list; they have no profile to update
            newGuests.add(g);
            // No notification for new players per spec
            break;
          case GuestType.clubMember:
            final keepAndSync = decision.syncClubMembersOnMaybe;
            if (keepAndSync) {
              newGuests.add(g);
              final cm = g as ClubMemberGuest;
              await provider.updateMemberParticipationStatus(clubId, practiceId, cm.memberId, ParticipationStatus.maybe, conditionalThreshold: decision.makeConditional ? decision.threshold : null);
              await provider.sendGuestRSVPNotification(
                practiceId: practiceId,
                guestDisplayName: cm.name,
                guestType: GuestType.clubMember,
                newStatus: ParticipationStatus.maybe,
                isClubMember: true,
                memberId: cm.memberId,
              );
            } else {
              // Detach; notify they remain at previous status (message content is placeholder)
              final cm = g as ClubMemberGuest;
              await provider.sendGuestRSVPNotification(
                practiceId: practiceId,
                guestDisplayName: cm.name,
                guestType: GuestType.clubMember,
                newStatus: ParticipationStatus.maybe,
                isClubMember: true,
                memberId: cm.memberId,
              );
            }
            break;
          case GuestType.visitor:
            if (decision.syncVisitorsOnMaybe) {
              newGuests.add(g);
              // We don't have a visitor memberId/profile to update in mock; send notification only
              await provider.sendGuestRSVPNotification(
                practiceId: practiceId,
                guestDisplayName: g.name,
                guestType: GuestType.visitor,
                newStatus: ParticipationStatus.maybe,
                isClubMember: false,
              );
            } else {
              await provider.sendGuestRSVPNotification(
                practiceId: practiceId,
                guestDisplayName: g.name,
                guestType: GuestType.visitor,
                newStatus: ParticipationStatus.maybe,
                isClubMember: false,
              );
            }
            break;
          case GuestType.dependent:
            if (decision.syncDependentsOnMaybe) {
              newGuests.add(g);
              // No memberId in mock dependent; notify only
              await provider.sendGuestRSVPNotification(
                practiceId: practiceId,
                guestDisplayName: g.name,
                guestType: GuestType.dependent,
                newStatus: ParticipationStatus.maybe,
                isClubMember: false,
              );
            } else {
              await provider.sendGuestRSVPNotification(
                practiceId: practiceId,
                guestDisplayName: g.name,
                guestType: GuestType.dependent,
                newStatus: ParticipationStatus.maybe,
                isClubMember: false,
              );
            }
            break;
        }
      }
    } else if (target == ParticipationStatus.no) {
      // Clear all guests from my list
      // Apply No-change rules per guest type
      for (final g in guests) {
        switch (g.type) {
          case GuestType.newPlayer:
            // Set to No conceptually; in mock just no notification
            break;
          case GuestType.clubMember:
            final cm = g as ClubMemberGuest;
            if (decision.setClubMembersToNo) {
              await provider.updateMemberParticipationStatus(clubId, practiceId, cm.memberId, ParticipationStatus.no);
              await provider.sendGuestRSVPNotification(
                practiceId: practiceId,
                guestDisplayName: cm.name,
                guestType: GuestType.clubMember,
                newStatus: ParticipationStatus.no,
                isClubMember: true,
                memberId: cm.memberId,
              );
            } else {
              await provider.sendGuestRSVPNotification(
                practiceId: practiceId,
                guestDisplayName: cm.name,
                guestType: GuestType.clubMember,
                newStatus: ParticipationStatus.no,
                isClubMember: true,
                memberId: cm.memberId,
              );
            }
            break;
          case GuestType.visitor:
            if (decision.setVisitorsToNo) {
              await provider.sendGuestRSVPNotification(
                practiceId: practiceId,
                guestDisplayName: g.name,
                guestType: GuestType.visitor,
                newStatus: ParticipationStatus.no,
                isClubMember: false,
              );
            } else {
              await provider.sendGuestRSVPNotification(
                practiceId: practiceId,
                guestDisplayName: g.name,
                guestType: GuestType.visitor,
                newStatus: ParticipationStatus.no,
                isClubMember: false,
              );
            }
            break;
          case GuestType.dependent:
            if (decision.setDependentsToNo) {
              await provider.sendGuestRSVPNotification(
                practiceId: practiceId,
                guestDisplayName: g.name,
                guestType: GuestType.dependent,
                newStatus: ParticipationStatus.no,
                isClubMember: false,
              );
            } else {
              await provider.sendGuestRSVPNotification(
                practiceId: practiceId,
                guestDisplayName: g.name,
                guestType: GuestType.dependent,
                newStatus: ParticipationStatus.no,
                isClubMember: false,
              );
            }
            break;
        }
      }
    }

    // Write guest list (empty on No)
    provider.updatePracticeGuests(practiceId, target == ParticipationStatus.no ? <Guest>[] : newGuests);
    provider.updateBringGuestState(practiceId, target != ParticipationStatus.no && newGuests.isNotEmpty);
  }
}

