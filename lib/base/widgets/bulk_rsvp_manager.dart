/// Bulk RSVP Manager Widget
/// Comprehensive bulk RSVP interface with filtering and selection capabilities
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/practice.dart';
import '../../core/models/club.dart';
import '../../core/models/guest.dart';
import '../../core/constants/dependent_constants.dart';
import 'multi_select_dropdown.dart';
import 'dropdown_utils.dart';
import 'phone_modal_utils.dart';
import 'phone_modal.dart';
import '../../core/providers/participation_provider.dart';
import '../../core/constants/app_constants.dart';

/// Comprehensive bulk RSVP manager with advanced filtering and selection
class BulkRSVPManager extends StatefulWidget {
  final Club club;
  final VoidCallback? onCancel;
  
  const BulkRSVPManager({
    super.key,
    required this.club,
    this.onCancel,
  });
  
  @override
  State<BulkRSVPManager> createState() => _BulkRSVPManagerState();
}

class _BulkRSVPManagerState extends State<BulkRSVPManager> {
  // Filter state
  Set<String> _selectedLocations = <String>{}; // Changed to Set for multi-select
  Set<String> _selectedLevels = <String>{}; // Changed to Set for multi-select
  
  // Selection state
  final Set<String> _selectedPracticeIds = <String>{};
  
  // New participation interface state - Only YES or NO for bulk RSVP
  ParticipationStatus? _selectedRSVPChoice; // YES or NO selection only
  String _selectedTimeframe = 'only_announced'; // 'only_announced', 'custom', 'all_future'
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  
  // Dependent selection state
  List<String> _selectedDependents = [];
  
  // UI state
  bool _isLoading = false;
  final Map<String, bool> _expandedDescriptions = <String, bool>{};
  
  // Dependent state - Simpson family mock data
  bool _includeDependents = false;
  final List<String> _availableDependents = DependentConstants.availableDependents;
  
  // Toast state
  bool _showToast = false;
  String _toastMessage = '';
  Color _toastColor = Colors.green;
  IconData? _toastIcon;
  
  // Available options (populated from data)
  List<String> _availableLocations = [];
  List<String> _availableLevels = [];
  
  @override
  void initState() {
    super.initState();
    _initializeFilters();
    _initializeRSVPProvider();
  }
  
  void _initializeFilters() {
    // Initialize available locations and levels from club practices
    _updateAvailableLocations();
    _updateAvailableLevels();
  }
  
