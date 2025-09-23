import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/practice_filter_provider.dart';
import '../../core/constants/app_constants.dart';

/// Bottom sheet modal for filtering practices by level and location
/// Follows the same design pattern as the Events filter modal
class LevelFilterModal extends StatefulWidget {
  final Set<String> availableLevels;
  final Set<String> availableLocations;
  final VoidCallback? onFiltersChanged;

  const LevelFilterModal({
    super.key,
    required this.availableLevels,
    required this.availableLocations,
    this.onFiltersChanged,
  });

  @override
  State<LevelFilterModal> createState() => _LevelFilterModalState();
}

class _LevelFilterModalState extends State<LevelFilterModal> {
  late Set<String> _tempSelectedLevels;
  late Set<String> _tempSelectedLocations;

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
      height: 400, // Fixed height to work well as bottom sheet
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Modal handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
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
          
          // Filter options - using Expanded to fill remaining space
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12), // Reduced from 16 to 12
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Two-column layout for Level and Location filters
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Level column (left)
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
                      
                      const SizedBox(width: 16), // Spacing between columns
                      
                      // Location column (right)
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
                    ],
                  ),
                  
                  const SizedBox(height: 24), // Reduced from 32 to 24
                  
                  // Button row with Reset and Apply side by side
                  Row(
                    children: [
                      // Reset button (left side)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _resetFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14), // Reduced from 16 to 14
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
                      
                      const SizedBox(width: 16), // Spacing between buttons
                      
                      // Apply button (right side)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _applyFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14), // Reduced from 16 to 14
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'APPLY FILTERS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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