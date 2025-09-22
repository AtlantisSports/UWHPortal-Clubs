/// Bulk RSVP Manager Widget
/// Comprehensive bulk RSVP interface with filtering and selection capabilities
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/practice.dart';
import '../../core/models/practice_pattern.dart';
import '../../core/models/practice_recurrence.dart';
import '../../core/models/club.dart';
import '../../core/models/guest.dart';
import '../../core/constants/dependent_constants.dart';
import '../../core/services/schedule_service.dart';
import '../../core/di/service_locator.dart';
import '../../core/utils/time_utils.dart';
import '../../core/utils/practice_data_consistency.dart';
import 'dropdown_utils.dart';
import 'phone_modal_utils.dart';
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
  final ScheduleService _scheduleService = ServiceLocator.scheduleService;
  
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
    _verifyPracticeDataConsistency();
  }
  
  void _verifyPracticeDataConsistency() {
    final recurringPractices = _getRepresentativePractices();
    
    // Log practice lists for debugging
    PracticeDataConsistencyVerifier.logPracticeList(
      recurringPractices, 
      'Bulk RSVP Representative Practices'
    );
    
    // Verify each practice has valid pattern ID
    for (final practice in recurringPractices) {
      if (!PracticeDataConsistencyVerifier.hasValidPatternId(practice)) {
        debugPrint('WARNING: Invalid pattern ID for practice: ${practice.title} (${practice.id})');
      }
    }
    
    debugPrint('Bulk RSVP initialized with ${recurringPractices.length} practice patterns');
  }
  
  void _initializeFilters() {
    // Initialize available locations and levels from club practices
    _updateAvailableLocations();
    _updateAvailableLevels();
  }
  
  void _initializeRSVPProvider() {
    // Initialize participation provider with current club practices
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    // Use practice patterns instead of recurring practices to avoid date issues
    final practicePatterns = _scheduleService.getPracticePatterns(widget.club.id);
    
    // Convert practice patterns to Practice objects for bulk RSVP display
    // Generate representative practice instances for the current week
    return practicePatterns.map((pattern) {
      // Generate a practice instance for display purposes only
      final nextOccurrenceDate = _getNextOccurrenceDate(pattern);
      final practiceData = pattern.generatePracticeData(nextOccurrenceDate);
      
      // Convert the Map to a Practice object
      return Practice(
        id: practiceData['id'] as String,
        clubId: practiceData['clubId'] as String,
        patternId: pattern.id, // Link to the practice pattern
        title: practiceData['title'] as String,
        description: practiceData['description'] as String,
        dateTime: DateTime.parse(practiceData['dateTime'] as String),
        location: practiceData['location'] as String,
        address: practiceData['address'] as String,
        tag: practiceData['tag'] as String?,
        duration: Duration(minutes: practiceData['duration'] as int),
      );
    }).toList()
      ..sort((a, b) {
        // Sort by weekday, then by time
        final dayComparison = a.dateTime.weekday.compareTo(b.dateTime.weekday);
        if (dayComparison != 0) return dayComparison;
        return a.dateTime.hour.compareTo(b.dateTime.hour);
      });
  }
  
  /// Get the next occurrence date for a practice pattern
  DateTime _getNextOccurrenceDate(PracticePattern pattern) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Find the next occurrence of this pattern
    for (int i = 0; i < 14; i++) { // Look ahead 2 weeks
      final testDate = today.add(Duration(days: i));
      if (pattern.shouldGeneratePracticeOn(testDate)) {
        return DateTime(
          testDate.year,
          testDate.month,
          testDate.day,
          pattern.startTime.hour,
          pattern.startTime.minute,
        );
      }
    }
    
    // Fallback: just use a date with the correct weekday
    final targetWeekday = pattern.day.weekdayNumber;
    final daysToAdd = (targetWeekday - now.weekday) % 7;
    final targetDate = now.add(Duration(days: daysToAdd));
    return DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      pattern.startTime.hour,
      pattern.startTime.minute,
    );
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

  /// Show confirmation dialog for clearing all future RSVPs
  Future<void> _showClearFutureRSVPsConfirmation() async {
    final confirmed = await PhoneModalUtils.showPhoneConfirmationDialog(
      context: context,
      title: 'Clear All Future RSVPs',
      message: 'This will clear ALL of your RSVPs!\n\nAny New Player guests or Dependents associated with your RSVPs will also be cleared.\n\nVisitors and Club Members you have previously added as your guest will keep their RSVPs.\n\nThis action cannot be undone.',
      confirmText: 'Clear RSVPs',
      cancelText: 'Cancel',
      isDestructive: true,
    );
    
    if (confirmed) {
      await _clearAllFutureRSVPs();
    }
  }

  /// Clear all future RSVPs for user, new player guests, and dependents
  Future<void> _clearAllFutureRSVPs() async {
    setState(() => _isLoading = true);
    
    try {
      final participationProvider = Provider.of<ParticipationProvider>(context, listen: false);
      final today = DateTime.now();
      
      // Get all club practices from today forward
      final allPractices = _getClubPractices();
      final futurePractices = allPractices.where((practice) {
        return practice.dateTime.isAfter(today) || 
               practice.dateTime.day == today.day;
      }).toList();
      
      // Clear RSVPs for each future practice
      for (final practice in futurePractices) {
        // Clear user's own RSVP
        await participationProvider.updateParticipationStatus(
          widget.club.id, 
          practice.id, 
          ParticipationStatus.blank
        );
        
        // Clear new player guests and dependents (preserve known Visitors/Club members)
        final currentGuests = participationProvider.getPracticeGuests(practice.id);
        final filteredGuests = currentGuests.guests.where((guest) {
          // Keep guests that are known Visitors or Club members
          // Remove new player guests and dependents
          return guest.type == GuestType.visitor || guest.type == GuestType.clubMember;
        }).toList();
        
        participationProvider.updatePracticeGuests(practice.id, filteredGuests);
      }
      
      _showCustomToast(
        'All future RSVPs cleared successfully',
        Colors.green,
        Icons.check_circle,
      );
      
    } catch (error) {
      _showCustomToast(
        'Failed to clear RSVPs. Please try again.',
        Colors.red,
        Icons.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
          // Clear all future RSVPs button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _showClearFutureRSVPsConfirmation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLoading) ...[
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ] else ...[
                    const Icon(Icons.event_busy, size: 18),
                    const SizedBox(width: 8),
                  ],
                  const Text(
                    'Clear all future RSVPs',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Dynamic filter row based on available options
          _buildDynamicFilterRow(),
          
          const SizedBox(height: 4),
        ],
      ),
    );
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
    // Get practice patterns for recurrence information
    final practicePatterns = _scheduleService.getPracticePatterns(widget.club.id);
    final patternMap = {for (var pattern in practicePatterns) pattern.id: pattern};
    
    // Separate weekly and non-weekly practices
    final weeklyPractices = <Practice>[];
    final nonWeeklyPractices = <Practice>[];
    
    for (final practice in filteredPractices) {
      final pattern = patternMap[practice.patternId ?? practice.id];
      final isWeekly = pattern?.recurrence.type == RecurrenceType.weekly && 
                      pattern?.recurrence.interval == 1;
      
      if (isWeekly) {
        weeklyPractices.add(practice);
      } else {
        nonWeeklyPractices.add(practice);
      }
    }
    
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
              // Weekly title
              if (weeklyPractices.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Weekly',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
              
              // Weekly practices
              ...weeklyPractices.map((practice) => _buildWeeklyPracticeItem(practice, patternMap)),
              
              // Horizontal divider
              if (weeklyPractices.isNotEmpty && nonWeeklyPractices.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(
                    color: Color(0xFFE5E7EB),
                    thickness: 1,
                  ),
                ),
              ],
              
              // Non-weekly practices
              ...nonWeeklyPractices.map((practice) => _buildNonWeeklyPracticeItem(practice, patternMap)),
            ],
          ),
        );
  }

  /// Build a weekly practice item (current format)
  Widget _buildWeeklyPracticeItem(Practice practice, Map<String, PracticePattern> patternMap) {
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
                    '${_getDayNameForPractice(practice)} • ${TimeUtils.formatTimeRangeWithDuration(practice.dateTime, practice.duration)} • ${practice.location}',
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
  }

  /// Build a non-weekly practice item (restructured format)
  Widget _buildNonWeeklyPracticeItem(Practice practice, Map<String, PracticePattern> patternMap) {
    final isSelected = _selectedPracticeIds.contains(practice.id);
    final pattern = patternMap[practice.patternId ?? practice.id];
    
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recurrence note first (pattern description)
                      if (pattern?.recurrence.description != null && pattern!.recurrence.description.isNotEmpty) ...[
                        Text(
                          pattern.recurrence.description,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      // Day/time/location below
                      Text(
                        '${_getDayNameForPractice(practice)} • ${TimeUtils.formatTimeRangeWithDuration(practice.dateTime, practice.duration)} • ${practice.location}',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
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
            color: Colors.black.withValues(alpha: 0.05),
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
                child: GestureDetector(
                  onTap: (_canApply() && !_isLoading) ? null : _showInactiveApplyMessage,
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
          tooltip: 'Only confirmed practices',
        ),
        
        // Custom date range option  
        _buildCustomRadioOption(
          value: 'custom',
          title: (_customStartDate != null && _customEndDate != null) 
              ? _getCustomDateRangeText() 
              : 'Custom',
          tooltip: 'Custom date range',
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
          tooltip: 'All events matching this same criteria even if not Announced yet',
        ),
      ],
    );
  }
  
  Widget _buildCustomRadioOption({
    required String value,
    required String title,
    Widget? trailing,
    String? tooltip,
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
            if (tooltip != null) ...[
              const SizedBox(width: 6),
              _TooltipWidget(
                message: tooltip,
                child: const Icon(
                  Icons.help_outline,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
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
    await PhoneModalUtils.showPhoneFrameModal<Map<String, DateTime>>(
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
  
  bool _canApply() {
    return _selectedPracticeIds.isNotEmpty && _selectedRSVPChoice != null;
  }

  /// Show helpful toast when user clicks inactive Apply button
  void _showInactiveApplyMessage() {
    String message;
    
    if (_selectedPracticeIds.isEmpty && _selectedRSVPChoice == null) {
      message = 'Please select practices and choose YES or NO to apply bulk RSVP';
    } else if (_selectedPracticeIds.isEmpty) {
      message = 'Please select at least one practice to apply bulk RSVP';
    } else if (_selectedRSVPChoice == null) {
      message = 'Please choose YES or NO to apply bulk RSVP';
    } else {
      message = 'Unable to apply bulk RSVP at this time';
    }
    
    _showCustomToast(
      message,
      const Color(0xFF0284C7), // Blue color as requested
      Icons.info_outline,
    );
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
      
      // Find all calendar practices that match this pattern
      // Match by patternId directly - this is the robust identifier
      final matchingPractices = allCalendarPractices.where((p) {
        return p.patternId == selectedRepresentative.patternId;
      }).toList();
      
      // Apply timeframe filtering
      List<Practice> timeframePractices = [];
      switch (_selectedTimeframe) {
        case 'only_announced':
          // Filter for upcoming announced practices only (bounded by mock announced cutoff)
          timeframePractices = matchingPractices.where((p) {
            final now = DateTime.now();
            final cutoff = AppConstants.mockAnnouncedCutoff;
            final dt = p.dateTime;
            return dt.isAfter(now) && (dt.isBefore(cutoff) || dt.isAtSameMomentAs(cutoff));
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
  String _getDayNameForPractice(Practice practice) {
    // For recurring practices, extract day from practice ID - same logic as recurring practices widget
    if (practice.id.startsWith('recurring-')) {
      final dayPrefix = practice.id.substring(10); // Remove 'recurring-'
      switch (dayPrefix) {
        case 'monday':
          return 'Mon';
        case 'tuesday':
          return 'Tue';
        case 'wednesday':
          return 'Wed';
        case 'thursday':
          return 'Thu';
        case 'friday':
          return 'Fri';
        case 'saturday':
          return 'Sat';
        case 'sunday-morning':
        case 'sunday-afternoon':
          return 'Sun';
        default:
          return TimeUtils.formatShortDayName(practice.dateTime.weekday);
      }
    }
    
    // For regular practices, use the actual date
    return TimeUtils.formatShortDayName(practice.dateTime.weekday);
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
    // Use showPhoneModal (Navigator-backed) so inner OK/Cancel only closes the date picker,
    // not the parent Bulk RSVP overlay.
    final pickedDate = await PhoneModalUtils.showPhoneModal<DateTime>(
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
    // Use Flutter's DatePickerDialog for reliable selection visuals (blue filled
    // circle with white text). Embedding it in our navigator-backed modal means
    // only this picker closes on OK/Cancel.
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: AppColors.textPrimary,
        ),
        datePickerTheme: Theme.of(context).datePickerTheme.copyWith(
          dayShape: WidgetStateProperty.all(const CircleBorder()),
          dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) return AppColors.primary; // blue filled circle
            return Colors.transparent;
          }),
          dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) return Colors.white; // white number
            if (states.contains(WidgetState.disabled)) return AppColors.textSecondary;
            return AppColors.textPrimary;
          }),
          todayForegroundColor: WidgetStateProperty.all<Color>(AppColors.primary),
          todayBackgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
          todayBorder: BorderSide.none, // remove today ring
        ),
      ),
      child: DatePickerDialog(
        initialDate: _selectedDate,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        currentDate: DateTime.now(), // keep 'today' state for blue text without ring
        helpText: widget.title,
        confirmText: 'OK',
        cancelText: 'Cancel',
        initialEntryMode: DatePickerEntryMode.calendarOnly,
      ),
    );
  }
}

/// Custom tooltip widget that shows on hover/tap
class _TooltipWidget extends StatefulWidget {
  final String message;
  final Widget child;
  
  const _TooltipWidget({
    required this.message,
    required this.child,
  });
  
  @override
  State<_TooltipWidget> createState() => _TooltipWidgetState();
}

class _TooltipWidgetState extends State<_TooltipWidget> {
  bool _isVisible = false;
  
  void _showTooltip() {
    setState(() {
      _isVisible = true;
    });
    
    // Auto-hide after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }
  
  void _hideTooltip() {
    setState(() {
      _isVisible = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isVisible ? _hideTooltip : _showTooltip,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,
          if (_isVisible)
            Positioned(
              bottom: 25, // Position above the icon
              left: -60, // Center horizontally relative to icon
              child: SizedBox(
                width: 140,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tooltip bubble
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF374151), // Dark gray background
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Arrow pointing down to the icon (moved closer)
                    Transform.translate(
                      offset: const Offset(0, -1), // Move arrow 1px closer to bubble
                      child: CustomPaint(
                        size: const Size(8, 4),
                        painter: _TooltipArrowPainter(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Custom painter for tooltip arrow (pointing down)
class _TooltipArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF374151) // Same dark gray as tooltip
      ..style = PaintingStyle.fill;
    
    final path = Path()
      ..moveTo(size.width / 2, size.height) // Bottom center (tip of arrow)
      ..lineTo(0, 0) // Top left
      ..lineTo(size.width, 0) // Top right
      ..close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
