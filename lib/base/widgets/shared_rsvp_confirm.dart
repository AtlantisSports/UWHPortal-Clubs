/// Shared RSVP confirmation dialog and decision model
library;

import 'package:flutter/material.dart';
import '../../core/models/practice.dart';
import '../../core/models/guest.dart';
import '../../core/providers/participation_provider.dart';
import 'phone_aware_modal_utils.dart';

class RSVPDecision {
  // Applies when target == ParticipationStatus.maybe
  final bool makeConditional;
  final int? threshold;
  final bool syncClubMembersOnMaybe; // keep + sync (default true)
  final bool syncVisitorsOnMaybe; // keep + sync (default true)
  final bool syncDependentsOnMaybe; // keep + sync (default true)

  // Applies when target == ParticipationStatus.no
  final bool setClubMembersToNo; // default true
  final bool setVisitorsToNo; // default true
  final bool setDependentsToNo; // default true

  const RSVPDecision({
    this.makeConditional = false,
    this.threshold,
    this.syncClubMembersOnMaybe = true,
    this.syncVisitorsOnMaybe = true,
    this.syncDependentsOnMaybe = true,
    this.setClubMembersToNo = true,
    this.setVisitorsToNo = true,
    this.setDependentsToNo = true,
  });

  RSVPDecision copyWith({
    bool? makeConditional,
    int? threshold,
    bool? syncClubMembersOnMaybe,
    bool? syncVisitorsOnMaybe,
    bool? syncDependentsOnMaybe,
    bool? setClubMembersToNo,
    bool? setVisitorsToNo,
    bool? setDependentsToNo,
  }) {
    return RSVPDecision(
      makeConditional: makeConditional ?? this.makeConditional,
      threshold: threshold ?? this.threshold,
      syncClubMembersOnMaybe: syncClubMembersOnMaybe ?? this.syncClubMembersOnMaybe,
      syncVisitorsOnMaybe: syncVisitorsOnMaybe ?? this.syncVisitorsOnMaybe,
      syncDependentsOnMaybe: syncDependentsOnMaybe ?? this.syncDependentsOnMaybe,
      setClubMembersToNo: setClubMembersToNo ?? this.setClubMembersToNo,
      setVisitorsToNo: setVisitorsToNo ?? this.setVisitorsToNo,
      setDependentsToNo: setDependentsToNo ?? this.setDependentsToNo,
    );
  }
}

