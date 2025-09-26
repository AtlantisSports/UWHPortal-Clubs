/// Core participation status provider - focused on RSVP/attendance only
/// Handles participation status and guest management for practices
library;

import 'package:flutter/foundation.dart';
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

  // Conditional Yes: per-practice toggle and threshold (provider memory; can be hydrated from Practice when present)
  final Map<String, bool> _conditionalYesMap = {}; // practiceId -> checked
  final Map<String, int> _conditionalThresholdMap = {}; // practiceId -> threshold

  // Map to track guest lists for each practice
  // Key: practiceId, Value: PracticeGuestList
  final Map<String, PracticeGuestList> _practiceGuestsMap = {};

  // Map to track "bring guest" checkbox state for each practice
  // Key: practiceId, Value: bool
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

  /// Conditional Yes state
  bool getConditionalYes(String practiceId) => _conditionalYesMap[practiceId] ?? false;
  int? getConditionalThreshold(String practiceId) => _conditionalThresholdMap[practiceId];
  void setConditionalYes(String practiceId, bool checked, {int? threshold}) {
    _conditionalYesMap[practiceId] = checked;
    if (checked && threshold != null) {
      _conditionalThresholdMap[practiceId] = threshold;
    }
    if (!checked) {
      // Keep last threshold in memory for convenience, but could be cleared if desired
    }
    notifyListeners();
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
    for (final status in _participationStatusMap.values) {
      if (status == ParticipationStatus.maybe) count++;
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

    // Hydrate Conditional Yes from practice model when present
    final t = practice.conditionalYesThresholds[currentUserId];
    if (t != null) {
      _conditionalYesMap[practice.id] = true;
      _conditionalThresholdMap[practice.id] = t;
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

      // Hydrate Conditional Yes
      final t = practice.conditionalYesThresholds[currentUserId];
      if (t != null) {
        _conditionalYesMap[practice.id] = true;
        _conditionalThresholdMap[practice.id] = t;
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
    _conditionalYesMap.clear();
    _conditionalThresholdMap.clear();
    _loadingStates.clear();
    _error = null;
    notifyListeners();
  }

  /// Compute Effective Yes count using fixed-point satisfaction of Conditional Yes groups.
  ///
  /// Rules:
  /// - Start with hard Yes from other users (excludes current user if they have Conditional Yes enabled).
  /// - Each Conditional Yes group contributes their own attendance if satisfied.
  /// - A group is satisfied if its threshold <= (current effective + that group's contribution)
  ///   which allows self-satisfying groups.
  /// - Other users are assumed to contribute 1 (we do not know their guest counts here).
  /// - Current user contributes 1 + their guest count if they have Conditional Yes enabled.
  int computeEffectiveYesCount(Practice practice) {
    final String uid = currentUserId;

    // Base hard-yes from others only
    int effective = 0;
    practice.participationResponses.forEach((userId, status) {
      if (userId != uid && status == ParticipationStatus.yes) {
        effective++;
      }
    });

    // Build pending conditional groups (others from practice model; current user from provider state)
    final pending = <_CondGroup>[];

    // Others (assume contribution of 1 each)
    practice.conditionalYesThresholds.forEach((userId, threshold) {
      if (userId != uid) {
        pending.add(_CondGroup(threshold: threshold, contribution: 1, isCurrentUser: false));
      }
    });

    // Current user group (if enabled)
    final bool myChecked = getConditionalYes(practice.id);
    final int? myThreshold = getConditionalThreshold(practice.id);
    if (myChecked && myThreshold != null) {
      final int myGuests = getPracticeGuests(practice.id).totalGuests;
      pending.add(_CondGroup(threshold: myThreshold, contribution: 1 + myGuests, isCurrentUser: true));
    } else {
      // If not using Conditional Yes, and current user is a hard Yes in the model, count them.
      final myStatus = practice.getParticipationStatus(uid);
      if (myStatus == ParticipationStatus.yes) effective++;
    }

    // Fixed-point satisfaction loop
    bool changed = true;
    while (changed) {
      changed = false;
      final remaining = <_CondGroup>[];
      for (final g in pending) {
        if (g.threshold <= (effective + g.contribution)) {
          effective += g.contribution;
          changed = true;
        } else {
          remaining.add(g);
        }
      }
      if (remaining.length == pending.length) {
        // No progress; break to avoid infinite loop
        break;
      }
      pending
        ..clear()
        ..addAll(remaining);
    }

    return effective;
  }

  /// Determine whether the current user's Conditional Yes (if enabled) is satisfied
  /// under the same fixed-point rules used by computeEffectiveYesCount.
  bool isCurrentUserConditionalSatisfied(Practice practice) {
    final String uid = currentUserId;

    final bool myChecked = getConditionalYes(practice.id);
    final int? myThreshold = getConditionalThreshold(practice.id);
    if (!myChecked || myThreshold == null) return false;

    // Base hard-yes from others only
    int effective = 0;
    practice.participationResponses.forEach((userId, status) {
      if (userId != uid && status == ParticipationStatus.yes) {
        effective++;
      }
    });

    // Build pending conditional groups including current user
    final pending = <_CondGroup>[];

    // Others (assume contribution of 1 each)
    practice.conditionalYesThresholds.forEach((userId, threshold) {
      if (userId != uid) {
        pending.add(_CondGroup(threshold: threshold, contribution: 1, isCurrentUser: false));
      }
    });

    // Current user group with their guests
    final int myGuests = getPracticeGuests(practice.id).totalGuests;
    pending.add(_CondGroup(threshold: myThreshold, contribution: 1 + myGuests, isCurrentUser: true));

    // Fixed-point loop, tracking when current user's group satisfies
    bool mySatisfied = false;
    bool changed = true;
    while (changed) {
      changed = false;
      final remaining = <_CondGroup>[];
      for (final g in pending) {
        if (g.threshold <= (effective + g.contribution)) {
          effective += g.contribution;
          if (g.isCurrentUser) mySatisfied = true;
          changed = true;
        } else {
          remaining.add(g);
        }
      }
      if (remaining.length == pending.length) {
        break;
      }
      pending
        ..clear()
        ..addAll(remaining);
    }

    return mySatisfied;
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
}

class _CondGroup {
  final int threshold;
  final int contribution;
  final bool isCurrentUser;
  const _CondGroup({required this.threshold, required this.contribution, required this.isCurrentUser});
}
