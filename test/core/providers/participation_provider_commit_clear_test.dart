import 'package:flutter_test/flutter_test.dart';
import 'package:clubs_mockup/core/models/club.dart';
import 'package:clubs_mockup/core/models/practice.dart';
import 'package:clubs_mockup/core/models/guest.dart';
import 'package:clubs_mockup/core/providers/participation_provider.dart';
import 'package:clubs_mockup/features/clubs/clubs_repository.dart';
import 'package:clubs_mockup/core/services/user_service.dart';

class _FakeClubsRepository implements ClubsRepository {
  final Club club;
  _FakeClubsRepository(this.club);

  @override
  Future<Club> getClub(String clubId) async => club;

  @override
  Future<List<Club>> getClubs({int page = 1, int limit = 20, String? search, String? location, List<String>? tags}) async => [club];

  @override
  Future<void> refreshClubs() async {}

  @override
  Future<void> updateParticipationStatus(String clubId, String practiceId, ParticipationStatus status) async {}
}

class _FakeUserService implements UserService {
  @override
  final String currentUserId;
  _FakeUserService(this.currentUserId);

  @override
  Future<PracticeGuestList> getPracticeGuests(String practiceId, DateTime practiceDate) async => const PracticeGuestList();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('commit from pending to YES clears Conditional Maybe flag and removes threshold', () async {
    final me = 'me';
    final practice = Practice(
      id: 'p1',
      clubId: 'c1',
      title: 'Practice',
      description: 'desc',
      dateTime: DateTime.now().add(const Duration(days: 1)),
      location: 'loc',
      address: 'addr',
      participationResponses: const {},
      conditionalYesThresholds: const {},
    );
    final club = Club(
      id: 'c1',
      name: 'Club',
      shortName: 'Club',
      longName: 'Club',
      description: 'desc',
      location: 'loc',
      contactEmail: 'c@e.com',
      upcomingPractices: [practice],
    );
    final provider = ParticipationProvider(clubsRepository: _FakeClubsRepository(club), userService: _FakeUserService(me));

    // Set Conditional Maybe active with a threshold
    provider.setConditionalMaybe(practice.id, true, threshold: 8);
    expect(provider.getConditionalMaybe(practice.id), isTrue);
    expect(provider.getConditionalMaybeThreshold(practice.id), 8);

    // Start a pending change to YES and commit immediately
    provider.startPendingChange(club.id, practice.id, ParticipationStatus.yes, duration: const Duration(milliseconds: 1));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    // After commit: flag cleared and threshold removed
    expect(provider.getConditionalMaybe(practice.id), isFalse);
    expect(provider.getConditionalMaybeThreshold(practice.id), isNull);
  });

  test('commit to plain Maybe removes any stored threshold (keeps plain Maybe yellow)', () async {
    final me = 'me';
    final practice = Practice(
      id: 'p2',
      clubId: 'c1',
      title: 'Practice 2',
      description: 'desc',
      dateTime: DateTime.now().add(const Duration(days: 2)),
      location: 'loc',
      address: 'addr',
      participationResponses: const {},
      conditionalYesThresholds: const {},
    );
    final club = Club(
      id: 'c1',
      name: 'Club',
      shortName: 'Club',
      longName: 'Club',
      description: 'desc',
      location: 'loc',
      contactEmail: 'c@e.com',
      upcomingPractices: [practice],
    );
    final provider = ParticipationProvider(clubsRepository: _FakeClubsRepository(club), userService: _FakeUserService(me));

    // Previously conditional was set and threshold stored
    provider.setConditionalMaybe(practice.id, true, threshold: 10);
    expect(provider.getConditionalMaybeThreshold(practice.id), 10);

    // Turn off Conditional Maybe before starting countdown
    provider.setConditionalMaybe(practice.id, false);

    // Start a pending change to Maybe and let it commit
    provider.startPendingChange(club.id, practice.id, ParticipationStatus.maybe, duration: const Duration(milliseconds: 1));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    // After commit to plain Maybe: threshold removed
    expect(provider.getConditionalMaybe(practice.id), isFalse);
    expect(provider.getConditionalMaybeThreshold(practice.id), isNull);
  });
}

