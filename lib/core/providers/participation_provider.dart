/// Unified participation status provider
/// Handles both RSVP and attendance management for practices
library;

import 'package:flutter/foundation.dart';
import '../models/practice.dart';
import '../models/guest.dart';
import '../utils/error_handler.dart';
import '../data/mock_data_service.dart';
import '../../features/clubs/clubs_repository.dart';
import '../di/service_locator.dart';

class ParticipationProvider with ChangeNotifier {
  final ClubsRepository _clubsRepository;
  
  ParticipationProvider({ClubsRepository? clubsRepository}) 
    : _clubsRepository = clubsRepository ?? ServiceLocator.clubsRepository;

  // Map to track participation status for each practice
  // Key: practiceId, Value: ParticipationStatus
  final Map<String, ParticipationStatus> _participationStatusMap = {};
  
  // Map to track guest lists for each practice
  // Key: practiceId, Value: PracticeGuestList
  final Map<String, PracticeGuestList> _practiceGuestsMap = {};
  
  // Map to track "bring guest" checkbox state for each practice
  // Key: practiceId, Value: bool
  final Map<String, bool> _bringGuestMap = {};
  
  // Map to track loading states for each practice
  final Map<String, bool> _loadingStates = {};
  
  // Level filter state (session-based persistence)
  Set<String> _selectedLevels = <String>{};
  
  // Location filter state (session-based persistence)
  Set<String> _selectedLocations = <String>{};
  
  // Bulk operation tracking
  bool _isBulkOperationInProgress = false;
  String? _bulkOperationStatus;
  
  // Error tracking
  String? _error;

  // Getters
  String? get error => _error;
  String get currentUserId => MockDataService.currentUserId;
  bool get isBulkOperationInProgress => _isBulkOperationInProgress;
  String? get bulkOperationStatus => _bulkOperationStatus;
  Set<String> get selectedLevels => Set.from(_selectedLevels);
  Set<String> get selectedLocations => Set.from(_selectedLocations);
  bool get hasLevelFiltersApplied => _selectedLevels.isNotEmpty;
  bool get hasLocationFiltersApplied => _selectedLocations.isNotEmpty;

  /// Get participation status for a specific practice
  ParticipationStatus getParticipationStatus(String practiceId) {
    return _participationStatusMap[practiceId] ?? ParticipationStatus.blank;
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
  
  /// Initialize participation status from a practice object
  void initializePracticeParticipation(Practice practice) {
    final status = practice.getParticipationStatus(currentUserId);
    if (_participationStatusMap[practice.id] != status) {
      _participationStatusMap[practice.id] = status;
      // Don't notify listeners here as this is initialization
    }
    
    // Initialize mock guest data for past practices
    _initializeMockGuestData(practice);
  }
  
  /// Initialize participation statuses from a list of practices
  void initializePracticesParticipation(List<Practice> practices) {
    bool hasChanges = false;
    
    for (final practice in practices) {
      final status = practice.getParticipationStatus(currentUserId);
      if (_participationStatusMap[practice.id] != status) {
        _participationStatusMap[practice.id] = status;
        hasChanges = true;
      }
      
      // Initialize mock guest data for past practices
      _initializeMockGuestData(practice);
    }
    
    if (hasChanges) {
      notifyListeners();
    }
  }

  /// Initialize mock guest data for a practice (past practices only)
  void _initializeMockGuestData(Practice practice) {
    // Only initialize if we don't already have guest data for this practice
    if (_practiceGuestsMap.containsKey(practice.id)) {
      return;
    }
    
    // Get mock guest data from MockDataService
    final mockGuests = MockDataService.getMockGuestsForPractice(practice.id, practice.dateTime);
    
    // Only set if there are guests to avoid unnecessary empty entries
    if (mockGuests.totalGuests > 0) {
      _practiceGuestsMap[practice.id] = mockGuests;
      _bringGuestMap[practice.id] = true; // Set bring guest flag if guests exist
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
  Future<BulkParticipationResult> bulkUpdateParticipation(BulkParticipationRequest request) async {
    if (_isBulkOperationInProgress) {
      throw Exception('Another bulk operation is already in progress');
    }
    
    _isBulkOperationInProgress = true;
    _bulkOperationStatus = 'Processing ${request.practiceIds.length} practices...';
    _setError(null);
    notifyListeners();

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
          _bulkOperationStatus = 'Updated ${successfulIds.length}/${request.practiceIds.length} practices...';
          notifyListeners();
        } catch (error) {
          failedIds.add(practiceId);
          errors[practiceId] = error.toString();
        }
      }
    } finally {
      _isBulkOperationInProgress = false;
      _bulkOperationStatus = null;
      notifyListeners();
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
    _loadingStates.clear();
    _error = null;
    notifyListeners();
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
  
  /// Level Filter Management
  
  /// Get all available practice levels from a list of practices
  Set<String> getAvailableLevels(List<Practice> practices) {
    final levels = <String>{};
    for (final practice in practices) {
      if (practice.tag != null && practice.tag!.isNotEmpty) {
        levels.add(practice.tag!);
      }
    }
    return levels;
  }
  
  /// Get all available practice locations from a list of practices
  Set<String> getAvailableLocations(List<Practice> practices) {
    final locations = <String>{};
    for (final practice in practices) {
      if (practice.location.isNotEmpty) {
        locations.add(practice.location);
      }
    }
    return locations;
  }
  
  /// Update selected levels for filtering
  void updateSelectedLevels(Set<String> levels) {
    _selectedLevels = Set.from(levels);
    notifyListeners();
  }
  
  /// Update selected locations for filtering
  void updateSelectedLocations(Set<String> locations) {
    _selectedLocations = Set.from(locations);
    notifyListeners();
  }
  
  /// Add a level to the filter
  void addLevelToFilter(String level) {
    _selectedLevels.add(level);
    notifyListeners();
  }
  
  /// Add a location to the filter
  void addLocationToFilter(String location) {
    _selectedLocations.add(location);
    notifyListeners();
  }
  
  /// Remove a level from the filter
  void removeLevelFromFilter(String level) {
    _selectedLevels.remove(level);
    notifyListeners();
  }
  
  /// Remove a location from the filter
  void removeLocationFromFilter(String location) {
    _selectedLocations.remove(location);
    notifyListeners();
  }
  
  /// Clear all level filters
  void clearLevelFilters() {
    _selectedLevels.clear();
    notifyListeners();
  }
  
  /// Clear all location filters
  void clearLocationFilters() {
    _selectedLocations.clear();
    notifyListeners();
  }
  
  /// Clear all filters (both level and location)
  void clearAllFilters() {
    _selectedLevels.clear();
    _selectedLocations.clear();
    notifyListeners();
  }
  
  /// Check if a practice passes both level and location filters
  bool shouldShowPractice(Practice practice) {
    // Check level filter
    final passesLevelFilter = _selectedLevels.isEmpty || 
        (practice.tag != null && practice.tag!.isNotEmpty && _selectedLevels.contains(practice.tag));
    
    // Check location filter
    final passesLocationFilter = _selectedLocations.isEmpty || 
        _selectedLocations.contains(practice.location);
    
    // Practice must pass both filters
    return passesLevelFilter && passesLocationFilter;
  }
  
  /// Debug method to see all tracked participation statuses
  void debugPrintParticipation() {
    debugPrint('=== Participation Provider Debug ===');
    for (final entry in _participationStatusMap.entries) {
      debugPrint('Practice ${entry.key}: ${entry.value.name}');
    }
    debugPrint('====================================');
  }
}