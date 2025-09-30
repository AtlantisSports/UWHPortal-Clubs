/// Core participation status provider - focused on RSVP/attendance only
/// Handles participation status and guest management for practices
library;

import 'dart:async';
import 'package:flutter/widgets.dart';
import '../models/practice.dart';
import '../models/guest.dart';
import '../utils/error_handler.dart';
import '../services/user_service.dart';
import '../../features/clubs/clubs_repository.dart';
import '../di/service_locator.dart';

class ParticipationProvider with ChangeNotifier, WidgetsBindingObserver {
  final ClubsRepository _clubsRepository;
  final UserService _userService;

  ParticipationProvider({
    ClubsRepository? clubsRepository,
    UserService? userService,
  }) : _clubsRepository = clubsRepository ?? ServiceLocator.clubsRepository,
        _userService = userService ?? ServiceLocator.userService {
    // Observe app lifecycle to commit pending YES on background/close
    WidgetsBinding.instance.addObserver(this);
  }

  // Map to track participation status for each practice
  // Key: practiceId, Value: ParticipationStatus
  final Map<String, ParticipationStatus> _participationStatusMap = {};

  // Conditional Maybe: per-practice toggle and threshold (provider memory; can be hydrated from Practice when present)
  final Map<String, bool> _conditionalMaybeMap = {}; // practiceId -> checked
  final Map<String, int> _conditionalMaybeThresholdMap = {}; // practiceId -> threshold

  // Remember last-used Conditional Maybe threshold across practices
  int? _lastUsedConditionalThreshold;


  // Map to track guest lists for each practice
  // Key: practiceId, Value: PracticeGuestList
  final Map<String, PracticeGuestList> _practiceGuestsMap = {};

  // Consolidated pending-change state per practice (Phase 2)

  // Consolidated pending-change state per practice (Phase 2)
  final Map<String, PendingChange> _pending = {}; // practiceId -> PendingChange


  // Optional mock overrides for Effective Yes computation (used by Practice Details debug UI)
  final Map<String, int> _mockBaseYesOverrides = {}; // practiceId -> baseYes
  final Map<String, Map<int, int>> _mockOtherConditionalCountsOverrides = {}; // practiceId -> {threshold -> count}

  void setMockEffectiveYesOverrides(String practiceId, {required int baseYes, required Map<int, int> otherConditionalCounts}) {
    final prevBase = _mockBaseYesOverrides[practiceId];
    final prevMap = _mockOtherConditionalCountsOverrides[practiceId];
    final sameBase = prevBase == baseYes;
    final sameMap = prevMap != null && _mapsEqual(prevMap, otherConditionalCounts);
    _mockBaseYesOverrides[practiceId] = baseYes;
    _mockOtherConditionalCountsOverrides[practiceId] = Map<int, int>.from(otherConditionalCounts);
    if (!(sameBase && sameMap)) {
      notifyListeners();
    }
  }

  void clearMockEffectiveYesOverrides(String practiceId) {
    final removedBase = _mockBaseYesOverrides.remove(practiceId);
    final removedMap = _mockOtherConditionalCountsOverrides.remove(practiceId);
    if (removedBase != null || removedMap != null) {
      notifyListeners();
    }
  }

  bool _mapsEqual(Map<int, int> a, Map<int, int> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (final e in a.entries) {
      if (b[e.key] != e.value) return false;
    }
    return true;
  }

  // Last-committed target status per practice (used for accurate commit toasts)
  final Map<String, ParticipationStatus> _lastCommittedTarget = {};
  ParticipationStatus? getLastCommittedTarget(String practiceId) => _lastCommittedTarget[practiceId];

  bool isPendingChange(String practiceId) => _pending.containsKey(practiceId);

  /// Returns progress [0..1] of the pending countdown for a practice.
  double pendingChangeProgress(String practiceId) {
    final pc = _pending[practiceId];
    if (pc == null) return 0.0;
    if (pc.paused) return pc.progressCache ?? 0.0;
    final start = pc.start;
    final end = pc.deadline;
    final totalMs = end.difference(start).inMilliseconds;
    if (totalMs <= 0) return 1.0;
    final elapsedMs = DateTime.now().difference(start).inMilliseconds;
    final v = elapsedMs / totalMs;
    if (v < 0) return 0.0;
    if (v > 1) return 1.0;
    return v;
  }



