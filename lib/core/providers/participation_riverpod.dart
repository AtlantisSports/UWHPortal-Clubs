/// Riverpod version of Participation provider (non-invasive, not wired to UI yet)
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/practice.dart';
import '../models/guest.dart';
import '../utils/error_handler.dart';
import '../di/riverpod_providers.dart';

part 'participation_riverpod.freezed.dart';
part 'participation_riverpod.g.dart';

@freezed
abstract class ParticipationState with _$ParticipationState {
  const factory ParticipationState({
    @Default({}) Map<String, ParticipationStatus> participationStatusMap,
    @Default({}) Map<String, bool> loadingStates,
    String? error,
    @Default({}) Map<String, ParticipationStatus> lastCommittedTarget,
    @Default({}) Map<String, int> mockBaseYesOverrides,
  }) = _ParticipationState;

}

@riverpod
class ParticipationController extends _$ParticipationController {
  @override
  ParticipationState build() => const ParticipationState();

  // Convenience getters
  String get _currentUserId => ref.read(userServiceProvider).currentUserId;

  ParticipationStatus getParticipationStatus(String practiceId) {
    final cached = state.participationStatusMap[practiceId];
    if (cached != null) return cached;
    _loadParticipationStatusAsync(practiceId);
    return ParticipationStatus.blank;
  }

  Future<void> _loadParticipationStatusAsync(String practiceId) async {
    try {
      final repo = ref.read(participationRepositoryProvider);
      final status = await repo.getParticipationStatus(
        userId: _currentUserId,
        practiceId: practiceId,
      );
      if (status != null && state.participationStatusMap[practiceId] != status) {
        final updated = Map<String, ParticipationStatus>.from(state.participationStatusMap)
          ..[practiceId] = status;
        state = state.copyWith(participationStatusMap: updated);
      }
    } catch (e) {
      // Keep silent, this is background load
    }
  }

  Future<void> initializePracticeParticipation(Practice practice) async {
    try {
      final repo = ref.read(participationRepositoryProvider);
      final status = await repo.getParticipationStatus(
        userId: _currentUserId,
        practiceId: practice.id,
      );
      if (status != null && state.participationStatusMap[practice.id] != status) {
        final updated = Map<String, ParticipationStatus>.from(state.participationStatusMap)
          ..[practice.id] = status;
        state = state.copyWith(participationStatusMap: updated);
      }
    } catch (e) {
      // Fallback: use practice object
      final status = practice.getParticipationStatus(_currentUserId);
      if (state.participationStatusMap[practice.id] != status) {
        final updated = Map<String, ParticipationStatus>.from(state.participationStatusMap)
          ..[practice.id] = status;
        state = state.copyWith(participationStatusMap: updated);
      }
    }
  }

  Future<void> initializePracticesParticipation(List<Practice> practices) async {
    bool hasChanges = false;
    final repo = ref.read(participationRepositoryProvider);

    for (final practice in practices) {
      try {
        final status = await repo.getParticipationStatus(
          userId: _currentUserId,
          practiceId: practice.id,
        );
        if (status != null && state.participationStatusMap[practice.id] != status) {
          final updated = Map<String, ParticipationStatus>.from(state.participationStatusMap)
            ..[practice.id] = status;
          state = state.copyWith(participationStatusMap: updated);
          hasChanges = true;
        }
      } catch (_) {
        final status = practice.getParticipationStatus(_currentUserId);
        if (state.participationStatusMap[practice.id] != status) {
          final updated = Map<String, ParticipationStatus>.from(state.participationStatusMap)
            ..[practice.id] = status;
          state = state.copyWith(participationStatusMap: updated);
          hasChanges = true;
        }
      }
    }

    if (hasChanges) {
      // state already updated per practice
    }
  }

  Future<void> updateParticipationStatus(
    String clubId,
    String practiceId,
    ParticipationStatus newStatus, {
    bool isAdmin = false,
  }) async {
    _setLoading(practiceId, true);
    _setError(null);

    try {
      // Fetch practice for validation
      final clubsRepo = ref.read(clubsRepositoryProvider);
      final club = await clubsRepo.getClub(clubId);
      final practice = club.upcomingPractices.firstWhere(
        (p) => p.id == practiceId,
        orElse: () => throw Exception('Practice not found'),
      );

      final available = practice.getAvailableStatuses(isAdmin: isAdmin);
      if (!available.contains(newStatus)) {
        throw Exception('Status change not allowed at this time');
      }

      // Update repositories
      final repo = ref.read(participationRepositoryProvider);
      await repo.updateParticipationStatus(
        userId: _currentUserId,
        practiceId: practiceId,
        status: newStatus,
      );
      await clubsRepo.updateParticipationStatus(clubId, practiceId, newStatus);

      // Update local state
      final map = Map<String, ParticipationStatus>.from(state.participationStatusMap)
        ..[practiceId] = newStatus;
      final last = Map<String, ParticipationStatus>.from(state.lastCommittedTarget)
        ..[practiceId] = newStatus;
      state = state.copyWith(
        participationStatusMap: map,
        lastCommittedTarget: last,
      );
    } catch (error) {
      final errorMessage = AppErrorHandler.getErrorMessage(error);
      _setError(errorMessage);
      AppErrorHandler.handleError(error);
    } finally {
      _setLoading(practiceId, false);
    }
  }

