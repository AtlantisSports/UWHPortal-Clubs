import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/practice_filter_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/club.dart';

/// Bottom sheet modal for filtering practices by level and location
/// Follows the same design pattern as the Events filter modal
class PracticeFilterModal extends StatefulWidget {
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
  State<PracticeFilterModal> createState() => _PracticeFilterModalState();
}

class _PracticeFilterModalState extends State<PracticeFilterModal> {
  late Set<String> _tempSelectedLevels;
  late Set<String> _tempSelectedLocations;
  bool _showToast = false;

  @override
  void initState() {
    super.initState();
    final filterProvider = Provider.of<PracticeFilterProvider>(context, listen: false);
    _tempSelectedLevels = Set.from(filterProvider.selectedLevels);
    _tempSelectedLocations = Set.from(filterProvider.selectedLocations);
  }

  void _applyFilters() {
    final filterProvider = Provider.of<PracticeFilterProvider>(context, listen: false);
    filterProvider.updateSelectedLevels(_tempSelectedLevels);
    filterProvider.updateSelectedLocations(_tempSelectedLocations);
    // Close the modal after applying filters
    widget.onFiltersChanged?.call();
  }

  void _showErrorToast() {
    setState(() {
      _showToast = true;
    });

    // Hide toast after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showToast = false;
        });
      }
    });
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
    final filterProvider = Provider.of<PracticeFilterProvider>(context, listen: false);
    setState(() {
      _tempSelectedLevels.clear();
      _tempSelectedLocations.clear();
    });
    // Apply the cleared filters immediately so changes persist, but keep modal open
    filterProvider.updateSelectedLevels(_tempSelectedLevels);
    filterProvider.updateSelectedLocations(_tempSelectedLocations);
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

      // Custom toast overlay
      if (_showToast)
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'No practices match the selected filters. Please adjust your selection.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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