  void _initializeRSVPProvider() {
    // Initialize participation provider with current club practices
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final participationProvider = Provider.of<ParticipationProvider>(context, listen: false);
      final clubPractices = _getClubPractices();
      // Note: ParticipationProvider handles initialization differently than RSVPProvider
      // We'll work with the existing structure
    });
  }
  
  void _updateAvailableLocations() {
    final clubPractices = _getClubPractices();
    final locations = clubPractices.map((p) => p.location).toSet().toList();
    locations.sort();
    
    setState(() {
      _availableLocations = locations;
    });
  }
  
  void _updateAvailableLevels() {
    final clubPractices = _getClubPractices();
    final levels = clubPractices
        .map((p) => p.tag)
        .where((tag) => tag != null)
        .cast<String>()
        .toSet()
        .toList();
    levels.sort();
    
    setState(() {
      _availableLevels = levels;
    });
  }

  List<Practice> _getClubPractices() {
    // Return representative practices for bulk RSVP (one per pattern)
    return _getRepresentativePractices();
  }
  
  /// Get representative practices (one per recurring pattern) for bulk RSVP selection
  List<Practice> _getRepresentativePractices() {
    final representatives = <Practice>[
      Practice(
        id: 'rep-denver-monday',
        clubId: widget.club.id,
        title: 'Monday Evening',
        description: 'Beginner-friendly; arrive 10 min early.',
        dateTime: DateTime(2025, 1, 6, 20, 15), // Template: Monday 8:15 PM (using first Monday of 2025)
        location: 'VMAC',
        address: '5310 E 136th Ave, Thornton, CO',
        tag: 'Open',
      ),
      Practice(
        id: 'rep-denver-wednesday',
        clubId: widget.club.id,
        title: 'Wednesday Evening',
        description: 'Shallow end reserved. High-level participants only.',
        dateTime: DateTime(2025, 1, 1, 19, 0), // Template: Wednesday 7:00 PM (using first Wednesday of 2025)
        location: 'Carmody',
        address: '2200 S Kipling St, Lakewood, CO',
        tag: 'High-Level',
      ),
      Practice(
        id: 'rep-denver-thursday',
        clubId: widget.club.id,
        title: 'Thursday Evening',
        description: 'Scrimmage heavy. High-level participants only.',
        dateTime: DateTime(2025, 1, 2, 20, 15), // Template: Thursday 8:15 PM (using first Thursday of 2025)
        location: 'VMAC',
        address: '5310 E 136th Ave, Thornton, CO',
        tag: 'High-Level',
      ),
      Practice(
        id: 'rep-denver-sunday-morning',
        clubId: widget.club.id,
        title: 'Sunday Morning',
        description: 'Drills + conditioning.',
        dateTime: DateTime(2025, 1, 5, 10, 0), // Template: Sunday 10:00 AM (using first Sunday of 2025)
        location: 'VMAC',
        address: '5310 E 136th Ave, Thornton, CO',
        tag: 'Intermediate',
      ),
      Practice(
        id: 'rep-denver-sunday-afternoon',
        clubId: widget.club.id,
        title: 'Sunday Afternoon',
        description: 'Afternoon session.',
        dateTime: DateTime(2025, 1, 5, 15, 0), // Template: Sunday 3:00 PM (using first Sunday of 2025)
        location: 'Carmody',
        address: '2200 S Kipling St, Lakewood, CO',
        tag: 'Open',
      ),
    ];
    
    // Sort by weekday (Monday=1 through Sunday=7) for consistent ordering
    return representatives
      ..sort((a, b) {
        final dayA = a.dateTime.weekday;
        final dayB = b.dateTime.weekday;
        final dayComparison = dayA.compareTo(dayB);
        if (dayComparison != 0) return dayComparison;
        // If same day, sort by time
        return a.dateTime.hour.compareTo(b.dateTime.hour);
      });
  }
  
  List<Practice> _getFilteredPractices() {
    var practices = _getClubPractices();
    
    // Apply location filter (skip if "All locations" is selected)
    if (_selectedLocations.isNotEmpty && !_selectedLocations.contains('All locations')) {
      practices = practices.where((p) => _selectedLocations.contains(p.location)).toList();
    }
    
    // Apply level filter (skip if "All levels" is selected)
    if (_selectedLevels.isNotEmpty && !_selectedLevels.contains('All levels')) {
      practices = practices.where((p) => p.tag != null && _selectedLevels.contains(p.tag!)).toList();
    }
    
    return practices;
  }
  
  @override
  Widget build(BuildContext context) {
    final filteredPractices = _getFilteredPractices();
    
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Filter Section
                _buildFilterSection(),
                
                // Practice List
                _buildPracticeList(filteredPractices),
                
                // Dependent Selection Section
                _buildDependentSelectionSection(),
                
                // Bottom Action Bar
                _buildBottomActionBar(filteredPractices),
              ],
            ),
          ),
        ),
        // Custom Toast
        if (_showToast)
          Positioned(
            top: kToolbarHeight + 48,
            left: 16,
            right: 16,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _toastColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(_toastIcon, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _toastMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic filter row based on available options
          _buildDynamicFilterRow(),
          
          const SizedBox(height: 4),
        ],
      ),
    );
  }
  
  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday: return 'Monday';
      case DateTime.tuesday: return 'Tuesday';
      case DateTime.wednesday: return 'Wednesday';
      case DateTime.thursday: return 'Thursday';
      case DateTime.friday: return 'Friday';
      case DateTime.saturday: return 'Saturday';
      case DateTime.sunday: return 'Sunday';
      default: return 'Unknown';
    }
  }
  
  Widget _buildDynamicFilterRow() {
    List<Widget> filters = [];
    
    // Show location filter only if there are multiple locations
    if (_availableLocations.length > 1) {
      filters.add(Expanded(child: _buildLocationFilter()));
    }
    
    // Show level filter only if there are multiple levels
    if (_availableLevels.length > 1) {
      if (filters.isNotEmpty) {
        filters.add(const SizedBox(width: 6));
      }
      filters.add(Expanded(child: _buildLevelFilter()));
    }
    
    return Row(children: filters);
  }
  
  Widget _buildLocationFilter() {
    return DropdownUtils.createLocationFilter(
      selectedLocations: _selectedLocations.toList(),
      onLocationChanged: (selected) {
        setState(() {
          _selectedLocations = selected.toSet();
        });
      },
      customLocations: _availableLocations,
    );
  }
  
  Widget _buildLevelFilter() {
    return DropdownUtils.createLevelFilter(
      selectedLevels: _selectedLevels.toList(),
      onLevelChanged: (selected) {
        setState(() {
          _selectedLevels = selected.toSet();
        });
      },
      customLevels: _availableLevels,
    );
  }
  
  Widget _buildPracticeList(List<Practice> filteredPractices) {
    if (filteredPractices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Color(0xFF9CA3AF),
            ),
            SizedBox(height: 16),
            Text(
              'No practices found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }
    
    return Consumer<ParticipationProvider>(
      builder: (context, participationProvider, child) {
        return _buildConsolidatedPracticeSelector(filteredPractices, participationProvider);
      },
    );
  }
  
  Widget _buildConsolidatedPracticeSelector(List<Practice> filteredPractices, ParticipationProvider participationProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Practice list
              ...filteredPractices.map((practice) {
            final isSelected = _selectedPracticeIds.contains(practice.id);
            
            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedPracticeIds.remove(practice.id);
                  } else {
                    _selectedPracticeIds.add(practice.id);
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedPracticeIds.add(practice.id);
                              } else {
                                _selectedPracticeIds.remove(practice.id);
                              }
                            });
                          },
                          activeColor: const Color(0xFF0284C7),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${_formatShortDay(practice.dateTime)} • ${_formatTimeRange(practice.dateTime)} • ${practice.location}',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Level tag indicator
                        Container(
                          width: 32,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                            border: Border.all(
                              color: const Color(0xFF0284C7),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _truncateLevel(practice.tag ?? ''),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Practice description (similar to club card)
                    if (practice.description.isNotEmpty) 
                      _buildPracticeDescription(practice),
                  ],
                ),
              ),
            );
          }),
            ],
          ),
    );
  }
  
  Widget _buildDependentSelectionSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.family_restroom,
                size: 20,
                color: Color(0xFF0284C7),
              ),
              SizedBox(width: 8),
              Text(
                'Dependent Selection',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Select dependents to include in bulk RSVP actions',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          DropdownUtils.createNoneFilterDropdown(
            label: 'Dependents',
            items: DependentConstants.availableDependents,
            selectedItems: _selectedDependents,
            onSelectionChanged: (selected) {
              setState(() {
                _selectedDependents = selected;
                // Automatically set _includeDependents based on selection
                _includeDependents = selected.isNotEmpty && !selected.contains('None selected');
              });
            },
            noneOptionText: 'None selected',
            placeholder: 'Select dependents for bulk actions',
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomActionBar(List<Practice> filteredPractices) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Instruction note
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Select Timeframe and RSVP:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ),
          
          // Timeframe and RSVP Selection in horizontal layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeframe Selection (left side)
              Expanded(
                flex: 3,
                child: _buildTimeframeSelection(),
              ),
              
              const SizedBox(width: 12),
              
              // YES/NO RSVP Buttons (right side)
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      _buildPracticeRSVPButton(
                        status: ParticipationStatus.yes,
                        isSelected: _selectedRSVPChoice == ParticipationStatus.yes,
                        onTap: () {
                          setState(() {
                            _selectedRSVPChoice = ParticipationStatus.yes;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildPracticeRSVPButton(
                        status: ParticipationStatus.no,
                        isSelected: _selectedRSVPChoice == ParticipationStatus.no,
                        onTap: () {
                          setState(() {
                            _selectedRSVPChoice = ParticipationStatus.no;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Affected practices count (shown as soon as practices are selected)
          if (_selectedPracticeIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _getAffectedPracticesText(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Cancel/Apply Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Close the bulk RSVP window
                    if (widget.onCancel != null) {
                      widget.onCancel!();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  child: Text(
                    _hasUserInput() ? 'Cancel' : 'Done',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: (_canApply() && !_isLoading) ? _applyBulkRSVP : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_canApply() && !_isLoading) ? const Color(0xFF0284C7) : const Color(0xFFE5E7EB),
                    foregroundColor: (_canApply() && !_isLoading) ? Colors.white : const Color(0xFF9CA3AF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Apply',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPracticeRSVPButton({
    required ParticipationStatus status,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = status.color;
    final fadedBg = _getFadedBackground(status);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 53,
        height: 53,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
            width: isSelected ? 3 : 1,
          ),
          color: isSelected ? fadedBg : Colors.white,
        ),
        child: Center(
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: isSelected ? 4 : 2,
              ),
              color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
            ),
            child: Icon(
              _getOverlayIcon(status),
              size: 25.7, // Only YES/NO, no maybe option
              color: color,
            ),
          ),
        ),
      ),
    );
  }
  
  Color _getFadedBackground(ParticipationStatus status) {
    switch (status) {
      case ParticipationStatus.yes:
        return const Color(0xFFECFDF5);
      case ParticipationStatus.no:
        return const Color(0xFFFEF2F2);
      default:
        return const Color(0xFFF3F4F6);
    }
  }
  
  IconData _getOverlayIcon(ParticipationStatus status) {
    switch (status) {
      case ParticipationStatus.yes:
        return Icons.check;
      case ParticipationStatus.no:
        return Icons.close;
      default:
        return Icons.radio_button_unchecked;
    }
  }
  
  Widget _buildTimeframeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Only announced option
        _buildCustomRadioOption(
          value: 'only_announced',
          title: 'Announced',
        ),
        
        // Custom date range option  
        _buildCustomRadioOption(
          value: 'custom',
          title: (_customStartDate != null && _customEndDate != null) 
              ? _getCustomDateRangeText() 
              : 'Custom',
          trailing: (_customStartDate != null && _customEndDate != null)
              ? GestureDetector(
                  onTap: _showCustomDatePicker,
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Color(0xFF6B7280),
                  ),
                )
              : null,
        ),
        
        // All future option
        _buildCustomRadioOption(
          value: 'all_future',
          title: 'All future',
        ),
      ],
    );
  }
  
  Widget _buildCustomRadioOption({
    required String value,
    required String title,
    Widget? trailing,
  }) {
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeframe = value;
        });
        
        if (value == 'custom') {
          // Show date picker immediately when custom is selected
          _showCustomDatePicker();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _selectedTimeframe == value 
                      ? const Color(0xFF0284C7) 
                      : const Color(0xFFD1D5DB),
                  width: 2,
                ),
                color: _selectedTimeframe == value 
                    ? const Color(0xFF0284C7) 
                    : Colors.transparent,
              ),
              child: _selectedTimeframe == value
                  ? const Icon(
                      Icons.circle,
                      size: 8,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing,
            ],
          ],
        ),
      ),
    );
  }
  
  String _getCustomDateRangeText() {
    if (_customStartDate == null || _customEndDate == null) {
      return 'Select dates';
    }
    
    return _formatDateRange(_customStartDate!, _customEndDate!);
  }
  
  String _formatDateRange(DateTime start, DateTime end) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    final startMonth = months[start.month - 1];
    final endMonth = months[end.month - 1];
    final startDay = start.day;
    final endDay = end.day;
    
    // Check if years are different
    if (start.year != end.year) {
      final startYear = start.year.toString().substring(2); // Last 2 digits
      final endYear = end.year.toString().substring(2); // Last 2 digits
      return "$startMonth $startDay '$startYear - $endMonth $endDay '$endYear";
    } else {
      // Same year, don't show year
      return "$startMonth $startDay - $endMonth $endDay";
    }
  }
  
  void _showCustomDatePicker() async {
    final result = await PhoneModalUtils.showPhoneFrameModal<Map<String, DateTime>>(
      context: context,
      child: _CustomDateRangeModal(
        initialStartDate: _customStartDate,
        initialEndDate: _customEndDate,
        onResult: (result) {
          // This will be called by the modal before it closes
          if (result != null) {
            setState(() {
              _customStartDate = result['start'];
              _customEndDate = result['end'];
            });
          } else {
            // User cancelled - reset to "Announced" but stay on Bulk RSVP page
            setState(() {
              _selectedTimeframe = 'only_announced';
            });
          }
        },
      ),
    );
  }
  
  void _showDependentManagementModal() async {
    await PhoneModalUtils.showDependentManagementModal(
      context: context,
      availableDependents: _availableDependents,
      selectedDependents: _selectedDependents,
      onDependentsChanged: (selectedDependents) {
        setState(() {
          _selectedDependents.clear();
          _selectedDependents.addAll(selectedDependents);
        });
      },
    );
  }
  
  bool _canApply() {
    return _selectedPracticeIds.isNotEmpty && _selectedRSVPChoice != null;
  }
  
  /// Get practice IDs based on selected practices and timeframe filters
  List<String> _getTargetPracticeIds() {
    // Start with manually selected representative practices
    if (_selectedPracticeIds.isEmpty) {
      return [];
    }
    
    final representativePractices = _getRepresentativePractices();
    final allCalendarPractices = widget.club.upcomingPractices; // All actual instances
    final Set<String> targetPracticeIds = {};
    
    // For each selected representative practice, find matching calendar instances
    for (final selectedId in _selectedPracticeIds) {
      final selectedRepresentative = representativePractices.firstWhere(
        (p) => p.id == selectedId,
        orElse: () => throw Exception('Selected representative practice not found: $selectedId'),
      );
      
      // Find all calendar practices with the same time and location pattern
      final matchingPractices = allCalendarPractices.where((p) {
        return p.dateTime.hour == selectedRepresentative.dateTime.hour &&
               p.dateTime.minute == selectedRepresentative.dateTime.minute &&
               p.location == selectedRepresentative.location &&
               p.dateTime.weekday == selectedRepresentative.dateTime.weekday;
      }).toList();
      
      // Apply timeframe filtering
      List<Practice> timeframePractices = [];
      switch (_selectedTimeframe) {
        case 'only_announced':
          // For testing: announced practices are Sept-Nov
          timeframePractices = matchingPractices.where((p) {
            final month = p.dateTime.month;
            return month >= 9 && month <= 11; // September to November
          }).toList();
          break;
          
        case 'custom':
          // Custom date range
          if (_customStartDate != null && _customEndDate != null) {
            timeframePractices = matchingPractices.where((p) {
              final practiceDate = DateTime(p.dateTime.year, p.dateTime.month, p.dateTime.day);
              final startDate = DateTime(_customStartDate!.year, _customStartDate!.month, _customStartDate!.day);
              final endDate = DateTime(_customEndDate!.year, _customEndDate!.month, _customEndDate!.day);
              return practiceDate.isAtSameMomentAs(startDate) || 
                     practiceDate.isAtSameMomentAs(endDate) ||
                     (practiceDate.isAfter(startDate) && practiceDate.isBefore(endDate));
            }).toList();
          }
          break;
          
        case 'all_future':
          // All future practices from today
          final today = DateTime.now();
          final todayDate = DateTime(today.year, today.month, today.day);
          timeframePractices = matchingPractices.where((p) {
            final practiceDate = DateTime(p.dateTime.year, p.dateTime.month, p.dateTime.day);
            return practiceDate.isAtSameMomentAs(todayDate) || practiceDate.isAfter(todayDate);
          }).toList();
          break;
      }
      
      // Apply future-only filter to timeframe results
      final today = DateTime.now();
      final futurePractices = timeframePractices.where((p) {
        return p.dateTime.isAfter(today);
      }).toList();
      
      // Add the IDs to our target set
      for (final practice in futurePractices) {
        targetPracticeIds.add(practice.id);
      }
    }
    
    return targetPracticeIds.toList();
  }
  
  /// Get text describing how many practices will be affected
  String _getAffectedPracticesText() {
    if (_selectedPracticeIds.isEmpty) {
      return 'Select practices to see affected count';
    }
    
    final targetIds = _getTargetPracticeIds();
    final count = targetIds.length;
    
    if (count == 0) {
      return 'No future practices match the selected timeframe';
    } else if (count == 1) {
      return 'Will apply to 1 practice';
    } else {
      switch (_selectedTimeframe) {
        case 'only_announced':
          return 'Will apply to $count future announced practices';
        case 'custom':
          return 'Will apply to $count future practices in date range';
        case 'all_future':
          return 'Will apply to all future practices';
        default:
          return 'Will apply to $count future practices';
      }
    }
  }
  
  bool _hasUserInput() {
    return _selectedPracticeIds.isNotEmpty || 
           _selectedRSVPChoice != null || 
           _selectedTimeframe != 'only_announced' ||
           _selectedLocations.isNotEmpty ||
           _selectedLevels.isNotEmpty;
  }
  
  void _applyBulkRSVP() async {
    if (!_canApply()) return;
    
    // Show loading state
    setState(() {
      _isLoading = true;
    });
    
    try {
      final participationProvider = Provider.of<ParticipationProvider>(context, listen: false);
      
      // Get practice IDs based on selected timeframe and filters
      final targetPracticeIds = _getTargetPracticeIds();
      
      // Create the bulk participation request
      final request = BulkParticipationRequest(
        practiceIds: targetPracticeIds,
        newStatus: _selectedRSVPChoice!,
        clubId: widget.club.id,
        userId: participationProvider.currentUserId,
        includeDependents: _includeDependents,
        selectedDependents: _selectedDependents,
      );
      
      // If we're including dependents and RSVPing YES, store guest data
      if (_includeDependents && _selectedRSVPChoice == ParticipationStatus.yes && _selectedDependents.isNotEmpty) {
        // Convert dependent names to guest objects for storage
        final guestList = _selectedDependents.map((dependentName) {
          return DependentGuest(
            id: '${DateTime.now().millisecondsSinceEpoch}_${dependentName.hashCode}',
            name: dependentName,
          );
        }).toList();
        
        // Store guest data for all target practices
        for (final practiceId in targetPracticeIds) {
          participationProvider.updatePracticeGuests(practiceId, guestList);
          participationProvider.updateBringGuestState(practiceId, true);
        }
      } else if (!_includeDependents || _selectedRSVPChoice == ParticipationStatus.no) {
        // Clear guest data for all target practices if not including dependents or RSVPing NO
        for (final practiceId in targetPracticeIds) {
          participationProvider.updatePracticeGuests(practiceId, []);
          participationProvider.updateBringGuestState(practiceId, false);
        }
      }
      
      // Execute the bulk update through participation provider
      // Note: We'll simulate the bulk operation since ParticipationProvider may not have bulkUpdateRSVP
      for (final practiceId in targetPracticeIds) {
        await participationProvider.updateParticipationStatus(widget.club.id, practiceId, _selectedRSVPChoice!);
      }
      
      // Show success result to user
      if (mounted) {
        final successCount = targetPracticeIds.length;
        String message = '$successCount practices updated to ${_selectedRSVPChoice!.displayText}';
        
        // If we included dependents, add dependent count to message
        if (_includeDependents && _selectedDependents.isNotEmpty) {
          final dependentCount = _selectedDependents.length;
          final dependentText = dependentCount == 1 ? '1 dependent' : '$dependentCount dependents';
          message = '$message + $dependentText';
        }
        
        _showCustomToast(
          message,
          AppColors.success, // Green for success
          Icons.check,
        );
        
        // Reset the form after successful operation but keep window open
        setState(() {
          _selectedPracticeIds.clear();
          _selectedRSVPChoice = null;
          _selectedTimeframe = 'only_announced';
          _customStartDate = null;
          _customEndDate = null;
          _selectedDependents = ['None selected']; // Reset to "None selected" state
          _includeDependents = false; // Reset include dependents checkbox
          _selectedLocations.clear(); // Clear location filter
          _selectedLevels.clear(); // Clear level filter
        });
      }
    } catch (error) {
      if (mounted) {
        _showErrorDialog('Failed to update RSVPs: ${error.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _showCustomToast(String message, Color color, IconData icon) {
    setState(() {
      _toastMessage = message;
      _toastColor = color;
      _toastIcon = icon;
      _showToast = true;
    });
    
    // Hide toast after 4 seconds
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showToast = false;
        });
      }
    });
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  // Helper methods
  String _formatShortDay(DateTime dateTime) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[dateTime.weekday - 1];
  }
  
  String _formatTimeRange(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'pm' : 'am';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    
    // For now, assuming practices are 1.25 hours long
    final endTime = dateTime.add(const Duration(hours: 1, minutes: 15));
    final endHour = endTime.hour;
    final endMinute = endTime.minute;
    final endPeriod = endHour >= 12 ? 'pm' : 'am';
    final endDisplayHour = endHour > 12 ? endHour - 12 : (endHour == 0 ? 12 : endHour);
    final endMinuteStr = endMinute.toString().padLeft(2, '0');
    
    // Show period for both times if they're different, otherwise just the end
    if (period == endPeriod) {
      return '$displayHour:$minuteStr–$endDisplayHour:$endMinuteStr $endPeriod';
    } else {
      return '$displayHour:$minuteStr $period–$endDisplayHour:$endMinuteStr $endPeriod';
    }
  }
  
  String _truncateLevel(String level) {
    if (level.isEmpty) return '';
    
    // Special mappings for common levels to fit in 4 characters
    switch (level.toLowerCase()) {
      case 'high-level':
      case 'high level':
        return 'HIGH';
      case 'intermediate':
        return 'INT';
      case 'beginner':
        return 'BEG';
      case 'advanced':
        return 'ADV';
      case 'open':
        return 'OPEN';
      default:
        // Truncate to 4 characters and uppercase
        return level.toUpperCase().substring(0, level.length > 4 ? 4 : level.length);
    }
  }
  
  /// Build practice description with truncation (similar to club card)
  Widget _buildPracticeDescription(Practice practice) {
    final isDescriptionExpanded = _expandedDescriptions[practice.id] ?? false;
    final shouldTruncateDescription = _shouldTruncateDescription(practice.description);
    
    return Padding(
      padding: const EdgeInsets.only(left: 46, top: 4, right: 16, bottom: 4), // Align with text above (checkbox + spacing)
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              shouldTruncateDescription && !isDescriptionExpanded
                  ? _getTruncatedDescription(practice.description)
                  : practice.description,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          if (shouldTruncateDescription)
            GestureDetector(
              onTap: () {
                setState(() {
                  _expandedDescriptions[practice.id] = !isDescriptionExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  isDescriptionExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Determines if a description should be truncated based on visual length
  bool _shouldTruncateDescription(String description) {
    // Estimate if description would wrap to second line
    // Rough estimate: more than 40 characters likely to wrap
    return description.length > 40;
  }

  /// Returns truncated description with ellipsis
  String _getTruncatedDescription(String description) {
    if (description.length <= 40) return description;
    
    // Find a good break point (prefer word boundaries)
    String truncated = description.substring(0, 37);
    int lastSpace = truncated.lastIndexOf(' ');
    
    // If we can break at a word boundary and it's not too short, do so
    if (lastSpace > 25) {
      truncated = truncated.substring(0, lastSpace);
    }
    
    return '$truncated...';
  }
}

/// Custom Date Range Modal
class _CustomDateRangeModal extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(Map<String, DateTime>?)? onResult;
  
  const _CustomDateRangeModal({
    this.initialStartDate,
    this.initialEndDate,
    this.onResult,
  });
  
  @override
  State<_CustomDateRangeModal> createState() => _CustomDateRangeModalState();
}

class _CustomDateRangeModalState extends State<_CustomDateRangeModal> {
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  DateTime? _startDate;
  DateTime? _endDate;
  
  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate ?? DateTime.now();
    _endDate = widget.initialEndDate ?? DateTime.now().add(const Duration(days: 7));
    
    _startDateController = TextEditingController(text: _formatDateForInput(_startDate!));
    _endDateController = TextEditingController(text: _formatDateForInput(_endDate!));
  }
  
  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
  
  String _formatDateForInput(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }
  
  DateTime? _parseDate(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final month = int.parse(parts[0]);
        final day = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      // Invalid date format
    }
    return null;
  }
  
  Future<void> _pickDate(bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final pickedDate = await PhoneModalUtils.showPhoneFrameModal<DateTime>(
      context: context,
      child: _CustomDatePickerModal(
        initialDate: initialDate ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        title: isStart ? 'Select Start Date' : 'Select End Date',
      ),
    );
    
    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _startDate = pickedDate;
          _startDateController.text = _formatDateForInput(pickedDate);
        } else {
          _endDate = pickedDate;
          _endDateController.text = _formatDateForInput(pickedDate);
        }
      });
    }
  }
  
  void _validateAndSubmit() {
    // Parse dates from text fields if they were manually edited
    final startFromText = _parseDate(_startDateController.text);
    final endFromText = _parseDate(_endDateController.text);
    
    final finalStartDate = startFromText ?? _startDate;
    final finalEndDate = endFromText ?? _endDate;
    
    if (finalStartDate == null || finalEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid dates')),
      );
      return;
    }
    
    if (finalStartDate.isAfter(finalEndDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start date must be before end date')),
      );
      return;
    }
    
    // Submit with result
    if (widget.onResult != null) {
      widget.onResult!({
        'start': finalStartDate,
        'end': finalEndDate,
      });
    }
    PhoneFrameModal.close();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and close button
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Select Date Range',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (widget.onResult != null) {
                    widget.onResult!(null); // Cancel with no result
                  }
                  PhoneFrameModal.close();
                },
                icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Content area with scrolling
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Start Date
                  const Text(
                    'Start Date',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _startDateController,
                          decoration: InputDecoration(
                            hintText: 'MM/DD/YYYY',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF0284C7)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          onChanged: (value) {
                            final parsed = _parseDate(value);
                            if (parsed != null) {
                              _startDate = parsed;
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _pickDate(true),
                        icon: const Icon(Icons.calendar_today, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // End Date
                  const Text(
                    'End Date',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _endDateController,
                          decoration: InputDecoration(
                            hintText: 'MM/DD/YYYY',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF0284C7)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          onChanged: (value) {
                            final parsed = _parseDate(value);
                            if (parsed != null) {
                              _endDate = parsed;
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _pickDate(false),
                        icon: const Icon(Icons.calendar_today, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    if (widget.onResult != null) {
                      widget.onResult!(null); // Cancel with no result
                    }
                    PhoneFrameModal.close();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _validateAndSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationSelectionModal extends StatefulWidget {
  final List<String> availableLocations;
  final Set<String> selectedLocations;
  final Function(Set<String>) onSelectionChanged;

  const _LocationSelectionModal({
    required this.availableLocations,
    required this.selectedLocations,
    required this.onSelectionChanged,
  });

  @override
  State<_LocationSelectionModal> createState() => _LocationSelectionModalState();
}

class _LocationSelectionModalState extends State<_LocationSelectionModal> {
  late Set<String> _tempSelection;

  @override
  void initState() {
    super.initState();
    _tempSelection = Set<String>.from(widget.selectedLocations);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Select Locations',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => PhoneFrameModal.close(),
                icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _tempSelection.clear();
                  });
                },
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _tempSelection.addAll(widget.availableLocations);
                  });
                },
                child: const Text(
                  'Select All',
                  style: TextStyle(color: Color(0xFF0284C7)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: widget.availableLocations.length,
              itemBuilder: (context, index) {
                final location = widget.availableLocations[index];
                final isSelected = _tempSelection.contains(location);
                
                return CheckboxListTile(
                  title: Text(
                    location,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF374151),
                    ),
                  ),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _tempSelection.add(location);
                      } else {
                        _tempSelection.remove(location);
                      }
                    });
                  },
                  activeColor: const Color(0xFF0284C7),
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => PhoneFrameModal.close(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSelectionChanged(_tempSelection);
                    PhoneFrameModal.close();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelSelectionModal extends StatefulWidget {
  final List<String> availableLevels;
  final Set<String> selectedLevels;
  final Function(Set<String>) onSelectionChanged;

  const _LevelSelectionModal({
    required this.availableLevels,
    required this.selectedLevels,
    required this.onSelectionChanged,
  });

  @override
  State<_LevelSelectionModal> createState() => _LevelSelectionModalState();
}

class _LevelSelectionModalState extends State<_LevelSelectionModal> {
  late Set<String> _tempSelection;

  @override
  void initState() {
    super.initState();
    _tempSelection = Set<String>.from(widget.selectedLevels);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Select Levels',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => PhoneFrameModal.close(),
                icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _tempSelection.clear();
                  });
                },
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _tempSelection.addAll(widget.availableLevels);
                  });
                },
                child: const Text(
                  'Select All',
                  style: TextStyle(color: Color(0xFF0284C7)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: widget.availableLevels.length,
              itemBuilder: (context, index) {
                final level = widget.availableLevels[index];
                final isSelected = _tempSelection.contains(level);
                
                return CheckboxListTile(
                  title: Text(
                    level,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF374151),
                    ),
                  ),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _tempSelection.add(level);
                      } else {
                        _tempSelection.remove(level);
                      }
                    });
                  },
                  activeColor: const Color(0xFF0284C7),
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => PhoneFrameModal.close(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSelectionChanged(_tempSelection);
                    PhoneFrameModal.close();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom Date Picker Modal that respects phone frame boundaries
class _CustomDatePickerModal extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String title;
  
  const _CustomDatePickerModal({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.title,
  });
  
  @override
  State<_CustomDatePickerModal> createState() => _CustomDatePickerModalState();
}

class _CustomDatePickerModalState extends State<_CustomDatePickerModal> {
  late DateTime _selectedDate;
  
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          
          // Calendar
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
            ),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(_selectedDate),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
