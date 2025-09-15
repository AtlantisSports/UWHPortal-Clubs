/// Comprehensive Bulk RSVP Manager Screen
/// Full-page interface for managing multiple practice RSVPs with advanced filtering
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/practice.dart';
import '../../core/models/club.dart';
import '../../core/providers/rsvp_provider.dart';

/// Comprehensive bulk RSVP manager with advanced filtering and selection
class BulkRSVPManagerScreen extends StatefulWidget {
  final Club club;
  
  const BulkRSVPManagerScreen({
    super.key,
    required this.club,
  });
  
  @override
  State<BulkRSVPManagerScreen> createState() => _BulkRSVPManagerScreenState();
}

class _BulkRSVPManagerScreenState extends State<BulkRSVPManagerScreen> {
  // Filter state
  DateTime? _startDate;
  DateTime? _endDate;
  Set<int> _selectedDaysOfWeek = <int>{};
  String? _selectedLocation;
  
  // Selection state
  final Set<String> _selectedPracticeIds = <String>{};
  RSVPStatus? _selectedRSVPStatus;
  
  // UI state
  bool _isLoading = false;
  bool _showingConfirmation = false;
  
  // Available options (populated from data)
  List<String> _availableLocations = [];
  
  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }
  
  void _initializeFilters() {
    // Set default date range to next 30 days
    final now = DateTime.now();
    _startDate = now;
    _endDate = now.add(const Duration(days: 30));
    
    // Initialize available options based on club's practices
    _updateAvailableOptions();
  }
  
  void _updateAvailableOptions() {
    final practices = _getClubPractices();
    
    // Extract unique locations
    _availableLocations = practices
        .map((p) => p.location)
        .toSet()
        .toList()
      ..sort();
    
    setState(() {});
  }
  
  List<Practice> _getClubPractices() {
    return widget.club.upcomingPractices
        .where((practice) => practice.isUpcoming)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }
  
  List<Practice> _getFilteredPractices() {
    var practices = _getClubPractices();
    
    // Apply date range filter
    if (_startDate != null && _endDate != null) {
      practices = practices.where((p) {
        return p.dateTime.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
               p.dateTime.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }
    
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
    
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 393, // Galaxy S23 width - match phone frame
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bulk RSVP Manager',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE5E7EB),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Section
          _buildFilterSection(),
          
          // Practice Count & Controls
          _buildHeaderControls(filteredPractices),
          
          // Practice List
          Expanded(
            child: _buildPracticeList(filteredPractices),
          ),
          
          // Bottom Action Bar
          if (_selectedPracticeIds.isNotEmpty || _showingConfirmation)
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
          const Text(
            'Filter Practices',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          
          // Date Range Row
          Row(
            children: [
              Expanded(
                child: _buildDateRangePicker(),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
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
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildDateRangePicker() {
    return GestureDetector(
      onTap: _showDateRangePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range, size: 16, color: Color(0xFF6B7280)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getDateRangeText(),
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
  
  String _getDateRangeText() {
    if (_startDate == null || _endDate == null) return 'Select date range';
    
    final start = '${_startDate!.month}/${_startDate!.day}';
    final end = '${_endDate!.month}/${_endDate!.day}';
    return '$start - $end';
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
  
  Widget _buildHeaderControls(List<Practice> filteredPractices) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Select All Checkbox
          Checkbox(
            value: _selectedPracticeIds.isNotEmpty && 
                   _selectedPracticeIds.length == filteredPractices.length,
            tristate: true,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedPracticeIds.addAll(filteredPractices.map((p) => p.id));
                } else {
                  _selectedPracticeIds.clear();
                }
              });
            },
            activeColor: const Color(0xFF0284C7),
          ),
          const Text(
            'Select All',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          
          const Spacer(),
          
          // Practice count
          Text(
            '${filteredPractices.length} practices',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Clear selection button
          if (_selectedPracticeIds.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedPracticeIds.clear();
                });
              },
              child: const Text(
                'Clear All',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
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
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: filteredPractices.length,
          itemBuilder: (context, index) {
            final practice = filteredPractices[index];
            final isSelected = _selectedPracticeIds.contains(practice.id);
            final currentRSVP = rsvpProvider.getRSVPStatus(practice.id);
            
            return _buildPracticeListItem(practice, isSelected, currentRSVP);
          },
        );
      },
    );
  }
  
  Widget _buildPracticeListItem(Practice practice, bool isSelected, RSVPStatus currentRSVP) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFE5E7EB),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
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
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatPracticeDate(practice.dateTime),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Color(0xFF6B7280)),
                      const SizedBox(width: 4),
                      Text(
                        _formatPracticeTime(practice.dateTime),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on, size: 14, color: Color(0xFF6B7280)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          practice.location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Current RSVP Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: currentRSVP.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: currentRSVP.color.withValues(alpha: 0.3)),
              ),
              child: Text(
                currentRSVP.displayText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: currentRSVP.color,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          setState(() {
            if (_selectedPracticeIds.contains(practice.id)) {
              _selectedPracticeIds.remove(practice.id);
            } else {
              _selectedPracticeIds.add(practice.id);
            }
          });
        },
      ),
    );
  }
  
  Widget _buildBottomActionBar(List<Practice> filteredPractices) {
    if (_showingConfirmation) {
      return _buildConfirmationPanel(filteredPractices);
    }
    
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
          // Selection summary
          Row(
            children: [
              const Icon(Icons.checklist, size: 20, color: Color(0xFF0284C7)),
              const SizedBox(width: 8),
              Text(
                '${_selectedPracticeIds.length} practices selected',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // RSVP Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildRSVPActionButton(
                  RSVPStatus.yes,
                  'Yes',
                  Icons.check,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRSVPActionButton(
                  RSVPStatus.maybe,
                  'Maybe',
                  Icons.question_mark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRSVPActionButton(
                  RSVPStatus.no,
                  'No',
                  Icons.close,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRSVPActionButton(
                  RSVPStatus.pending,
                  'Clear',
                  Icons.clear,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildRSVPActionButton(RSVPStatus status, String label, IconData icon) {
    return ElevatedButton(
      onPressed: () => _selectRSVPStatus(status),
      style: ElevatedButton.styleFrom(
        backgroundColor: status.color.withValues(alpha: 0.1),
        foregroundColor: status.color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: status.color.withValues(alpha: 0.3)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConfirmationPanel(List<Practice> filteredPractices) {
    final selectedPractices = filteredPractices
        .where((p) => _selectedPracticeIds.contains(p.id))
        .toList();
    
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedRSVPStatus!.color.withValues(alpha: 0.1),
                  border: Border.all(color: _selectedRSVPStatus!.color, width: 2),
                ),
                child: Icon(
                  _selectedRSVPStatus!.overlayIcon,
                  size: 20,
                  color: _selectedRSVPStatus!.color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Confirm Bulk RSVP',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      'Change to "${_selectedRSVPStatus!.displayText}"',
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedRSVPStatus!.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Practice list preview
          Text(
            'Practices to update (${selectedPractices.length}):',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Show first few practices
          Container(
            constraints: const BoxConstraints(maxHeight: 120),
            child: SingleChildScrollView(
              child: Column(
                children: selectedPractices.take(5).map((practice) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Text('•', style: TextStyle(color: Color(0xFF6B7280))),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_formatPracticeDate(practice.dateTime)} - ${_formatPracticeTime(practice.dateTime)} at ${practice.location}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          if (selectedPractices.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '...and ${selectedPractices.length - 5} more',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          
          const SizedBox(height: 20),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _showingConfirmation = false;
                      _selectedRSVPStatus = null;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _executeBulkRSVP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedRSVPStatus!.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Apply Changes'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Helper methods
  String _formatPracticeDate(DateTime dateTime) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    return '${weekdays[dateTime.weekday - 1]}, ${months[dateTime.month - 1]} ${dateTime.day}';
  }
  
  String _formatPracticeTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    
    return '$displayHour:$minuteStr $period';
  }
  
  // Action handlers
  void _showDateRangePicker() async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: _startDate ?? DateTime.now(),
        end: _endDate ?? DateTime.now().add(const Duration(days: 30)),
      ),
    );
    
    if (result != null) {
      setState(() {
        _startDate = result.start;
        _endDate = result.end;
      });
    }
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
  
  void _selectRSVPStatus(RSVPStatus status) {
    setState(() {
      _selectedRSVPStatus = status;
      _showingConfirmation = true;
    });
  }
  
  void _executeBulkRSVP() async {
    if (_selectedRSVPStatus == null || _selectedPracticeIds.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final rsvpProvider = context.read<RSVPProvider>();
      
      // Create bulk RSVP request
      final request = BulkRSVPRequest(
        practiceIds: _selectedPracticeIds.toList(),
        newStatus: _selectedRSVPStatus!,
        clubId: widget.club.id,
        userId: rsvpProvider.currentUserId,
      );
      
      // Execute bulk update
      final result = await rsvpProvider.bulkUpdateRSVP(request);
      
      if (mounted) {
        // Show result dialog
        _showResultDialog(result);
        
        // Reset state on success
        if (result.isFullSuccess || result.isPartialSuccess) {
          setState(() {
            _selectedPracticeIds.clear();
            _showingConfirmation = false;
            _selectedRSVPStatus = null;
          });
        }
      }
      
    } catch (error) {
      if (mounted) {
        _showErrorDialog('Failed to update RSVP statuses: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _showResultDialog(BulkRSVPResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          result.isFullSuccess
              ? 'Success!'
              : result.isPartialSuccess
                  ? 'Partially Complete'
                  : 'Failed',
          style: TextStyle(
            color: result.isFullSuccess
                ? const Color(0xFF10B981)
                : result.isPartialSuccess
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFFEF4444),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.summaryText),
            if (result.failedIds.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Failed practices:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              ...result.failedIds.map((id) => Text(
                '• ${result.errors[id] ?? 'Unknown error'}',
                style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444)),
              )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Error',
          style: TextStyle(color: Color(0xFFEF4444)),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
