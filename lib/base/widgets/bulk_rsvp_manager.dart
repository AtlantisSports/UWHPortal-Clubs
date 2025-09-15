/// Bulk RSVP Manager Widget
/// Comprehensive bulk RSVP interface with filtering and selection capabilities
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/practice.dart';
import '../../core/models/club.dart';
import '../../core/providers/rsvp_provider.dart';

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
  Set<int> _selectedDaysOfWeek = <int>{};
  String? _selectedLocation;
  
  // Selection state
  final Set<String> _selectedPracticeIds = <String>{};
  
  // New RSVP interface state
  RSVPStatus? _selectedRSVPChoice; // YES or NO selection
  String _selectedTimeframe = 'only_announced'; // 'only_announced', 'custom', 'all_future'
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  
  // Available options (populated from data)
  List<String> _availableLocations = [];
  
  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }
  
  void _initializeFilters() {
    // Initialize available locations from club practices
    _updateAvailableLocations();
  }
  
  void _updateAvailableLocations() {
    final clubPractices = _getClubPractices();
    final locations = clubPractices.map((p) => p.location).toSet().toList();
    locations.sort();
    
    setState(() {
      _availableLocations = locations;
    });
  }
  
  List<Practice> _getClubPractices() {
    return widget.club.upcomingPractices
        .where((practice) => practice.isUpcoming)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }
  
  List<Practice> _getFilteredPractices() {
    var practices = _getClubPractices();
    
    // Apply day of week filter
    if (_selectedDaysOfWeek.isNotEmpty) {
      practices = practices.where((p) {
        return _selectedDaysOfWeek.contains(p.dateTime.weekday);
      }).toList();
    }
    
    // Apply location filter
    if (_selectedLocation != null && _selectedLocation!.isNotEmpty) {
      practices = practices.where((p) => p.location == _selectedLocation).toList();
    }
    
    return practices;
  }
  
  @override
  Widget build(BuildContext context) {
    final filteredPractices = _getFilteredPractices();
    
    return Container(
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
            
            // Bottom Action Bar
            _buildBottomActionBar(filteredPractices),
          ],
        ),
      ),
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
          // Day of Week & Location Row
          Row(
            children: [
              Expanded(
                child: _buildDayOfWeekFilter(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLocationFilter(),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
        ],
      ),
    );
  }
  
  Widget _buildDayOfWeekFilter() {
    return GestureDetector(
      onTap: _showDayOfWeekPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Icon(Icons.today, size: 16, color: Color(0xFF6B7280)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getDayOfWeekText(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }
  
  String _getDayOfWeekText() {
    if (_selectedDaysOfWeek.isEmpty) return 'Any day';
    if (_selectedDaysOfWeek.length == 7) return 'All days';
    if (_selectedDaysOfWeek.length == 1) {
      return _getDayName(_selectedDaysOfWeek.first);
    }
    return '${_selectedDaysOfWeek.length} days selected';
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
  
  Widget _buildLocationFilter() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedLocation,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.location_on, size: 16, color: Color(0xFF6B7280)),
        hintText: 'Any location',
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Any location', style: TextStyle(fontSize: 14)),
        ),
        ..._availableLocations.map((location) => DropdownMenuItem<String>(
          value: location,
          child: Text(location, style: const TextStyle(fontSize: 14)),
        )),
      ],
      onChanged: (value) {
        setState(() {
          _selectedLocation = value;
        });
      },
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
    
    return Consumer<RSVPProvider>(
      builder: (context, rsvpProvider, child) {
        return _buildConsolidatedPracticeSelector(filteredPractices, rsvpProvider);
      },
    );
  }
  
  Widget _buildConsolidatedPracticeSelector(List<Practice> filteredPractices, RSVPProvider rsvpProvider) {
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
                child: Row(
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
                  ],
                ),
              ),
            );
          }),
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
                        status: RSVPStatus.yes,
                        isSelected: _selectedRSVPChoice == RSVPStatus.yes,
                        onTap: () {
                          setState(() {
                            _selectedRSVPChoice = RSVPStatus.yes;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildPracticeRSVPButton(
                        status: RSVPStatus.no,
                        isSelected: _selectedRSVPChoice == RSVPStatus.no,
                        onTap: () {
                          setState(() {
                            _selectedRSVPChoice = RSVPStatus.no;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
                  onPressed: _canApply() ? _applyBulkRSVP : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canApply() ? const Color(0xFF0284C7) : const Color(0xFFE5E7EB),
                    foregroundColor: _canApply() ? Colors.white : const Color(0xFF9CA3AF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text(
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
    required RSVPStatus status,
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
              size: status == RSVPStatus.maybe ? 20.8 : 25.7,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
  
  Color _getFadedBackground(RSVPStatus status) {
    switch (status) {
      case RSVPStatus.yes:
        return const Color(0xFFECFDF5);
      case RSVPStatus.maybe:
        return const Color(0xFFFFFBEB);
      case RSVPStatus.no:
        return const Color(0xFFFEF2F2);
      case RSVPStatus.pending:
        return const Color(0xFFF3F4F6);
    }
  }
  
  IconData _getOverlayIcon(RSVPStatus status) {
    switch (status) {
      case RSVPStatus.yes:
        return Icons.check;
      case RSVPStatus.maybe:
        return Icons.question_mark;
      case RSVPStatus.no:
        return Icons.close;
      case RSVPStatus.pending:
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
            Radio<String>(
              value: value,
              groupValue: _selectedTimeframe,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTimeframe = newValue!;
                });
                
                if (newValue == 'custom') {
                  // Show date picker immediately when custom is selected
                  _showCustomDatePicker();
                }
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
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
    final result = await showDialog<Map<String, DateTime>>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (BuildContext context) {
        return _CustomDateRangeModal(
          initialStartDate: _customStartDate,
          initialEndDate: _customEndDate,
        );
      },
    );
    
    if (result != null) {
      setState(() {
        _customStartDate = result['start'];
        _customEndDate = result['end'];
      });
    } else {
      // User cancelled - reset to "Announced"
      setState(() {
        _selectedTimeframe = 'only_announced';
      });
    }
  }
  
  bool _canApply() {
    return _selectedPracticeIds.isNotEmpty && _selectedRSVPChoice != null;
  }
  
  bool _hasUserInput() {
    return _selectedPracticeIds.isNotEmpty || 
           _selectedRSVPChoice != null || 
           _selectedTimeframe != 'only_announced' ||
           _selectedDaysOfWeek.isNotEmpty ||
           _selectedLocation != null;
  }
  
  void _applyBulkRSVP() {
    // Implementation for applying bulk RSVP
    // This would normally interact with the RSVPProvider
    print('Applying bulk RSVP: ${_selectedRSVPChoice?.name} for ${_selectedPracticeIds.length} practices');
    print('Timeframe: $_selectedTimeframe');
    if (_selectedTimeframe == 'custom') {
      print('Custom range: $_customStartDate to $_customEndDate');
    }
    
    // Reset after applying
    setState(() {
      _selectedPracticeIds.clear();
      _selectedRSVPChoice = null;
      _selectedTimeframe = 'only_announced';
      _customStartDate = null;
      _customEndDate = null;
    });
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
    
    return '$displayHour:$minuteStr–$endDisplayHour:$endMinuteStr $endPeriod';
  }
  
  void _showDayOfWeekPicker() {
    showDialog(
      context: context,
      builder: (context) {
        final tempSelection = Set<int>.from(_selectedDaysOfWeek);
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Days of Week'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int day = DateTime.monday; day <= DateTime.sunday; day++)
                    CheckboxListTile(
                      title: Text(_getDayName(day)),
                      value: tempSelection.contains(day),
                      onChanged: (value) {
                        setDialogState(() {
                          if (value == true) {
                            tempSelection.add(day);
                          } else {
                            tempSelection.remove(day);
                          }
                        });
                      },
                      activeColor: const Color(0xFF0284C7),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedDaysOfWeek = tempSelection;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Custom Date Range Modal
class _CustomDateRangeModal extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  
  const _CustomDateRangeModal({
    this.initialStartDate,
    this.initialEndDate,
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
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
    
    Navigator.of(context).pop({
      'start': finalStartDate,
      'end': finalEndDate,
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Select Date Range',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 24),
            
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
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
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
                    onPressed: _validateAndSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Submit',
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
      ),
    );
  }
}
