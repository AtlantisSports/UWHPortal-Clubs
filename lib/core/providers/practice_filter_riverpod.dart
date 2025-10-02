/// Riverpod version of PracticeFilterProvider
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/practice.dart';

part 'practice_filter_riverpod.freezed.dart';
part 'practice_filter_riverpod.g.dart';

@freezed
abstract class PracticeFilterState with _$PracticeFilterState {
  const factory PracticeFilterState({
    @Default({}) Set<String> selectedLevels,
    @Default({}) Set<String> selectedLocations,
  }) = _PracticeFilterState;
}

@riverpod
class PracticeFilterController extends _$PracticeFilterController {
  @override
  PracticeFilterState build() {
    return const PracticeFilterState();
  }

  // Getters for convenience
  Set<String> get selectedLevels => Set.from(state.selectedLevels);
  Set<String> get selectedLocations => Set.from(state.selectedLocations);
  bool get hasLevelFiltersApplied => state.selectedLevels.isNotEmpty;
  bool get hasLocationFiltersApplied => state.selectedLocations.isNotEmpty;
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
    state = state.copyWith(selectedLevels: Set.from(levels));
  }
  
  /// Update selected locations for filtering
  void updateSelectedLocations(Set<String> locations) {
    state = state.copyWith(selectedLocations: Set.from(locations));
  }
  
  /// Toggle a specific level filter
  void toggleLevel(String level) {
    final newLevels = Set<String>.from(state.selectedLevels);
    if (newLevels.contains(level)) {
      newLevels.remove(level);
    } else {
      newLevels.add(level);
    }
    state = state.copyWith(selectedLevels: newLevels);
  }
  
  /// Toggle a specific location filter
  void toggleLocation(String location) {
    final newLocations = Set<String>.from(state.selectedLocations);
    if (newLocations.contains(location)) {
      newLocations.remove(location);
    } else {
      newLocations.add(location);
    }
    state = state.copyWith(selectedLocations: newLocations);
  }
  
  /// Clear all level filters
  void clearLevelFilters() {
    state = state.copyWith(selectedLevels: <String>{});
  }
  
  /// Clear all location filters
  void clearLocationFilters() {
    state = state.copyWith(selectedLocations: <String>{});
  }
  
  /// Clear all filters
  void clearAllFilters() {
    state = const PracticeFilterState();
  }
  
  /// Check if a practice passes both level and location filters
  bool shouldShowPractice(Practice practice) {
    // Check level filter
    final passesLevelFilter = state.selectedLevels.isEmpty || 
        (practice.tag != null && practice.tag!.isNotEmpty && state.selectedLevels.contains(practice.tag));
    
    // Check location filter
    final passesLocationFilter = state.selectedLocations.isEmpty || 
        state.selectedLocations.contains(practice.location);
    
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
}
