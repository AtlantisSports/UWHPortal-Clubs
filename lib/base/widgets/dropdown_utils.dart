import 'package:flutter/material.dart';
import 'multi_select_dropdown.dart';

/// Utility class for creating standardized dropdown components
class DropdownUtils {
  /// Creates a standard filter dropdown with "All" option
  static Widget createFilterDropdown({
    required String label,
    required List<String> items,
    required List<String> selectedItems,
    required Function(List<String>) onSelectionChanged,
    String? allOptionText,
    String? placeholder,
  }) {
    return MultiSelectDropdown(
      label: label,
      items: items,
      selectedItems: selectedItems,
      onSelectionChanged: onSelectionChanged,
      showAllOption: true,
      allOptionText: allOptionText ?? 'All ${label.toLowerCase()}',
      placeholder: placeholder ?? 'Select ${label.toLowerCase()}',
    );
  }

  /// Creates a standard filter dropdown with "None" option
  static Widget createNoneFilterDropdown({
    required String label,
    required List<String> items,
    required List<String> selectedItems,
    required Function(List<String>) onSelectionChanged,
    String? noneOptionText,
    String? placeholder,
  }) {
    return MultiSelectDropdown(
      label: label,
      items: items,
      selectedItems: selectedItems,
      onSelectionChanged: onSelectionChanged,
      showNoneOption: true,
      noneOptionText: noneOptionText ?? 'None',
      placeholder: placeholder ?? 'Select ${label.toLowerCase()}',
    );
  }

  /// Creates a standard multi-select dropdown without "All" option
  static Widget createMultiSelectDropdown({
    required String label,
    required List<String> items,
    required List<String> selectedItems,
    required Function(List<String>) onSelectionChanged,
    String? placeholder,
  }) {
    return MultiSelectDropdown(
      label: label,
      items: items,
      selectedItems: selectedItems,
      onSelectionChanged: onSelectionChanged,
      showAllOption: false,
      placeholder: placeholder ?? 'Select ${label.toLowerCase()}',
    );
  }

  /// Creates a location filter dropdown
  static Widget createLocationFilter({
    required List<String> selectedLocations,
    required Function(List<String>) onLocationChanged,
    List<String>? customLocations,
  }) {
    final locations = customLocations ?? [
      'North Pool',
      'South Pool', 
      'East Pool',
      'West Pool',
      'Main Pool',
    ];

    return createFilterDropdown(
      label: 'Location',
      items: locations,
      selectedItems: selectedLocations,
      onSelectionChanged: onLocationChanged,
      allOptionText: 'All locations',
      placeholder: 'Select locations',
    );
  }

  /// Creates a level filter dropdown
  static Widget createLevelFilter({
    required List<String> selectedLevels,
    required Function(List<String>) onLevelChanged,
    List<String>? customLevels,
  }) {
    final levels = customLevels ?? [
      'Beginner',
      'Intermediate',
      'Advanced',
      'Expert',
    ];

    return createFilterDropdown(
      label: 'Level',
      items: levels,
      selectedItems: selectedLevels,
      onSelectionChanged: onLevelChanged,
      allOptionText: 'All levels',
      placeholder: 'Select levels',
    );
  }

  /// Creates a dependent selector dropdown
  static Widget createDependentSelector({
    required List<String> selectedDependents,
    required Function(List<String>) onDependentsChanged,
    List<String>? customDependents,
  }) {
    final dependents = customDependents ?? [
      'Bart Simpson',
      'Lisa Simpson',
      'Maggie Simpson',
    ];

    return createMultiSelectDropdown(
      label: 'Dependents',
      items: dependents,
      selectedItems: selectedDependents,
      onSelectionChanged: onDependentsChanged,
      placeholder: 'Select dependents',
    );
  }

  /// Creates a category filter dropdown
  static Widget createCategoryFilter({
    required List<String> selectedCategories,
    required Function(List<String>) onCategoryChanged,
    List<String>? customCategories,
  }) {
    final categories = customCategories ?? [
      'Training',
      'Competition',
      'Social',
      'Workshop',
      'Tournament',
    ];

    return createFilterDropdown(
      label: 'Category',
      items: categories,
      selectedItems: selectedCategories,
      onSelectionChanged: onCategoryChanged,
      allOptionText: 'All categories',
      placeholder: 'Select categories',
    );
  }

  /// Creates a time slot filter dropdown
  static Widget createTimeSlotFilter({
    required List<String> selectedTimeSlots,
    required Function(List<String>) onTimeSlotChanged,
    List<String>? customTimeSlots,
  }) {
    final timeSlots = customTimeSlots ?? [
      'Morning (6AM-12PM)',
      'Afternoon (12PM-6PM)',
      'Evening (6PM-10PM)',
      'Late Night (10PM+)',
    ];

    return createFilterDropdown(
      label: 'Time Slot',
      items: timeSlots,
      selectedItems: selectedTimeSlots,
      onSelectionChanged: onTimeSlotChanged,
      allOptionText: 'All time slots',
      placeholder: 'Select time slots',
    );
  }

  /// Creates a status filter dropdown
  static Widget createStatusFilter({
    required List<String> selectedStatuses,
    required Function(List<String>) onStatusChanged,
    List<String>? customStatuses,
  }) {
    final statuses = customStatuses ?? [
      'Active',
      'Inactive',
      'Pending',
      'Cancelled',
    ];

    return createFilterDropdown(
      label: 'Status',
      items: statuses,
      selectedItems: selectedStatuses,
      onSelectionChanged: onStatusChanged,
      allOptionText: 'All statuses',
      placeholder: 'Select statuses',
    );
  }
}