  Future<BulkParticipationResult> bulkUpdateParticipation(
      BulkParticipationRequest request) async {
    final successfulIds = <String>[];
    final failedIds = <String>[];
    final errors = <String, String>{};

    for (final practiceId in request.practiceIds) {
      try {
        await updateParticipationStatus(
          request.clubId,
          practiceId,
          request.newStatus,
          isAdmin: false,
        );
        successfulIds.add(practiceId);
      } catch (error) {
        failedIds.add(practiceId);
        errors[practiceId] = error.toString();
      }
    }

    return BulkParticipationResult(
      successfulIds: successfulIds,
      failedIds: failedIds,
      errors: errors,
      appliedStatus: request.newStatus,
    );
  }

  Map<String, ParticipationStatus> getBulkParticipationStatuses(
      List<String> practiceIds) {
    final result = <String, ParticipationStatus>{};
    for (final id in practiceIds) {
      result[id] = getParticipationStatus(id);
    }
    return result;
  }

  Future<void> refreshPracticeParticipation(String clubId, String practiceId) async {
    try {
      final clubsRepo = ref.read(clubsRepositoryProvider);
      final club = await clubsRepo.getClub(clubId);
      final practice = club.upcomingPractices.firstWhere(
        (p) => p.id == practiceId,
        orElse: () => throw Exception('Practice not found'),
      );

      final status = practice.getParticipationStatus(_currentUserId);
      if (state.participationStatusMap[practiceId] != status) {
        final updated = Map<String, ParticipationStatus>.from(state.participationStatusMap)
          ..[practiceId] = status;
        state = state.copyWith(participationStatusMap: updated);
      }
    } catch (error) {
      AppErrorHandler.handleError(error);
    }
  }

  void clearAll() {
    state = state.copyWith(
      participationStatusMap: const {},
      loadingStates: const {},
      error: null,
    );
  }

  // Mock overrides for Effective Yes computation (dev-only)
  void setMockEffectiveYesOverrides(String practiceId, {required int baseYes}) {
    final updated = Map<String, int>.from(state.mockBaseYesOverrides)
      ..[practiceId] = baseYes;
    state = state.copyWith(mockBaseYesOverrides: updated);
  }

  void clearMockEffectiveYesOverrides(String practiceId) {
    final updated = Map<String, int>.from(state.mockBaseYesOverrides)
      ..remove(practiceId);
    state = state.copyWith(mockBaseYesOverrides: updated);
  }

  // Guest-related API (still clean slate stubs)
  PracticeGuestList getPracticeGuests(String practiceId) => const PracticeGuestList();
  bool getBringGuestState(String practiceId) => false;
  Future<void> updatePracticeGuests(String practiceId, List<Guest> guests) async {}
  Future<void> updateBringGuestState(String practiceId, bool bringGuest) async {}
  bool needsGuestConfirmation(String practiceId, ParticipationStatus newTarget) => false;

  int computeEffectiveYesCount(Practice practice) {
    // Base hard-yes from others only (override when provided by mock UI)
    int effective;
    final overrideBase = state.mockBaseYesOverrides[practice.id];
    if (overrideBase != null) {
      effective = overrideBase;
    } else {
      effective = 0;
      practice.participationResponses.forEach((userId, status) {
        if (userId != _currentUserId && status == ParticipationStatus.yes) {
          effective++;
        }
      });
    }

    if (getParticipationStatus(practice.id) == ParticipationStatus.yes) {
      final int myGuests = getPracticeGuests(practice.id).totalGuests;
      effective += 1 + myGuests;
    }

    return effective;
  }

  void _setLoading(String practiceId, bool loading) {
    final updated = Map<String, bool>.from(state.loadingStates)
      ..[practiceId] = loading;
    state = state.copyWith(loadingStates: updated);
  }

  void _setError(String? error) {
    state = state.copyWith(error: error);
  }
}

