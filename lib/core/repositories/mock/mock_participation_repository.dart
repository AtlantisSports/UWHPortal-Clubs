/// Mock implementation of participation repository
/// Provides realistic mock data for participation operations without Service Locator
library;

import 'dart:math';
import '../interfaces/participation_repository.dart';
import '../../models/practice.dart';
import '../../models/guest.dart';
import '../../services/user_service.dart';
import '../../../features/clubs/clubs_repository.dart';

/// Mock implementation of ParticipationRepository for development and testing
///
/// This implementation provides realistic mock data and behavior while maintaining
/// the same interface as the future production implementation.
class MockParticipationRepository implements ParticipationRepository {
  final UserService _userService;
  final ClubsRepository _clubsRepository;
  final Random _random = Random();

  // In-memory storage for mock data
  final Map<String, ParticipationStatus> _participationStatusMap = {};
  final Map<String, PracticeGuestList> _practiceGuestsMap = {};
  final Map<String, bool> _bringGuestMap = {};

  MockParticipationRepository({
    required UserService userService,
    required ClubsRepository clubsRepository,
  }) : _userService = userService,
        _clubsRepository = clubsRepository;

  @override
  Future<ParticipationStatus?> getParticipationStatus({
    required String userId,
    required String practiceId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final key = '${practiceId}_$userId';
    return _participationStatusMap[key];
  }

  @override
  Future<bool> updateParticipationStatus({
    required String userId,
    required String practiceId,
    required ParticipationStatus status,
  }) async {
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(200)));
    try {
      final key = '${practiceId}_$userId';
      _participationStatusMap[key] = status;

      // Clear guests if status is No
      if (status == ParticipationStatus.no) {
        _practiceGuestsMap[practiceId] = const PracticeGuestList();
        _bringGuestMap[practiceId] = false;
      }

      return true;
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
    final currentUserKey = '${practiceId}_${_userService.currentUserId}';
    return {
      'user1': ParticipationStatus.yes,
      'user2': ParticipationStatus.maybe,
      'user3': ParticipationStatus.no,
      _userService.currentUserId: _participationStatusMap[currentUserKey] ?? ParticipationStatus.blank,
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
        
        final key = '${practice.id}_$userId';
        history[practice.id] = _participationStatusMap[key] ?? ParticipationStatus.blank;
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
    final guestList = _practiceGuestsMap[practiceId] ?? const PracticeGuestList();
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
      _practiceGuestsMap[practiceId] = PracticeGuestList(guests: guests);
      _bringGuestMap[practiceId] = guests.isNotEmpty;
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
    return _bringGuestMap[practiceId] ?? false;
  }

  @override
  Future<bool> updateBringGuestState({
    required String userId,
    required String practiceId,
    required bool bringGuest,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      _bringGuestMap[practiceId] = bringGuest;

      // Clear guests if bring guest is turned off
      if (!bringGuest) {
        _practiceGuestsMap[practiceId] = const PracticeGuestList();
      }

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