  /// Universal pending countdown for any target status (Yes/Maybe/No)
  void startPendingChange(String clubId, String practiceId, ParticipationStatus target, {Duration duration = const Duration(seconds: 5)}) {
    final hasPending = _pending.containsKey(practiceId);

    if (hasPending) {
      final pc = _pending[practiceId]!;
      final original = pc.originalStatus;
      if (target == pc.target || target == original) {
        // Tapping the same pending option or the original option cancels the countdown entirely
        cancelPendingChange(practiceId);
        notifyListeners();
        return;
      }
      // Change target and restart timer to a fresh full duration
      pc.target = target;
      pc.clubId = clubId;

      // Cancel existing timers/tickers and any paused state
      pc.commitTimer?.cancel();
      pc.ticker?.cancel();
      pc.paused = false;
      pc.remaining = null;
      pc.progressCache = null;

      final now = DateTime.now();
      pc.start = now;
      pc.deadline = now.add(duration);

      // Commit timer for the new deadline
      pc.commitTimer = Timer(duration, () {
        unawaited(commitPendingChange(pc.clubId, practiceId));
      });

      // Progress ticker (reduced frequency for efficiency)
      pc.ticker = Timer.periodic(const Duration(milliseconds: 150), (_) {
        notifyListeners();
      });

      notifyListeners();
      return;
    }

    // No active pending. Start a new countdown only if changing away from current committed status
    final current = getParticipationStatus(practiceId);
    if (target == current) {
      return; // No-op; no timer needed for selecting the already-committed state
    }

    final now = DateTime.now();
    final pc = PendingChange(
      start: now,
      deadline: now.add(duration),
      clubId: clubId,
      target: target,
      originalStatus: current,
    );
    _pending[practiceId] = pc;

    pc.commitTimer = Timer(duration, () {
      unawaited(commitPendingChange(pc.clubId, practiceId));
    });

    pc.ticker = Timer.periodic(const Duration(milliseconds: 150), (t) {
      if (!_pending.containsKey(practiceId)) {
        t.cancel();
        return;
      }
      if (pc.paused) return;
      notifyListeners();
    });

    notifyListeners();
  }

  ParticipationStatus? getPendingTarget(String practiceId) => _pending[practiceId]?.target;

  void pausePendingChange(String practiceId) {
    final pc = _pending[practiceId];
    if (pc == null) return;
    if (pc.paused) return;
    final totalMs = pc.deadline.difference(pc.start).inMilliseconds;
    final elapsedMs = DateTime.now().difference(pc.start).inMilliseconds;
    final remainingMs = (totalMs - elapsedMs).clamp(0, totalMs);
    pc.remaining = Duration(milliseconds: remainingMs);
    pc.progressCache = pendingChangeProgress(practiceId);
    pc.pausedAt = DateTime.now();
    pc.paused = true;
    pc.commitTimer?.cancel();
    pc.ticker?.cancel();
    notifyListeners();
  }

  void resumePendingChange(String practiceId) {
    final pc = _pending[practiceId];
    if (pc == null) return;
    if (!pc.paused) return;

    final now = DateTime.now();
    final pausedAt = pc.pausedAt ?? now;
    final pausedDuration = now.difference(pausedAt);

    // Shift both start and deadline forward by the paused duration to keep
    // progress continuous and maintain the same remaining time without a visual reset.
    pc.start = pc.start.add(pausedDuration);
    pc.deadline = pc.deadline.add(pausedDuration);

    // Compute remaining time to schedule commit
    final rem = pc.deadline.difference(now);
    if (rem <= Duration.zero) {
      unawaited(commitPendingChange(pc.clubId, practiceId));
      return;
    }

    pc.commitTimer = Timer(rem, () {
      unawaited(commitPendingChange(pc.clubId, practiceId));
    });

    pc.ticker = Timer.periodic(const Duration(milliseconds: 150), (_) {
      if (pc.paused) return;
      notifyListeners();
    });

    pc.paused = false;
    pc.remaining = null; // legacy
    pc.progressCache = null; // allow ring to continue from current progress
    pc.pausedAt = null;
    notifyListeners();
  }

