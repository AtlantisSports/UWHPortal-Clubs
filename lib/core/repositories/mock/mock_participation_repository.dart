/// Mock implementation of participation repository
/// Integrates with existing ParticipationProvider and mock data
library;

import '../interfaces/participation_repository.dart';
import '../../models/practice.dart';
import '../../models/guest.dart';
import '../../providers/participation_provider.dart';
import '../../services/user_service.dart';
import '../../di/service_locator.dart';
import '../../../features/clubs/clubs_repository.dart';

/// Mock implementation of IParticipationRepository using existing providers
class MockParticipationRepository implements IParticipationRepository {
  final ParticipationProvider _participationProvider;
  final UserService _userService;
  final ClubsRepository _clubsRepository;

  MockParticipationRepository({
    ParticipationProvider? participationProvider,
    UserService? userService,
    ClubsRepository? clubsRepository,
  }) : _participationProvider = participationProvider ?? ServiceLocator.participationProvider,
        _userService = userService ?? ServiceLocator.userService,
        _clubsRepository = clubsRepository ?? ServiceLocator.clubsRepository;

  @override
  Future<ParticipationStatus?> getParticipationStatus({
    required String userId,
    required String practiceId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    // Use the existing provider
    return _participationProvider.getParticipationStatus(practiceId);
  }

  @override
  Future<bool> updateParticipationStatus({
    required String userId,
    required String practiceId,
    required ParticipationStatus status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      // Find the club that contains this practice
      final clubs = await _clubsRepository.getClubs();
      for (final club in clubs) {
        final practice = club.upcomingPractices.where((p) => p.id == practiceId).firstOrNull;
        if (practice != null) {
          await _participationProvider.updateParticipationStatus(club.id, practiceId, status);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> bulkUpdateParticipationStatus({
    required String userId,
    required List<String> practiceIds,
    required ParticipationStatus status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      // Update each practice individually using existing provider
      for (final practiceId in practiceIds) {
        await updateParticipationStatus(
          userId: userId,
          practiceId: practiceId,
          status: status,
        );
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> clearParticipationStatus({
    required String userId,
    required String practiceId,
  }) async {
    return updateParticipationStatus(
      userId: userId,
      practiceId: practiceId,
      status: ParticipationStatus.blank,
    );
  }

  @override
  Future<bool> clearAllFutureRSVPs({
    required String userId,
    required String clubId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final club = await _clubsRepository.getClub(clubId);
      final now = DateTime.now();
      final futurePractices = club.upcomingPractices.where((p) => 
        p.dateTime.isAfter(now)
      ).toList();
      
      for (final practice in futurePractices) {
        await updateParticipationStatus(
          userId: userId,
          practiceId: practice.id,
          status: ParticipationStatus.blank,
        );
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, ParticipationStatus>> getPracticeParticipants(String practiceId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Mock implementation - return sample participants
    return {
      'user1': ParticipationStatus.yes,
      'user2': ParticipationStatus.maybe,
      'user3': ParticipationStatus.no,
      _userService.currentUserId: _participationProvider.getParticipationStatus(practiceId),
    };
  }

  @override
  Future<Map<ParticipationStatus, int>> getParticipationSummary(String practiceId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final participants = await getPracticeParticipants(practiceId);
    final summary = <ParticipationStatus, int>{};
    
    for (final status in ParticipationStatus.values) {
      summary[status] = participants.values.where((s) => s == status).length;
    }
    
    return summary;
  }

  @override
  Future<Map<String, ParticipationStatus>> getUserParticipationHistory({
    required String userId,
    required String clubId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    try {
      final club = await _clubsRepository.getClub(clubId);
      final history = <String, ParticipationStatus>{};
      
      for (final practice in club.upcomingPractices) {
        if (startDate != null && practice.dateTime.isBefore(startDate)) continue;
        if (endDate != null && practice.dateTime.isAfter(endDate)) continue;
        
        history[practice.id] = _participationProvider.getParticipationStatus(practice.id);
      }
      
      return history;
    } catch (e) {
      return {};
    }
  }

  @override
  Future<List<Guest>> getPracticeGuests({
    required String userId,
    required String practiceId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final guestList = _participationProvider.getPracticeGuests(practiceId);
    return guestList.guests;
  }

  @override
  Future<bool> updatePracticeGuests({
    required String userId,
    required String practiceId,
    required List<Guest> guests,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      _participationProvider.updatePracticeGuests(practiceId, guests);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> getBringGuestState({
    required String userId,
    required String practiceId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _participationProvider.getBringGuestState(practiceId);
  }

  @override
  Future<bool> updateBringGuestState({
    required String userId,
    required String practiceId,
    required bool bringGuest,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      _participationProvider.updateBringGuestState(practiceId, bringGuest);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<String>> getUserDependents(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Mock implementation - return sample dependents
    return ['Alex (Child)', 'Sam (Spouse)', 'Jordan (Sibling)'];
  }

  @override
  Future<bool> updateUserDependents({
    required String userId,
    required List<String> dependents,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    // Mock implementation always succeeds
    return true;
  }

  @override
  Future<Map<String, dynamic>> getUserParticipationStats({
    required String userId,
    required String clubId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Mock implementation returns sample stats
    return {
      'totalPractices': 45,
      'attended': 38,
      'missed': 7,
      'attendanceRate': 0.84,
      'currentStreak': 5,
      'longestStreak': 12,
    };
  }

  @override
  Future<Map<String, dynamic>> getClubParticipationStats(String clubId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Mock implementation returns sample club stats
    return {
      'totalMembers': 45,
      'averageAttendance': 0.72,
      'mostActiveMembers': ['user1', 'user2', 'user3'],
      'practicesThisMonth': 12,
      'totalPracticesThisYear': 156,
    };
  }
}
