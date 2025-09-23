/// Practice filter provider for managing UI filter state
/// 
/// Handles level and location filtering for practice lists,
/// separated from ParticipationProvider for better separation of concerns.
library;

import 'package:flutter/foundation.dart';
import '../models/practice.dart';

class PracticeFilterProvider with ChangeNotifier {
  // Level filter state (session-based persistence)
  Set<String> _selectedLevels = <String>{};
  
  // Location filter state (session-based persistence)
  Set<String> _selectedLocations = <String>{};

  // Getters
  Set<String> get selectedLevels => Set.from(_selectedLevels);
  Set<String> get selectedLocations => Set.from(_selectedLocations);
  bool get hasLevelFiltersApplied => _selectedLevels.isNotEmpty;
  bool get hasLocationFiltersApplied => _selectedLocations.isNotEmpty;
  bool get hasAnyFiltersApplied => hasLevelFiltersApplied || hasLocationFiltersApplied;

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

  /// Get filtered practices from a list
  List<Practice> getFilteredPractices(List<Practice> practices) {
    if (!hasAnyFiltersApplied) {
      return practices;
    }
    
    return practices.where(shouldShowPractice).toList();
  }

  /// Get filter summary text for UI display
  String getFilterSummaryText() {
    final parts = <String>[];
    
    if (hasLevelFiltersApplied) {
      parts.add('${_selectedLevels.length} level${_selectedLevels.length == 1 ? '' : 's'}');
    }
    
    if (hasLocationFiltersApplied) {
      parts.add('${_selectedLocations.length} location${_selectedLocations.length == 1 ? '' : 's'}');
    }
    
    if (parts.isEmpty) {
      return 'No filters applied';
    }
    
    return 'Filtered by: ${parts.join(', ')}';
  }
}