  void cancelPendingChange(String practiceId) {
    final pc = _pending.remove(practiceId);
    pc?.commitTimer?.cancel();
    pc?.ticker?.cancel();
    notifyListeners();
  }

  Future<void> commitPendingChange(String clubId, String practiceId) async {
    final pc = _pending.remove(practiceId);
    // Snapshot target before clearing (default to Yes)
    final target = pc?.target ?? ParticipationStatus.yes;

    // Record the target for accurate commit-time toasts
    _lastCommittedTarget[practiceId] = target;

    // Clear pending state first to avoid duplicate commits
    pc?.commitTimer?.cancel();
    pc?.ticker?.cancel();
    notifyListeners();

    try {
      await updateParticipationStatus(clubId, practiceId, target);

      // If this commit came from a countdown (pc != null), enforce full reset rules
      if (pc != null) {
        if (target == ParticipationStatus.yes || target == ParticipationStatus.no) {
          // Clear Conditional Maybe and remove stored threshold
          clearConditionalMaybe(practiceId);
        } else if (target == ParticipationStatus.maybe) {
          // If this is plain Maybe (not conditional), remove any stored threshold
          final isConditionalActive = getConditionalMaybe(practiceId);
          if (!isConditionalActive) {
            clearConditionalMaybe(practiceId);
          }
        }
      }
    } catch (_) {
      // Errors are already handled in updateParticipationStatus
    }
  }

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
  /// Return the last-used Conditional Maybe threshold if available, else the minimum of options
  int getLastUsedOrMinThreshold(List<int> options) {
    if (_lastUsedConditionalThreshold != null) return _lastUsedConditionalThreshold!;
    if (options.isEmpty) return 0;
    int minVal = options.first;
    for (final v in options) {
      if (v < minVal) minVal = v;
    }
    return minVal;
  }


  /// Conditional Maybe state
  bool getConditionalMaybe(String practiceId) => _conditionalMaybeMap[practiceId] ?? false;
  int? getConditionalMaybeThreshold(String practiceId) => _conditionalMaybeThresholdMap[practiceId];

  // Tracks the last number of non-dependent guests removed when enabling Conditional Maybe
  final Map<String, int> _lastRemovedNonDependentGuests = {};
  int consumeRemovedNonDependentGuests(String practiceId) {
    final n = _lastRemovedNonDependentGuests.remove(practiceId) ?? 0;
    return n;
  }

  void setConditionalMaybe(String practiceId, bool checked, {int? threshold}) {
    _conditionalMaybeMap[practiceId] = checked;
    if (checked && threshold != null) {
      _conditionalMaybeThresholdMap[practiceId] = threshold;
      _lastUsedConditionalThreshold = threshold; // remember last used globally
    }
    if (!checked) {
      // When disabling conditional, clear stored threshold for this practice but keep last-used global
      _conditionalMaybeThresholdMap.remove(practiceId);
    }
    // Per new spec: Do not auto-clear any non-dependent guests when enabling Conditional Maybe.
    // We simply toggle the flag and optionally store the threshold.
    notifyListeners();
  }

