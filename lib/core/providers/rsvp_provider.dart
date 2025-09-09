/// Centralized RSVP state management
/// 
/// This provider manages RSVP status across all practices and clubs
/// ensuring synchronization between home, club list, and club detail screens
library;

import 'package:flutter/foundation.dart';
import '../models/practice.dart';
import '../utils/error_handler.dart';
import '../../features/clubs/clubs_repository.dart';
import '../di/service_locator.dart';

class RSVPProvider with ChangeNotifier {
  final ClubsRepository _clubsRepository;
  final String _currentUserId = 'user123'; // TODO: Get from auth service
  
  RSVPProvider({ClubsRepository? clubsRepository}) 
    : _clubsRepository = clubsRepository ?? ServiceLocator.clubsRepository;

  // Map to track RSVP status for each practice
  // Key: practiceId, Value: RSVPStatus
  final Map<String, RSVPStatus> _rsvpStatusMap = {};
  
  // Map to track loading states for each practice
  final Map<String, bool> _loadingStates = {};
  
  // Error tracking
  String? _error;

  // Getters
  String? get error => _error;
  String get currentUserId => _currentUserId;

  /// Get RSVP status for a specific practice
  RSVPStatus getRSVPStatus(String practiceId) {
    return _rsvpStatusMap[practiceId] ?? RSVPStatus.pending;
  }
  
  /// Check if a specific practice is loading
  bool isLoading(String practiceId) {
    return _loadingStates[practiceId] ?? false;
  }
  
  /// Initialize RSVP status from a practice object
  void initializePracticeRSVP(Practice practice) {
    final status = practice.getRSVPStatus(_currentUserId);
    if (_rsvpStatusMap[practice.id] != status) {
      _rsvpStatusMap[practice.id] = status;
      // Don't notify listeners here as this is initialization
    }
  }
  
  /// Initialize RSVP statuses from a list of practices
  void initializePracticesRSVP(List<Practice> practices) {
    bool hasChanges = false;
    
    for (final practice in practices) {
      final status = practice.getRSVPStatus(_currentUserId);
      if (_rsvpStatusMap[practice.id] != status) {
        _rsvpStatusMap[practice.id] = status;
        hasChanges = true;
      }
    }
    
    if (hasChanges) {
      notifyListeners();
    }
  }

  /// Update RSVP status for a practice
  Future<void> updateRSVP(String clubId, String practiceId, RSVPStatus newStatus) async {
    _setLoading(practiceId, true);
    _setError(null);

    try {
      // Update the repository
      await _clubsRepository.updateRSVP(clubId, practiceId, newStatus);
      
      // Update local state
      _rsvpStatusMap[practiceId] = newStatus;
      
      // Notify all listeners that this practice RSVP has changed
      notifyListeners();
      
    } catch (error) {
      final errorMessage = AppErrorHandler.getErrorMessage(error);
      _setError(errorMessage);
      AppErrorHandler.handleError(error);
    } finally {
      _setLoading(practiceId, false);
    }
  }
  
  /// Refresh RSVP status for a specific practice
  Future<void> refreshPracticeRSVP(String clubId, String practiceId) async {
    try {
      final club = await _clubsRepository.getClub(clubId);
      final practice = club.upcomingPractices.firstWhere(
        (p) => p.id == practiceId,
        orElse: () => throw Exception('Practice not found'),
      );
      
      final status = practice.getRSVPStatus(_currentUserId);
      if (_rsvpStatusMap[practiceId] != status) {
        _rsvpStatusMap[practiceId] = status;
        notifyListeners();
      }
    } catch (error) {
      AppErrorHandler.handleError(error);
    }
  }
  
  /// Clear all RSVP data (useful for user logout, etc.)
  void clearAll() {
    _rsvpStatusMap.clear();
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
  
  /// Debug method to see all tracked RSVP statuses
  void debugPrintRSVPs() {
    debugPrint('=== RSVP Provider Debug ===');
    for (final entry in _rsvpStatusMap.entries) {
      debugPrint('Practice ${entry.key}: ${entry.value.name}');
    }
    debugPrint('=========================');
  }
}
