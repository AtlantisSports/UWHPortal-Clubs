import 'package:flutter_test/flutter_test.dart';
import 'package:clubs_mockup/core/models/club.dart';
import 'package:clubs_mockup/core/models/practice.dart';
import 'package:clubs_mockup/core/models/guest.dart';
import 'package:clubs_mockup/core/providers/participation_provider.dart';
import 'package:clubs_mockup/core/services/user_service.dart';
import 'package:clubs_mockup/features/clubs/clubs_repository.dart';

// Minimal fakes for isolation
class _FakeClubsRepository implements ClubsRepository {
  final Club club;
  ParticipationStatus? lastStatus;
  _FakeClubsRepository(this.club);

  @override
  Future<Club> getClub(String clubId) async => club;

  @override
  Future<List<Club>> getClubs({int page = 1, int limit = 20, String? search, String? location, List<String>? tags}) async => [club];

  @override
  Future<void> refreshClubs() async {}

  @override
  Future<void> updateParticipationStatus(String clubId, String practiceId, ParticipationStatus status) async {
    lastStatus = status; // record call; local provider state is asserted via getParticipationStatus
  }
}

class _FakeUserService implements UserService {
  @override
  final String currentUserId;
  final Map<String, PracticeGuestList> _guests;
  _FakeUserService(this.currentUserId, [Map<String, PracticeGuestList>? seed]) : _guests = seed ?? {};

  @override
  Future<PracticeGuestList> getPracticeGuests(String practiceId, DateTime practiceDate) async {
    return _guests[practiceId] ?? const PracticeGuestList();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ParticipationProvider.isCurrentUserConditionalSatisfied', () {
    late String me;
    late Practice practice;
    late Club club;
    late _FakeClubsRepository repo;
    late ParticipationProvider provider;

    setUp(() {
      me = 'me';
      practice = Practice(
        id: 'p1',
        clubId: 'c1',
        title: 'Practice',
        description: 'desc',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        location: 'loc',
        address: 'addr',
        participationResponses: {
          // 5 hard yes from others
          'u1': ParticipationStatus.yes,
          'u2': ParticipationStatus.yes,
          'u3': ParticipationStatus.yes,
          'u4': ParticipationStatus.yes,
          'u5': ParticipationStatus.yes,
          // current user default blank (not present)
        },
        conditionalYesThresholds: const {},
      );
      club = Club(
        id: 'c1',
        name: 'Club',
        shortName: 'Club',
        longName: 'Club',
        description: 'desc',
        location: 'loc',
        contactEmail: 'c@e.com',
        upcomingPractices: [practice],
      );
      repo = _FakeClubsRepository(club);
      provider = ParticipationProvider(clubsRepository: repo, userService: _FakeUserService(me));
      // Ensure our internal state for current practice is blank initially
      expect(provider.getParticipationStatus(practice.id), ParticipationStatus.blank);
      // Enable conditional maybe for current user with default threshold set later per test
      provider.setConditionalMaybe(practice.id, true, threshold: 6);
    });

    test('satisfied when base hard-yes + self contribution meets threshold (6 with 5 others)', () {
      // 5 others + me(1) => 6
      final ok = provider.isCurrentUserConditionalSatisfied(practice);
      expect(ok, isTrue);
    });

    test('not satisfied when threshold is too high (8 with 5 others, 0 guests)', () {
      provider.setConditionalMaybe(practice.id, true, threshold: 8);
      final ok = provider.isCurrentUserConditionalSatisfied(practice);
      expect(ok, isFalse);
    });

    test('satisfied when guests increase contribution (threshold 8 with 2 guests)', () {
      provider.setConditionalMaybe(practice.id, true, threshold: 8);
      provider.updatePracticeGuests(practice.id, const [DependentGuest(id: 'g1', name: 'Kid1'), DependentGuest(id: 'g2', name: 'Kid2')]);
      final ok = provider.isCurrentUserConditionalSatisfied(practice);
      expect(ok, isTrue); // 5 others + me(1) + 2 guests = 8
    });

    test('pending target blocks satisfaction until commit (regardless of target)', () {
      // Pending target Yes => blocked
      provider.startPendingChange(club.id, practice.id, ParticipationStatus.yes, duration: const Duration(seconds: 10));
      expect(provider.isPendingChange(practice.id), isTrue);
      expect(provider.isCurrentUserConditionalSatisfied(practice), isFalse);

      // Cancel and start pending Maybe => still blocked until commit
      provider.cancelPendingChange(practice.id);
      provider.startPendingChange(club.id, practice.id, ParticipationStatus.maybe, duration: const Duration(seconds: 10));
      expect(provider.isPendingChange(practice.id), isTrue);
      expect(provider.isCurrentUserConditionalSatisfied(practice), isFalse);

      // Cleanup
      provider.cancelPendingChange(practice.id);
    });
  });

  group('ParticipationProvider pending transitions', () {
    late String me;
    late Practice practice;
    late Club club;
    late _FakeClubsRepository repo;
    late ParticipationProvider provider;

    setUp(() {
      me = 'me';
      practice = Practice(
        id: 'p2',
        clubId: 'c1',
        title: 'Practice',
        description: 'desc',
        dateTime: DateTime.now().add(const Duration(days: 2)),
        location: 'loc',
        address: 'addr',
      );
      club = Club(
        id: 'c1',
        name: 'Club',
        shortName: 'Club',
        longName: 'Club',
        description: 'desc',
        location: 'loc',
        contactEmail: 'c@e.com',
        upcomingPractices: [practice],
      );
      repo = _FakeClubsRepository(club);
      provider = ParticipationProvider(clubsRepository: repo, userService: _FakeUserService(me));
    });

    test('start/cancel pending change updates flags and clears state', () async {
      provider.startPendingChange(club.id, practice.id, ParticipationStatus.maybe, duration: const Duration(seconds: 10));
      expect(provider.isPendingChange(practice.id), isTrue);
      expect(provider.getPendingTarget(practice.id), ParticipationStatus.maybe);

      provider.cancelPendingChange(practice.id);
      expect(provider.isPendingChange(practice.id), isFalse);
    });

    test('commit pending change applies status via repository and local state', () async {
      provider.startPendingChange(club.id, practice.id, ParticipationStatus.no, duration: const Duration(seconds: 10));
      expect(provider.isPendingChange(practice.id), isTrue);

      await provider.commitPendingChange(club.id, practice.id);

      expect(provider.isPendingChange(practice.id), isFalse);
      expect(provider.getParticipationStatus(practice.id), ParticipationStatus.no);
      expect(repo.lastStatus, ParticipationStatus.no);
    });
  });
}

