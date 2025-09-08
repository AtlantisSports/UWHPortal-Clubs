/// Clubs state management using Provider pattern
/// 
/// This centralizes all clubs-related state and business logic,
/// removing it from UI widgets and improving testability.
library;

import 'package:flutter/foundation.dart';
import '../../core/models/club.dart';
import '../../core/models/practice.dart';
import '../../core/utils/error_handler.dart';
import 'clubs_repository.dart';
import '../../core/di/service_locator.dart';

class ClubsProvider with ChangeNotifier {
  final ClubsRepository _clubsRepository;
  
  ClubsProvider({ClubsRepository? clubsRepository}) 
    : _clubsRepository = clubsRepository ?? ServiceLocator.clubsRepository;

  // State
  List<Club> _clubs = [];
  List<Club> _filteredClubs = [];
  Club? _selectedClub;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedLocation;
  List<String> _selectedTags = [];

  // Getters
  List<Club> get clubs => _filteredClubs;
  Club? get selectedClub => _selectedClub;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedLocation => _selectedLocation;
  List<String> get selectedTags => _selectedTags;
  bool get hasClubs => _clubs.isNotEmpty;

  /// Load all clubs from API
  Future<void> loadClubs() async {
    _setLoading(true);
    _setError(null);

    try {
      _clubs = await _clubsRepository.getClubs();
      _applyFilters();
    } catch (error) {
      final errorMessage = AppErrorHandler.getErrorMessage(error);
      _setError(errorMessage);
      
      // Log error for debugging
      AppErrorHandler.handleError(error);
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh clubs data
  Future<void> refreshClubs() async {
    await _clubsRepository.refreshClubs();
    await loadClubs();
  }

  /// Search clubs by query
  void searchClubs(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Filter clubs by location
  void filterByLocation(String? location) {
    _selectedLocation = location;
    _applyFilters();
    notifyListeners();
  }

  /// Filter clubs by tags
  void filterByTags(List<String> tags) {
    _selectedTags = tags;
    _applyFilters();
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedLocation = null;
    _selectedTags = [];
    _applyFilters();
    notifyListeners();
  }

  /// Select a specific club
  void selectClub(Club club) {
    _selectedClub = club;
    notifyListeners();
  }

  /// Handle RSVP change for a practice
  Future<void> handleRSVPChange(String practiceId, RSVPStatus status) async {
    if (_selectedClub == null) return;

    try {
      await _clubsRepository.updateRSVP(_selectedClub!.id, practiceId, status);
      
      // Refresh the selected club data
      _selectedClub = await _clubsRepository.getClub(_selectedClub!.id);
      
      // Update in the main clubs list
      final clubIndex = _clubs.indexWhere((c) => c.id == _selectedClub!.id);
      if (clubIndex != -1) {
        _clubs[clubIndex] = _selectedClub!;
        _applyFilters();
      }

      notifyListeners();
    } catch (error) {
      final errorMessage = AppErrorHandler.getErrorMessage(error);
      _setError(errorMessage);
      AppErrorHandler.handleError(error);
    }
  }

  /// Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    if (error != null) {
      notifyListeners();
    }
  }

  void _applyFilters() {
    _filteredClubs = _clubs.where((club) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!club.name.toLowerCase().contains(query) &&
            !club.description.toLowerCase().contains(query) &&
            !club.location.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Location filter
      if (_selectedLocation != null && 
          club.location != _selectedLocation) {
        return false;
      }

      // Tags filter
      if (_selectedTags.isNotEmpty &&
          !_selectedTags.every((tag) => club.tags.contains(tag))) {
        return false;
      }

      return true;
    }).toList();
  }
}
