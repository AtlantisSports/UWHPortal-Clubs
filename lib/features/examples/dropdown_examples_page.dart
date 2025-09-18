/// Dropdown Utility Examples
/// Shows how to use the DropdownUtils class in various scenarios
library;

import 'package:flutter/material.dart';
import '../base/widgets/dropdown_utils.dart';

class DropdownExamplesPage extends StatefulWidget {
  const DropdownExamplesPage({super.key});

  @override
  State<DropdownExamplesPage> createState() => _DropdownExamplesPageState();
}

class _DropdownExamplesPageState extends State<DropdownExamplesPage> {
  // State variables for different dropdowns
  List<String> selectedLocations = [];
  List<String> selectedLevels = [];
  List<String> selectedDependents = [];
  List<String> selectedCategories = [];
  List<String> selectedTimeSlots = [];
  List<String> selectedStatuses = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dropdown Examples'),
        backgroundColor: const Color(0xFF0284C7),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dropdown Utility Examples',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 20),
            
            // Location Filter Example
            const Text(
              'Location Filter',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            DropdownUtils.createLocationFilter(
              selectedLocations: selectedLocations,
              onLocationChanged: (selected) {
                setState(() {
                  selectedLocations = selected;
                });
                _showSelection('Locations', selected);
              },
            ),
            const SizedBox(height: 24),
            
            // Level Filter Example
            const Text(
              'Level Filter',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            DropdownUtils.createLevelFilter(
              selectedLevels: selectedLevels,
              onLevelChanged: (selected) {
                setState(() {
                  selectedLevels = selected;
                });
                _showSelection('Levels', selected);
              },
            ),
            const SizedBox(height: 24),
            
            // Dependent Selector Example
            const Text(
              'Dependent Selector',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            DropdownUtils.createDependentSelector(
              selectedDependents: selectedDependents,
              onDependentsChanged: (selected) {
                setState(() {
                  selectedDependents = selected;
                });
                _showSelection('Dependents', selected);
              },
            ),
            const SizedBox(height: 24),
            
            // Category Filter Example
            const Text(
              'Category Filter',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            DropdownUtils.createCategoryFilter(
              selectedCategories: selectedCategories,
              onCategoryChanged: (selected) {
                setState(() {
                  selectedCategories = selected;
                });
                _showSelection('Categories', selected);
              },
            ),
            const SizedBox(height: 24),
            
            // Time Slot Filter Example
            const Text(
              'Time Slot Filter',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            DropdownUtils.createTimeSlotFilter(
              selectedTimeSlots: selectedTimeSlots,
              onTimeSlotChanged: (selected) {
                setState(() {
                  selectedTimeSlots = selected;
                });
                _showSelection('Time Slots', selected);
              },
            ),
            const SizedBox(height: 24),
            
            // Status Filter Example
            const Text(
              'Status Filter',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            DropdownUtils.createStatusFilter(
              selectedStatuses: selectedStatuses,
              onStatusChanged: (selected) {
                setState(() {
                  selectedStatuses = selected;
                });
                _showSelection('Statuses', selected);
              },
            ),
            const SizedBox(height: 24),
            
            // Custom Dropdown Example
            const Text(
              'Custom Filter Dropdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            DropdownUtils.createFilterDropdown(
              label: 'Custom Options',
              items: ['Option A', 'Option B', 'Option C', 'Option D'],
              selectedItems: [],
              onSelectionChanged: (selected) {
                _showSelection('Custom Options', selected);
              },
              allOptionText: 'All custom options',
              placeholder: 'Select custom options',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  void _showSelection(String type, List<String> selected) {
    final message = selected.isEmpty 
        ? 'No $type selected'
        : '$type: ${selected.join(', ')}';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF0284C7),
      ),
    );
  }
}

/// Code Examples for Using DropdownUtils
/// 
/// Basic Usage:
/// ```dart
/// // Simple location filter
/// DropdownUtils.createLocationFilter(
///   selectedLocations: _selectedLocations,
///   onLocationChanged: (selected) {
///     setState(() {
///       _selectedLocations = selected;
///     });
///   },
/// )
/// 
/// // Custom level filter with specific options
/// DropdownUtils.createLevelFilter(
///   selectedLevels: _selectedLevels,
///   onLevelChanged: (selected) => _handleLevelChange(selected),
///   customLevels: ['Beginner', 'Expert'], // Override default levels
/// )
/// 
/// // Generic filter dropdown
/// DropdownUtils.createFilterDropdown(
///   label: 'Priority',
///   items: ['High', 'Medium', 'Low'],
///   selectedItems: _selectedPriorities,
///   onSelectionChanged: _handlePriorityChange,
///   allOptionText: 'All priorities',
/// )
/// 
/// // Multi-select without "All" option
/// DropdownUtils.createMultiSelectDropdown(
///   label: 'Skills',
///   items: ['Swimming', 'Diving', 'Water Polo'],
///   selectedItems: _selectedSkills,
///   onSelectionChanged: _handleSkillsChange,
/// )
/// ```
/// 
/// Available Utility Functions:
/// - createFilterDropdown() - Generic filter with "All" option
/// - createMultiSelectDropdown() - Multi-select without "All" option
/// - createLocationFilter() - Pre-configured location filter
/// - createLevelFilter() - Pre-configured level filter
/// - createDependentSelector() - Pre-configured dependent selector
/// - createCategoryFilter() - Pre-configured category filter
/// - createTimeSlotFilter() - Pre-configured time slot filter
/// - createStatusFilter() - Pre-configured status filter
/// 
/// Benefits:
/// - Consistent styling across the app
/// - Reduced code duplication
/// - Easy to maintain and update
/// - Pre-configured common use cases
/// - Flexible customization options