Future<RSVPDecision?> showSharedRSVPConfirmationDialog({
  required BuildContext context,
  required ParticipationProvider provider,
  required String practiceId,
  required ParticipationStatus target,
  bool initialMakeConditional = false,
  int? initialThreshold,
  bool? overrideHasClubMembers,
  bool? overrideHasVisitors,
  bool? overrideHasDependents,
  bool? overrideHasNewPlayers,
}) async {
  final guests = provider.getPracticeGuests(practiceId).guests;
  final hasClubMembers = overrideHasClubMembers ?? guests.any((g) => g.type == GuestType.clubMember);
  final hasVisitors = overrideHasVisitors ?? guests.any((g) => g.type == GuestType.visitor);
  final hasDependents = overrideHasDependents ?? guests.any((g) => g.type == GuestType.dependent);
  final hasNewPlayers = overrideHasNewPlayers ?? guests.any((g) => g.type == GuestType.newPlayer);

  final bool currentIsMaybe = provider.getParticipationStatus(practiceId) == ParticipationStatus.maybe;

  bool makeConditional = target == ParticipationStatus.maybe ? initialMakeConditional : false;
  int? threshold = target == ParticipationStatus.maybe ? initialThreshold : null;

  // Maybe defaults: sync = true
  int clubMemberMaybeChoice = 0; // 0 sync, 1 remove
  int visitorMaybeChoice = 0; // 0 sync, 1 remove
  int dependentMaybeChoice = 0; // 0 sync, 1 remove

  // No defaults: set to No = default
  int clubMemberNoChoice = 0; // 0 set to No, 1 detach keep-as-is
  int visitorNoChoice = 0; // 0 set to No, 1 detach keep-as-is
  int dependentNoChoice = 0; // 0 set to No, 1 detach keep-as-is

  return PhoneAwareModalUtils.showPhoneAwareDialogSlideUpFromBottom<RSVPDecision?>(
    context: context,
    child: StatefulBuilder(
      builder: (context, setModalState) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (() {
                  final current = provider.getParticipationStatus(practiceId);
                  if (current == ParticipationStatus.yes && target == ParticipationStatus.maybe) return 'Confirm your change from YES to MAYBE';
                  if (current == ParticipationStatus.yes && target == ParticipationStatus.no) return 'Confirm your change from YES to NO';
                  if (current == ParticipationStatus.maybe && target == ParticipationStatus.no) return 'Confirm your change from MAYBE to NO';
                  return 'Confirm your change';
                })(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              if (target == ParticipationStatus.maybe) ...[
                // Conditional Maybe section
                Row(
                  children: [
                    Checkbox(
                      value: makeConditional,
                      onChanged: (v) => setModalState(() {
                        makeConditional = v ?? false;
                        if (makeConditional && threshold == null) {
                          threshold = provider.getLastUsedOrMinThreshold(const [6, 8, 10, 12]);
                        }
                      }),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const Text('Conditional Maybe'),
                    const SizedBox(width: 6),
                    Tooltip(
                      triggerMode: TooltipTriggerMode.tap,
                      showDuration: Duration(seconds: 3),
                      message: 'Selecting this gives you the option to set a minimum attendance threshold before you will commit to attend',
                      child: const Icon(Icons.help_outline, size: 16, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
                if (makeConditional) ...[
                  const SizedBox(height: 6),
                  const Text(
                    'I will commit so long as at least this many (including myself) will attend',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [6, 8, 10, 12].map((t) {
                      final selected = threshold == t;
                      return ChoiceChip(
                        label: Text('$t+'),
                        selected: selected,
                        onSelected: (_) => setModalState(() => threshold = t),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Guests sections for Maybe
                if (hasNewPlayers) ...[
                  const Text('New Player guests', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('Your New Player guest(s) will have their RSVP changed to MAYBE also', style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 12),
                ],
                if (hasClubMembers) ...[
                  const Text('How about your Club Member guests?', style: TextStyle(fontWeight: FontWeight.w600)),
                  RadioGroup<int>(
                    groupValue: clubMemberMaybeChoice,
                    onChanged: (v) => setModalState(() => clubMemberMaybeChoice = v ?? 0),
                    child: Column(
                      children: const [
                        RadioListTile<int>(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: 0,
                          title: Text('Keep them as my guest and synced to my RSVP'),
                          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                        ),
                        RadioListTile<int>(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: 1,
                          title: Text('They are still confirmed, detach from my guest list'),
                          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (hasVisitors) ...[
                  const Text('How about your Visitor guests?', style: TextStyle(fontWeight: FontWeight.w600)),
                  RadioGroup<int>(
                    groupValue: visitorMaybeChoice,
                    onChanged: (v) => setModalState(() => visitorMaybeChoice = v ?? 0),
                    child: Column(
                      children: const [
                        RadioListTile<int>(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: 0,
                          title: Text('Keep them as my guest and synced to my RSVP'),
                          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                        ),
                        RadioListTile<int>(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: 1,
                          title: Text('They are still confirmed, detach from my guest list'),
                          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (hasDependents) ...[
                  const Text('How about your Dependent guests?', style: TextStyle(fontWeight: FontWeight.w600)),
                  RadioGroup<int>(
                    groupValue: dependentMaybeChoice,
                    onChanged: (v) => setModalState(() => dependentMaybeChoice = v ?? 0),
                    child: Column(
                      children: const [
                        RadioListTile<int>(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: 0,
                          title: Text('Keep them as my guest and synced to my RSVP'),
                          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                        ),
                        RadioListTile<int>(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: 1,
                          title: Text('They are still confirmed, detach from my guest list'),
                          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ] else ...[
                // NO target
                if (hasNewPlayers) ...[
                  const Text('New Player guests', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('Your New Player guest(s) will have their RSVP changed to NO also', style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 12),
                ],
                if (hasClubMembers) ...[
                  const Text('How about your Club Member guests?', style: TextStyle(fontWeight: FontWeight.w600)),
                  RadioGroup<int>(
                    groupValue: clubMemberNoChoice,
                    onChanged: (v) => setModalState(() => clubMemberNoChoice = v ?? 0),
                    child: Column(
                      children: [
                        RadioListTile<int>(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: 0,
                          title: Text('Also set their RSVP to NO'),
                          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                        ),
                        RadioListTile<int>(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: 1,
                          title: Text(currentIsMaybe ? 'They still might go, detach from my guest list' : 'They are still confirmed, detach from my guest list'),
                          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (hasVisitors) ...[
                  const Text('How about your Visitor guests?', style: TextStyle(fontWeight: FontWeight.w600)),
                  RadioGroup<int>(
                    groupValue: visitorNoChoice,
                    onChanged: (v) => setModalState(() => visitorNoChoice = v ?? 0),
                    child: Column(
                      children: [
                        RadioListTile<int>(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: 0,
                          title: Text('Also set their RSVP to NO'),
                          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                        ),
                        RadioListTile<int>(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: 1,
                          title: Text(currentIsMaybe ? 'They still might go, detach from my guest list' : 'They are still confirmed, detach from my guest list'),
                          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (hasDependents) ...[
                  const Text('How about your Dependent guests?', style: TextStyle(fontWeight: FontWeight.w600)),
                  RadioGroup<int>(
                    groupValue: dependentNoChoice,
                    onChanged: (v) => setModalState(() => dependentNoChoice = v ?? 0),
                    child: Column(
                      children: [
                        RadioListTile<int>(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: 0,
                          title: Text('Also set their RSVP to NO'),
                          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                        ),
                        RadioListTile<int>(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: 1,
                          title: Text(currentIsMaybe ? 'They still might go, detach from my guest list' : 'They are still confirmed, detach from my guest list'),
                          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],

              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final decision = RSVPDecision(
                          makeConditional: makeConditional,
                          threshold: makeConditional ? threshold : null,
                          syncClubMembersOnMaybe: clubMemberMaybeChoice == 0,
                          syncVisitorsOnMaybe: visitorMaybeChoice == 0,
                          syncDependentsOnMaybe: dependentMaybeChoice == 0,
                          setClubMembersToNo: clubMemberNoChoice == 0,
                          setVisitorsToNo: visitorNoChoice == 0,
                          setDependentsToNo: dependentNoChoice == 0,
                        );
                        Navigator.of(context).pop(decision);
                      },
                      child: const Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}

