import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/practice_filter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/club.dart';

import 'toast_manager.dart';

/// Bottom sheet modal for filtering practices by level and location
/// Follows the same design pattern as the Events filter modal
class PracticeFilterModal extends ConsumerStatefulWidget {
  final Set<String> availableLevels;
  final Set<String> availableLocations;
  final Club club; // Added to access practice data for validation
  final VoidCallback? onFiltersChanged;

  const PracticeFilterModal({
    super.key,
    required this.availableLevels,
    required this.availableLocations,
    required this.club,
    this.onFiltersChanged,
  });

  @override
  ConsumerState<PracticeFilterModal> createState() => _PracticeFilterModalState();
}

class _PracticeFilterModalState extends ConsumerState<PracticeFilterModal> {
  late Set<String> _tempSelectedLevels;
  late Set<String> _tempSelectedLocations;


  @override
  void initState() {
    super.initState();
    final filterState = ref.read(practiceFilterControllerProvider);
    _tempSelectedLevels = Set.from(filterState.selectedLevels);
    _tempSelectedLocations = Set.from(filterState.selectedLocations);
  }

  void _applyFilters() {
    final filterController = ref.read(practiceFilterControllerProvider.notifier);
    filterController.updateSelectedLevels(_tempSelectedLevels);
    filterController.updateSelectedLocations(_tempSelectedLocations);
    // Close the modal after applying filters
    widget.onFiltersChanged?.call();
  }

  void _showErrorToast() {
    ToastManager.showTopToast(
      context,
      message: 'No practices match the selected filters. Please adjust your selection.',
      color: Colors.red.shade600,
      icon: Icons.error_outline,
      persistent: false,
      duration: const Duration(seconds: 3),
    );
  }

  bool _hasMatchingPractices() {
    // If no filters selected, all practices are shown
    if (_tempSelectedLevels.isEmpty && _tempSelectedLocations.isEmpty) {
      return true;
    }

    return widget.club.upcomingPractices.any((practice) {
      bool levelMatch = _tempSelectedLevels.isEmpty || _tempSelectedLevels.contains(practice.tag);
      bool locationMatch = _tempSelectedLocations.isEmpty || _tempSelectedLocations.contains(practice.location);
      return levelMatch && locationMatch;
    });
  }

  void _resetFilters() {
    final filterController = ref.read(practiceFilterControllerProvider.notifier);
    setState(() {
      _tempSelectedLevels.clear();
      _tempSelectedLocations.clear();
    });
    // Apply the cleared filters immediately so changes persist, but keep modal open
    filterController.updateSelectedLevels(_tempSelectedLevels);
    filterController.updateSelectedLocations(_tempSelectedLocations);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Removed fixed height so the sheet can expand further; constrained by the sheet utility
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Stack(
        children: [
          Column(
            children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), // Reduced top whitespace by ~50%
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Practice Filters',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => widget.onFiltersChanged?.call(),
                  icon: const Icon(Icons.close),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            color: Colors.grey[300],
          ),

          // Filter options - allow content to size naturally up to max, then scroll
          Flexible(fit: FlexFit.loose,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12), // Reduced from 16 to 12
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Two-column layout for Level and Location filters
                  IntrinsicHeight(child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location column (left)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Location header
                            const Text(
                              'Location',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Location checkboxes
                            ...widget.availableLocations.map((location) => _buildLocationOption(location)),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8), // Reduced spacing before separator

                      // Vertical separator
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: Colors.grey[300],
                      ),

                      const SizedBox(width: 8), // Reduced spacing after separator

                      // Level column (right)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Level header
                            const Text(
                              'Level',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Level checkboxes
                            ...widget.availableLevels.map((level) => _buildLevelOption(level)),
                          ],
                        ),
                      ),
                    ],
                  )),


                ],
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Horizontal separator
          Divider(
            height: 1,
            color: Colors.grey[300],
            thickness: 1,
          ),

          const SizedBox(height: 8),

          // Button row with Reset and Apply side by side (fixed outside scroll)
          Row(
            children: [
              // Reset button (left side)
              Expanded(
                child: ElevatedButton(
                  onPressed: _resetFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'RESET FILTERS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Apply button (right side)
              Expanded(
                child: ElevatedButton(
                  onPressed: _hasMatchingPractices() ? _applyFilters : _showErrorToast,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasMatchingPractices() ? AppColors.primary : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'APPLY FILTERS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _hasMatchingPractices() ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ],
          ),


          ],
        ),

        ],
      ),
    );
  }

  Widget _buildLevelOption(String level) {
    final isSelected = _tempSelectedLevels.contains(level);

    return Container(
      margin: const EdgeInsets.only(bottom: 12), // Reduced from 16 to 12
      child: Row(
        children: [
          Expanded(
            child: Text(
              level,
              style: const TextStyle(
                fontSize: 15, // Reduced from 16 to 15
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Checkbox(
            value: isSelected,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _tempSelectedLevels.add(level);
                } else {
                  _tempSelectedLevels.remove(level);
                }
              });

            },
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationOption(String location) {
    final isSelected = _tempSelectedLocations.contains(location);

    return Container(
      margin: const EdgeInsets.only(bottom: 12), // Reduced from 16 to 12
      child: Row(
        children: [
          Expanded(
            child: Text(
              location,
              style: const TextStyle(
                fontSize: 15, // Reduced from 16 to 15
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Checkbox(
            value: isSelected,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _tempSelectedLocations.add(location);
                } else {
                  _tempSelectedLocations.remove(location);
                }
              });
            },
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}