  /// Clear Conditional Maybe state and its threshold for a practice
  void clearConditionalMaybe(String practiceId) {
    _conditionalMaybeMap[practiceId] = false;
    _conditionalMaybeThresholdMap.remove(practiceId);
    notifyListeners();
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


  /// Badge text helper (for buttons/calendar). Returns "N" or null when no badge.
  String? getConditionalBadgeText(String practiceId) {
    if (!getConditionalMaybe(practiceId)) return null;
    final th = getConditionalMaybeThreshold(practiceId);
    return th?.toString();
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

  /// Total count of practices currently marked as non-conditional Maybe for the user (upcoming set)
  int get totalMaybeCount {
    int count = 0;
    for (final entry in _participationStatusMap.entries) {
      if (entry.value == ParticipationStatus.maybe && !(getConditionalMaybe(entry.key))) {
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

    // Hydrate Conditional Maybe from practice model when present
    final t = practice.conditionalYesThresholds[currentUserId];
    if (t != null) {
      _conditionalMaybeMap[practice.id] = true;
      _conditionalMaybeThresholdMap[practice.id] = t;
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

      // Hydrate Conditional Maybe
      final t = practice.conditionalYesThresholds[currentUserId];
      if (t != null) {
        _conditionalMaybeMap[practice.id] = true;
        _conditionalMaybeThresholdMap[practice.id] = t;
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
  Future<void> updateMemberParticipationStatus(String clubId, String practiceId, String memberId, ParticipationStatus status, {int? conditionalThreshold}) async {
    await _clubsRepository.updateMemberParticipationStatus(clubId, practiceId, memberId, status);
    if (status == ParticipationStatus.maybe) {
      await _clubsRepository.setMemberConditionalMaybeThreshold(clubId, practiceId, memberId, conditionalThreshold);
    } else {
      await _clubsRepository.setMemberConditionalMaybeThreshold(clubId, practiceId, memberId, null);
    }
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
    _conditionalMaybeMap.clear();
    _conditionalMaybeThresholdMap.clear();
    _loadingStates.clear();
    _error = null;
    notifyListeners();
  }

  /// Compute Effective Yes count using fixed-point satisfaction of Conditional Maybe groups.
  ///
  /// Rules:
  /// - Start with hard Yes from other users (excludes current user if they have Conditional Maybe enabled).
  /// - Each Conditional Maybe group contributes their own attendance if satisfied.
  /// - A group is satisfied if its threshold <= (current effective + that group's contribution)
  ///   which allows self-satisfying groups.
  /// - Other users are assumed to contribute 1 (we do not know their guest counts here).
  /// - Current user contributes 1 + their guest count if they have Conditional Maybe enabled.
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

    // Build pending conditional groups (others from practice model or override; current user from provider state)
    final pending = <_CondGroup>[];

    final overrideOthers = _mockOtherConditionalCountsOverrides[practice.id];
    if (overrideOthers != null) {
      // Treat each threshold's whole group as a single contribution, matching debug logic
      overrideOthers.forEach((threshold, count) {
        if (count > 0) {
          pending.add(_CondGroup(threshold: threshold, contribution: count, isCurrentUser: false));
        }
      });
    } else {
      // Others (assume contribution of 1 each)
      practice.conditionalYesThresholds.forEach((userId, threshold) {
        if (userId != uid) {
          pending.add(_CondGroup(threshold: threshold, contribution: 1, isCurrentUser: false));
        }
      });
    }

    // Current user group (if enabled and not pending YES)
    final bool myChecked = getConditionalMaybe(practice.id);
    final int? myThreshold = getConditionalMaybeThreshold(practice.id);
    final bool myPending = isPendingChange(practice.id);
    if (!myPending && myChecked && myThreshold != null) {
      final int myGuests = getPracticeGuests(practice.id).totalGuests;
      pending.add(_CondGroup(threshold: myThreshold, contribution: 1 + myGuests, isCurrentUser: true));
    } else {
      // If not using Conditional Maybe (or currently pending), and current user is a hard Yes in the model,
      // count them (and their guests) only when not pending.
      final myStatus = practice.getParticipationStatus(uid);
      if (!myPending && myStatus == ParticipationStatus.yes) {
        final int myGuests = getPracticeGuests(practice.id).totalGuests;
        effective += 1 + myGuests;
      }
    }

    // Solve using shared fixed-point solver
    final res = _solveFixedPoint(baseEffective: effective, groups: pending);
    return res.effective;
  }

  /// Determine whether the current user's Conditional Maybe (if enabled) is satisfied
  /// under the same fixed-point rules used by computeEffectiveYesCount.
  bool isCurrentUserConditionalSatisfied(Practice practice) {
    final String uid = currentUserId;

    // If there is any pending change, do not consider Conditional Maybe satisfied yet.
    // We only compute satisfaction after the countdown commits.
    if (isPendingChange(practice.id)) {
      return false;
    }

    final bool myChecked = getConditionalMaybe(practice.id);
    final int? myThreshold = getConditionalMaybeThreshold(practice.id);
    if (!myChecked || myThreshold == null) return false;

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

    // Build pending conditional groups including current user, with optional override for others
    final pending = <_CondGroup>[];

    final overrideOthers = _mockOtherConditionalCountsOverrides[practice.id];
    if (overrideOthers != null) {
      overrideOthers.forEach((threshold, count) {
        if (count > 0) pending.add(_CondGroup(threshold: threshold, contribution: count, isCurrentUser: false));
      });
    } else {
      practice.conditionalYesThresholds.forEach((userId, threshold) {
        if (userId != uid) {
          pending.add(_CondGroup(threshold: threshold, contribution: 1, isCurrentUser: false));
        }
      });
    }

    // Current user group with their guests
    final int myGuests = getPracticeGuests(practice.id).totalGuests;
    pending.add(_CondGroup(threshold: myThreshold, contribution: 1 + myGuests, isCurrentUser: true));

    // Solve using shared fixed-point solver, tracking current user
    final res = _solveFixedPoint(baseEffective: effective, groups: pending, trackCurrentUser: true);
    return res.mySatisfied;
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
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      // Commit all pending changes immediately when app is backgrounded/closing
      final pending = Map<String, PendingChange>.from(_pending);
      for (final entry in pending.entries) {
        unawaited(commitPendingChange(entry.value.clubId, entry.key));
      }
    }
  }

  @override
  void dispose() {
    // Cancel timers and remove observer
    for (final pc in _pending.values) {
      pc.commitTimer?.cancel();
      pc.ticker?.cancel();
    }
    _pending.clear();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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
        if (getConditionalMaybe(practice.id)) {
          final th = getConditionalMaybeThreshold(practice.id) ?? getLastUsedOrMinThreshold(const [6, 8, 10, 12]);
          final satisfied = isCurrentUserConditionalSatisfied(practice);
          return PracticeStatusViewState(
            label: satisfied ? '$th+ you are going!' : 'Going if $th+',
            useSuccessColorForMaybe: satisfied,
          );
        }
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


class PendingChange {
  DateTime start;
  DateTime deadline;
  Timer? commitTimer;
  Timer? ticker;
  String clubId;
  ParticipationStatus target;
  ParticipationStatus originalStatus;

  // Pause/resume support
  bool paused;
  Duration? remaining; // legacy: kept for compatibility
  double? progressCache; // used to freeze ring while paused
  DateTime? pausedAt; // when pause started

  PendingChange({
    required this.start,
    required this.deadline,
    required this.clubId,
    required this.target,
    required this.originalStatus,
    this.commitTimer,
    this.ticker,
    this.paused = false,
    this.remaining,
    this.progressCache,
    this.pausedAt,
  });
}


class _SolveResult {
  final int effective;
  final bool mySatisfied;
  const _SolveResult(this.effective, this.mySatisfied);
}

_SolveResult _solveFixedPoint({
  required int baseEffective,
  required List<_CondGroup> groups,
  bool trackCurrentUser = false,
}) {
  int effective = baseEffective;
  bool mySatisfied = false;
  bool changed = true;
  while (changed) {
    changed = false;
    final remaining = <_CondGroup>[];
    for (final g in groups) {
      if (g.threshold <= (effective + g.contribution)) {
        effective += g.contribution;
        if (trackCurrentUser && g.isCurrentUser) mySatisfied = true;
        changed = true;
      } else {
        remaining.add(g);
      }
    }
    // If nothing changed, loop will exit; no need for length guard
    groups
      ..clear()
      ..addAll(remaining);
  }
  return _SolveResult(effective, mySatisfied);
}

/// Minimal view-model for PracticeStatus card header
@immutable
class PracticeStatusViewState {
  final String label;
  final bool useSuccessColorForMaybe; // when true, UI should show success green for Maybe
  const PracticeStatusViewState({required this.label, this.useSuccessColorForMaybe = false});
}

class _CondGroup {
  final int threshold;
  final int contribution;
  final bool isCurrentUser;
  const _CondGroup({required this.threshold, required this.contribution, required this.isCurrentUser});
}
