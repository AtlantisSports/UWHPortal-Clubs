/// Core participation status provider - focused on RSVP/attendance only
/// Handles participation status and guest management for practices
library;


import 'package:flutter/widgets.dart';
import '../models/practice.dart';
import '../models/guest.dart';
import '../utils/error_handler.dart';
import '../services/user_service.dart';
import '../../features/clubs/clubs_repository.dart';
import '../di/service_locator.dart';

class ParticipationProvider with ChangeNotifier {
  final ClubsRepository _clubsRepository;
  final UserService _userService;

  ParticipationProvider({
    ClubsRepository? clubsRepository,
    UserService? userService,
  }) : _clubsRepository = clubsRepository ?? ServiceLocator.clubsRepository,
        _userService = userService ?? ServiceLocator.userService;

  // Map to track participation status for each practice
  // Key: practiceId, Value: ParticipationStatus
  final Map<String, ParticipationStatus> _participationStatusMap = {};




  // Map to track guest lists for each practice
  // Key: practiceId, Value: PracticeGuestList
  final Map<String, PracticeGuestList> _practiceGuestsMap = {};


  // Optional mock overrides for Effective Yes computation (used by Practice Details debug UI)
  final Map<String, int> _mockBaseYesOverrides = {}; // practiceId -> baseYes


  void setMockEffectiveYesOverrides(String practiceId, {required int baseYes}) {
    final prevBase = _mockBaseYesOverrides[practiceId];
    _mockBaseYesOverrides[practiceId] = baseYes;
    if (prevBase != baseYes) {
      notifyListeners();
    }
  }

  void clearMockEffectiveYesOverrides(String practiceId) {
    final removedBase = _mockBaseYesOverrides.remove(practiceId);
    if (removedBase != null) {
      notifyListeners();
    }
  }



  // Last-committed target status per practice (used for accurate commit toasts)
  final Map<String, ParticipationStatus> _lastCommittedTarget = {};
  ParticipationStatus? getLastCommittedTarget(String practiceId) => _lastCommittedTarget[practiceId];



  final Map<String, bool> _bringGuestMap = {};


  // Map to track loading states for each practice
  final Map<String, bool> _loadingStates = {};

  // Error tracking
  String? _error;

  // Getters
  String? get error => _error;
  String get currentUserId => _userService.currentUserId;

  /// Get participation status for a specific practice
  ParticipationStatus getParticipationStatus(String practiceId) {
    return _participationStatusMap[practiceId] ?? ParticipationStatus.blank;
  }





  /// Determine if a confirmation modal is needed for a transition based on guest composition
  bool needsGuestConfirmation(String practiceId, ParticipationStatus newTarget) {
    final current = getParticipationStatus(practiceId);
    // Only consider transitions to Maybe/No
    if (newTarget != ParticipationStatus.maybe && newTarget != ParticipationStatus.no) return false;

    // Require any guests present
    final guests = getPracticeGuests(practiceId).guests;
    if (guests.isEmpty) return false;

    // Show confirmation for:
    // - Yes -> Maybe/No
    // - Maybe -> No
    if ((current == ParticipationStatus.yes && (newTarget == ParticipationStatus.maybe || newTarget == ParticipationStatus.no)) ||
        (current == ParticipationStatus.maybe && newTarget == ParticipationStatus.no)) {
      return true;
    }

    return false;
  }




  /// Get guest list for a specific practice
  PracticeGuestList getPracticeGuests(String practiceId) {
    return _practiceGuestsMap[practiceId] ?? const PracticeGuestList();
  }

  /// Get "bring guest" checkbox state for a specific practice
  bool getBringGuestState(String practiceId) {
    return _bringGuestMap[practiceId] ?? false;
  }

  /// Check if a specific practice is loading
  bool isLoading(String practiceId) {
    return _loadingStates[practiceId] ?? false;
  }

  /// Total count of practices currently marked as Maybe for the user (upcoming set)
  int get totalMaybeCount {
    int count = 0;
    for (final entry in _participationStatusMap.entries) {
      if (entry.value == ParticipationStatus.maybe) {
        count++;
      }
    }
    return count;
  }

  /// Initialize participation status from a practice object
  Future<void> initializePracticeParticipation(Practice practice) async {
    final status = practice.getParticipationStatus(currentUserId);
    if (_participationStatusMap[practice.id] != status) {
      _participationStatusMap[practice.id] = status;
      // Don't notify listeners here as this is initialization
    }



    // Initialize mock guest data for past practices
    await _initializeMockGuestData(practice);
  }

