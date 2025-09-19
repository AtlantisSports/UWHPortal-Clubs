import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/participation_provider.dart';
import '../../core/constants/app_constants.dart';

/// Bottom sheet modal for filtering practices by level
/// Follows the same design pattern as the Events filter modal
class LevelFilterModal extends StatefulWidget {
  final Set<String> availableLevels;
  final VoidCallback? onFiltersChanged;

  const LevelFilterModal({
    super.key,
    required this.availableLevels,
    this.onFiltersChanged,
  });

  @override
  State<LevelFilterModal> createState() => _LevelFilterModalState();
}

class _LevelFilterModalState extends State<LevelFilterModal> {
  late Set<String> _tempSelectedLevels;

  @override
  void initState() {
    super.initState();
    final participationProvider = Provider.of<ParticipationProvider>(context, listen: false);
    _tempSelectedLevels = Set.from(participationProvider.selectedLevels);
  }

  void _applyFilters() {
    final participationProvider = Provider.of<ParticipationProvider>(context, listen: false);
    participationProvider.updateSelectedLevels(_tempSelectedLevels);
    // Close the modal after applying filters
    widget.onFiltersChanged?.call();
  }

  void _resetFilters() {
    final participationProvider = Provider.of<ParticipationProvider>(context, listen: false);
    setState(() {
      _tempSelectedLevels.clear();
    });
    // Apply the cleared filters immediately so changes persist, but keep modal open
    participationProvider.updateSelectedLevels(_tempSelectedLevels);
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
                  'Level Filters',
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Level checkboxes
                  ...widget.availableLevels.map((level) => _buildLevelOption(level)),
                  
                  const SizedBox(height: 32),
                  
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              level,
              style: const TextStyle(
                fontSize: 16,
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
}