/// Practice filtering business logic service
/// Handles all practice filtering rules and operations
library;

import '../models/practice.dart';

/// Service for handling practice filtering business logic
class PracticeFilterService {
  /// Filter practices by location
  List<Practice> filterByLocation({
    required List<Practice> practices,
    required Set<String> selectedLocations,
  }) {
    // If no locations selected or "All locations" is selected, return all
    if (selectedLocations.isEmpty || selectedLocations.contains('All locations')) {
      return practices;
    }
    
    return practices.where((practice) => 
      selectedLocations.contains(practice.location)
    ).toList();
  }

  /// Filter practices by level/tag
  List<Practice> filterByLevel({
    required List<Practice> practices,
    required Set<String> selectedLevels,
  }) {
    // If no levels selected or "All levels" is selected, return all
    if (selectedLevels.isEmpty || selectedLevels.contains('All levels')) {
      return practices;
    }
    
    return practices.where((practice) => 
      practice.tag != null && selectedLevels.contains(practice.tag!)
    ).toList();
  }

  /// Apply multiple filters to practices
  List<Practice> applyFilters({
    required List<Practice> practices,
    Set<String>? selectedLocations,
    Set<String>? selectedLevels,
  }) {
    var filteredPractices = practices;
    
    // Apply location filter
    if (selectedLocations != null) {
      filteredPractices = filterByLocation(
        practices: filteredPractices,
        selectedLocations: selectedLocations,
      );
    }
    
    // Apply level filter
    if (selectedLevels != null) {
      filteredPractices = filterByLevel(
        practices: filteredPractices,
        selectedLevels: selectedLevels,
      );
    }
    
    return filteredPractices;
  }

  /// Get unique locations from practices
  List<String> getUniqueLocations(List<Practice> practices) {
    final locations = practices.map((p) => p.location).toSet().toList();
    locations.sort();
    return ['All locations', ...locations];
  }

  /// Get unique levels/tags from practices
  List<String> getUniqueLevels(List<Practice> practices) {
    final levels = practices
        .where((p) => p.tag != null)
        .map((p) => p.tag!)
        .toSet()
        .toList();
    levels.sort();
    return ['All levels', ...levels];
  }

  /// Check if any filters are active
  bool hasActiveFilters({
    Set<String>? selectedLocations,
    Set<String>? selectedLevels,
  }) {
    final hasLocationFilter = selectedLocations != null && 
        selectedLocations.isNotEmpty && 
        !selectedLocations.contains('All locations');
        
    final hasLevelFilter = selectedLevels != null && 
        selectedLevels.isNotEmpty && 
        !selectedLevels.contains('All levels');
        
    return hasLocationFilter || hasLevelFilter;
  }

  /// Get filter summary text
  String getFilterSummary({
    Set<String>? selectedLocations,
    Set<String>? selectedLevels,
  }) {
    final filters = <String>[];
    
    if (selectedLocations != null && 
        selectedLocations.isNotEmpty && 
        !selectedLocations.contains('All locations')) {
      if (selectedLocations.length == 1) {
        filters.add('Location: ${selectedLocations.first}');
      } else {
        filters.add('Locations: ${selectedLocations.length} selected');
      }
    }
    
    if (selectedLevels != null && 
        selectedLevels.isNotEmpty && 
        !selectedLevels.contains('All levels')) {
      if (selectedLevels.length == 1) {
        filters.add('Level: ${selectedLevels.first}');
      } else {
        filters.add('Levels: ${selectedLevels.length} selected');
      }
    }
    
    if (filters.isEmpty) {
      return 'No filters applied';
    }
    
    return filters.join(', ');
  }

  /// Clear all filters
  Map<String, Set<String>> clearAllFilters() {
    return {
      'locations': <String>{},
      'levels': <String>{},
    };
  }
}

/// Static instance for easy access throughout the app
final practiceFilterService = PracticeFilterService();