  /// Initialize participation statuses from a list of practices
  Future<void> initializePracticesParticipation(List<Practice> practices) async {
    bool hasChanges = false;

    for (final practice in practices) {
      final status = practice.getParticipationStatus(currentUserId);
      if (_participationStatusMap[practice.id] != status) {
        _participationStatusMap[practice.id] = status;
        hasChanges = true;
      }



      // Initialize mock guest data for past practices
      await _initializeMockGuestData(practice);
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  /// Initialize mock guest data for a practice (past practices only)
  Future<void> _initializeMockGuestData(Practice practice) async {
    // Only initialize if we don't already have guest data for this practice
    if (_practiceGuestsMap.containsKey(practice.id)) {
      return;
    }

    // Only initialize guest data for recent past practices (within last 30 days)
    // to avoid performance issues with processing years of data
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    if (practice.dateTime.isBefore(thirtyDaysAgo)) {
      return; // Skip old practices
    }

    try {
      // Get guest data through UserService instead of direct MockDataService access
      final guestData = await _userService.getPracticeGuests(practice.id, practice.dateTime);

      // Only set if there are guests to avoid unnecessary empty entries
      if (guestData.totalGuests > 0) {
        _practiceGuestsMap[practice.id] = guestData;
        _bringGuestMap[practice.id] = true; // Set bring guest flag if guests exist
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error initializing guest data for practice ${practice.id}: $e');
    }
  }

  /// Update participation status for a practice with time-based validation
  Future<void> updateParticipationStatus(
    String clubId,
    String practiceId,
    ParticipationStatus newStatus, {
    bool isAdmin = false,
  }) async {
    _setLoading(practiceId, true);
    _setError(null);

    try {
      // Get the practice to check time-based rules
      final club = await _clubsRepository.getClub(clubId);
      final practice = club.upcomingPractices.firstWhere(
        (p) => p.id == practiceId,
        orElse: () => throw Exception('Practice not found'),
      );

      // Check if the status change is allowed
      final availableStatuses = practice.getAvailableStatuses(isAdmin: isAdmin);
      if (!availableStatuses.contains(newStatus)) {
        throw Exception('Status change not allowed at this time');
      }

      // Update the repository
      await _clubsRepository.updateParticipationStatus(clubId, practiceId, newStatus);

      // Update local state
      _participationStatusMap[practiceId] = newStatus;
      // Record last committed target for UI selection stability across all change paths
      _lastCommittedTarget[practiceId] = newStatus;

      // Notify all listeners that this practice participation has changed
      notifyListeners();


    } catch (error) {
      final errorMessage = AppErrorHandler.getErrorMessage(error);
      _setError(errorMessage);
      AppErrorHandler.handleError(error);
    } finally {
      _setLoading(practiceId, false);
    }
  }

  /// Update guest list for a practice
  void updatePracticeGuests(String practiceId, List<Guest> guests) {
    _practiceGuestsMap[practiceId] = PracticeGuestList(guests: guests);
    notifyListeners();
  }

  /// Update "bring guest" checkbox state for a practice
  void updateBringGuestState(String practiceId, bool bringGuest) {
    _bringGuestMap[practiceId] = bringGuest;

    // Clear guest list if not bringing guests
    if (!bringGuest) {
      _practiceGuestsMap[practiceId] = const PracticeGuestList();
    }

    notifyListeners();
  }

  /// Bulk update participation status for multiple practices
  /// Note: Consider moving to separate BulkOperationsProvider for better separation
  Future<BulkParticipationResult> bulkUpdateParticipation(BulkParticipationRequest request) async {
    final successfulIds = <String>[];
    final failedIds = <String>[];
    final errors = <String, String>{};

    try {
      for (final practiceId in request.practiceIds) {
        try {
          await updateParticipationStatus(
            request.clubId,
            practiceId,
            request.newStatus,
            isAdmin: false, // Bulk operations are typically user-initiated
          );
          successfulIds.add(practiceId);
        } catch (error) {
          failedIds.add(practiceId);
          errors[practiceId] = error.toString();
        }
      }
    } catch (e) {
      // Handle any unexpected errors
      debugPrint('Bulk operation error: $e');
    }

    return BulkParticipationResult(
      successfulIds: successfulIds,
      failedIds: failedIds,
      errors: errors,
      appliedStatus: request.newStatus,
    );
  }

  /// Update RSVP for a club member (guest) directly
  Future<void> updateMemberParticipationStatus(String clubId, String practiceId, String memberId, ParticipationStatus status) async {
    await _clubsRepository.updateMemberParticipationStatus(clubId, practiceId, memberId, status);
    notifyListeners();
  }

  /// Send notification to a guest about their RSVP change (placeholder impl)
  Future<void> sendGuestRSVPNotification({
    required String practiceId,
    required String guestDisplayName,
    required GuestType guestType,
    required ParticipationStatus newStatus,
    required bool isClubMember,
    String? memberId,
  }) async {
    debugPrint('[Notify] Guest "$guestDisplayName" (${guestType.name}) changed to ${newStatus.name} for practice $practiceId. memberId=$memberId');
  }

  /// Get participation statuses for multiple practices
  Map<String, ParticipationStatus> getBulkParticipationStatuses(List<String> practiceIds) {
    final result = <String, ParticipationStatus>{};
    for (final id in practiceIds) {
      result[id] = getParticipationStatus(id);
    }
    return result;
  }

  /// Refresh participation status for a specific practice
  Future<void> refreshPracticeParticipation(String clubId, String practiceId) async {
    try {
      final club = await _clubsRepository.getClub(clubId);
      final practice = club.upcomingPractices.firstWhere(
        (p) => p.id == practiceId,
        orElse: () => throw Exception('Practice not found'),
      );

      final status = practice.getParticipationStatus(currentUserId);
      if (_participationStatusMap[practiceId] != status) {
        _participationStatusMap[practiceId] = status;
        notifyListeners();
      }
    } catch (error) {
      AppErrorHandler.handleError(error);
    }
  }

  /// Clear all participation data (useful for user logout, etc.)
  void clearAll() {
    _participationStatusMap.clear();
    _loadingStates.clear();
    _error = null;
    notifyListeners();
  }

  /// Compute the effective Yes headcount for a practice.
  ///
  /// Rules:
  /// - Start with other users marked Yes (1 each).
  /// - If current user is Yes, add 1 + their guest count.
  ///
  /// Note: Conditional groups are no longer considered.
  int computeEffectiveYesCount(Practice practice) {
    final String uid = currentUserId;

    // Base hard-yes from others only (override when provided by mock UI)
    int effective;
    final int? overrideBase = _mockBaseYesOverrides[practice.id];
    if (overrideBase != null) {
      effective = overrideBase;
    } else {
      effective = 0;
      practice.participationResponses.forEach((userId, status) {
        if (userId != uid && status == ParticipationStatus.yes) {
          effective++;
        }
      });
    }

    // Count current user and their guests if hard YES
    if (practice.getParticipationStatus(uid) == ParticipationStatus.yes) {
      final int myGuests = getPracticeGuests(practice.id).totalGuests;
      effective += 1 + myGuests;
    }

    return effective;
  }



  /// Private helper methods
  void _setLoading(String practiceId, bool loading) {
    _loadingStates[practiceId] = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    if (error != null) {
      notifyListeners();
    }
  }

  /// Debug method to see all tracked participation statuses
  void debugPrintParticipation() {
    debugPrint('=== Participation Provider Debug ===');
    for (final entry in _participationStatusMap.entries) {
      debugPrint('Practice ${entry.key}: ${entry.value.name}');
    }
    debugPrint('====================================');
  }

  /// Note: Filter management has been moved to PracticeFilterProvider
  /// This keeps ParticipationProvider focused on participation status only


  /// Returns label and a color hint for the PracticeStatus card header.
  /// Color hint is only relevant for Maybe (success green when conditional is satisfied).
  PracticeStatusViewState getPracticeStatusViewState(Practice practice) {
    final status = getParticipationStatus(practice.id);
    switch (status) {
      case ParticipationStatus.yes:
        return const PracticeStatusViewState(label: 'Going');
      case ParticipationStatus.no:
        return const PracticeStatusViewState(label: 'Not going');
      case ParticipationStatus.maybe:
        return const PracticeStatusViewState(label: 'Maybe');
      case ParticipationStatus.attended:
        return const PracticeStatusViewState(label: 'Attended');
      case ParticipationStatus.missed:
        return const PracticeStatusViewState(label: 'Missed');
      case ParticipationStatus.blank:
        return const PracticeStatusViewState(label: 'Maybe');
    }
  }

}





/// Minimal view-model for PracticeStatus card header
@immutable
class PracticeStatusViewState {
  final String label;
  final bool useSuccessColorForMaybe; // when true, UI should show success green for Maybe
  const PracticeStatusViewState({required this.label, this.useSuccessColorForMaybe = false});
}

