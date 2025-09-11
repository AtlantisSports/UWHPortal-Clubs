import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/practice.dart';
import '../../core/providers/rsvp_provider.dart';
import '../../features/clubs/clubs_provider.dart';
import '../../base/widgets/phone_modal_utils.dart';
import '../../base/widgets/shared_rsvp_button.dart';

/// Home screen placeholder matching UWH Portal design with bulk RSVP access
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Underwater Hockey'),
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              size: 28.8, // 20% larger than default 24
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to the UWH Portal - Clubs!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'This is a mockup of the clubs section for the UWH Portal.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bulk RSVP Feature',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Try out the bulk RSVP functionality to manage multiple practice RSVPs at once.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _showBulkRSVPModal(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Try Bulk RSVP',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBulkRSVPModal(BuildContext context) async {
    await PhoneModalUtils.showPhoneModal(
      context: context,
      child: const BulkRSVPModal(),
    );
  }
}

class BulkRSVPModal extends StatefulWidget {
  const BulkRSVPModal({super.key});

  @override
  State<BulkRSVPModal> createState() => _BulkRSVPModalState();
}

class _BulkRSVPModalState extends State<BulkRSVPModal> {
  final Set<String> _selectedPracticeIds = {};
  final Set<String> _selectedLocations = {'All locations'};
  final Set<String> _selectedDays = {'All days'};
  RSVPStatus _selectedRSVPStatus = RSVPStatus.yes;
  String _selectedTimeframe = 'Announced';
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  
  final List<String> _locations = ['All locations', 'VMAC', 'Carmody'];
  final List<String> _timeframes = ['Announced', 'Custom', 'All future'];

  List<String> _getAvailableDays() {
    final clubsProvider = Provider.of<ClubsProvider>(context, listen: false);
    List<Practice> practices = [];
    
    // Get all practices from all clubs
    for (final club in clubsProvider.clubs) {
      practices.addAll(club.upcomingPractices.where((p) => p.isUpcoming));
    }
    
    final dayNames = practices.map((p) => _getDayName(p.dateTime.weekday)).toSet().toList();
    dayNames.sort((a, b) {
      const dayOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return dayOrder.indexOf(a).compareTo(dayOrder.indexOf(b));
    });
    
    return ['All days', ...dayNames];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      constraints: const BoxConstraints(maxHeight: 600),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _buildFiltersRow(),
                  const SizedBox(height: 16),
                  _buildPracticesList(),
                  const SizedBox(height: 16),
                  _buildRSVPSelection(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Bulk RSVP - Typical Practices',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.close, size: 24, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersRow() {
    final availableDays = _getAvailableDays();
    return Row(
      children: [
        Expanded(child: _buildMultiSelectDropdown('Location', _locations, _selectedLocations)),
        const SizedBox(width: 12),
        Expanded(child: _buildMultiSelectDropdown('Day', availableDays, _selectedDays)),
      ],
    );
  }

  Widget _buildMultiSelectDropdown(String label, List<String> items, Set<String> selectedItems) {
    String displayText = selectedItems.contains('All ${label.toLowerCase()}s') 
        ? 'All ${label.toLowerCase()}s'
        : selectedItems.length == 1 
            ? selectedItems.first
            : '${selectedItems.length} selected';

    return GestureDetector(
      onTap: () => _showMultiSelectDialog(label, items, selectedItems),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD1D5DB)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayText,
                style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _showMultiSelectDialog(String label, List<String> items, Set<String> selectedItems) async {
    await PhoneModalUtils.showPhoneModal(
      context: context,
      child: Container(
        width: 320,
        constraints: const BoxConstraints(maxHeight: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select ${label}s',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(Icons.close, size: 24, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = selectedItems.contains(item);
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedItems.remove(item);
                              if (selectedItems.isEmpty) {
                                selectedItems.add(items.first); // Add back "All" if empty
                              }
                            } else {
                              if (item.startsWith('All')) {
                                selectedItems.clear();
                                selectedItems.add(item);
                              } else {
                                selectedItems.remove(items.first); // Remove "All" option
                                selectedItems.add(item);
                              }
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFD1D5DB),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                                ),
                                child: isSelected
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Done button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFE5E5E5))),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ).then((_) {
      setState(() {}); // Refresh the main modal
    });
  }

  Widget _buildPracticesList() {
    return Consumer<ClubsProvider>(
      builder: (context, clubsProvider, child) {
        final practices = _getFilteredPractices(clubsProvider);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...practices.map((practice) => _buildPracticeItem(practice)),
          ],
        );
      },
    );
  }

  Widget _buildPracticeItem(Practice practice) {
    final isSelected = _selectedPracticeIds.contains(practice.id);
    final dayName = _getDayName(practice.dateTime.weekday);
    final timeRange = _getTimeRange(practice);
    final location = practice.location;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedPracticeIds.remove(practice.id);
          } else {
            _selectedPracticeIds.add(practice.id);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFD1D5DB),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
                color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
              ),
              child: isSelected
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$dayName • $timeRange • $location',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRSVPSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Select Timeframe and RSVP:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                // Show tooltip using PhoneModalUtils
                PhoneModalUtils.showPhoneModal(
                  context: context,
                  child: Container(
                    width: 280,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5))),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Bulk RSVP Info',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: const Icon(Icons.close, size: 24, color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: const Text(
                            'You can use to apply Yes/No RSVPs for future practices and/or overwrite any current Yes/Maybe/No RSVPs',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF374151),
                              height: 1.4,
                            ),
                          ),
                        ),
                        // OK button
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            border: Border(top: BorderSide(color: Color(0xFFE5E5E5))),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('OK'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF9CA3AF),
                ),
                child: const Icon(
                  Icons.question_mark,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            // Timeframe options (left side) - styled like checkbox filters to match practices above
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _timeframes.map((timeframe) {
                  final isSelected = _selectedTimeframe == timeframe;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTimeframe = timeframe;
                      });
                      if (timeframe == 'Custom') {
                        _showDateRangeDialog();
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF3B82F6)
                                    : const Color(0xFFD1D5DB),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4), // Square corners like checkboxes
                              color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, size: 12, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _getTimeframeDisplayText(timeframe),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF374151),
                                    ),
                                  ),
                                ),
                                // Add tooltip icons for specific timeframes
                                if (timeframe == 'Only announced' || timeframe == 'All future')
                                  GestureDetector(
                                    onTap: () => _showTimeframeTooltip(timeframe),
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 4),
                                      width: 14,
                                      height: 14,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                      child: const Icon(
                                        Icons.question_mark,
                                        size: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(width: 20),
            
            // RSVP options (right side) - using shared RSVP button function
            Row(
              children: [
                // Yes RSVP Button
                buildRSVPButton(
                  status: RSVPStatus.yes,
                  selectedStatus: _selectedRSVPStatus,
                  onTap: () {
                    setState(() {
                      _selectedRSVPStatus = RSVPStatus.yes;
                    });
                  },
                  size: 60.0,
                ),
                
                const SizedBox(width: 16),
                
                // No RSVP Button
                buildRSVPButton(
                  status: RSVPStatus.no,
                  selectedStatus: _selectedRSVPStatus,
                  onTap: () {
                    setState(() {
                      _selectedRSVPStatus = RSVPStatus.no;
                    });
                  },
                  size: 60.0,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  String _getTimeframeDisplayText(String timeframe) {
    if (timeframe == 'Custom' && _customStartDate != null && _customEndDate != null) {
      return '${_formatDate(_customStartDate!)} - ${_formatDate(_customEndDate!)}';
    }
    return timeframe;
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _showDateRangeDialog() async {
    DateTime? startDate = _customStartDate ?? DateTime.now();
    DateTime? endDate = _customEndDate ?? DateTime.now().add(const Duration(days: 7));

    await PhoneModalUtils.showPhoneModal(
      context: context,
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Date Range',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(Icons.close, size: 24, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Start Date
                      Row(
                        children: [
                          const SizedBox(
                            width: 70,
                            child: Text(
                              'Start Date',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: startDate ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (date != null) {
                                  setDialogState(() {
                                    startDate = date;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFD1D5DB)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  startDate != null ? _formatDate(startDate!) : 'Select date',
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // End Date
                      Row(
                        children: [
                          const SizedBox(
                            width: 70,
                            child: Text(
                              'End Date',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: endDate ?? DateTime.now().add(const Duration(days: 7)),
                                  firstDate: startDate ?? DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (date != null) {
                                  setDialogState(() {
                                    endDate = date;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFD1D5DB)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  endDate != null ? _formatDate(endDate!) : 'Select date',
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Action buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFE5E5E5))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            // Reset timeframe to "Announced" when canceling custom date range
                            // Close dialog first, then update parent state
                            Navigator.of(context).pop();
                            setState(() {
                              _selectedTimeframe = 'Announced';
                            });
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Color(0xFF6B7280)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (startDate != null && endDate != null) {
                              setState(() {
                                _customStartDate = startDate;
                                _customEndDate = endDate;
                              });
                            }
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showTimeframeTooltip(String timeframe) {
    String tooltipText;
    switch (timeframe) {
      case 'Announced':
        tooltipText = 'Applies to all future practices that have been announced/scheduled';
        break;
      case 'All future':
        tooltipText = 'Applies to all future practices that match the day and time until the practice details change';
        break;
      default:
        return;
    }

    PhoneModalUtils.showPhoneModal(
      context: context,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    timeframe,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, size: 24, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                tooltipText,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                  height: 1.4,
                ),
              ),
            ),
            // OK button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE5E5E5))),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('OK'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E5E5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _selectedPracticeIds.isNotEmpty ? _handleApply : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  List<Practice> _getFilteredPractices(ClubsProvider clubsProvider) {
    List<Practice> practices = [];
    
    // Get all practices from all clubs for now (mock data)
    for (final club in clubsProvider.clubs) {
      practices.addAll(club.upcomingPractices.where((p) => p.isUpcoming));
    }
    
    // Apply location filter
    if (!_selectedLocations.contains('All locations')) {
      practices = practices.where((p) => _selectedLocations.contains(p.location)).toList();
    }
    
    // Apply day filter
    if (!_selectedDays.contains('All days')) {
      practices = practices.where((p) {
        final dayName = _getDayName(p.dateTime.weekday);
        return _selectedDays.contains(dayName);
      }).toList();
    }
    
    // Sort by date
    practices.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    return practices;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday: return 'Mon';
      case DateTime.tuesday: return 'Tue';
      case DateTime.wednesday: return 'Wed';
      case DateTime.thursday: return 'Thu';
      case DateTime.friday: return 'Fri';
      case DateTime.saturday: return 'Sat';
      case DateTime.sunday: return 'Sun';
      default: return 'Mon';
    }
  }

  String _getTimeRange(Practice practice) {
    final start = practice.formattedTime;
    final endTime = practice.dateTime.add(practice.duration);
    final endHour = endTime.hour > 12 ? endTime.hour - 12 : (endTime.hour == 0 ? 12 : endTime.hour);
    final endPeriod = endTime.hour >= 12 ? 'pm' : 'am';
    final end = '$endHour:${endTime.minute.toString().padLeft(2, '0')}$endPeriod';
    return '$start-$end';
  }

  void _handleApply() async {
    if (_selectedPracticeIds.isEmpty) return;

    try {
      final rsvpProvider = Provider.of<RSVPProvider>(context, listen: false);
      final clubsProvider = Provider.of<ClubsProvider>(context, listen: false);
      
      final allPractices = _getFilteredPractices(clubsProvider);
      final selectedPractices = allPractices.where(
        (p) => _selectedPracticeIds.contains(p.id),
      ).toList();
      
      final clubId = selectedPractices.isNotEmpty ? selectedPractices.first.clubId : '';
      
      final request = BulkRSVPRequest(
        practiceIds: _selectedPracticeIds.toList(),
        newStatus: _selectedRSVPStatus,
        clubId: clubId,
        userId: rsvpProvider.currentUserId,
      );
      
      await rsvpProvider.bulkUpdateRSVP(request);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('RSVP updated for ${_selectedPracticeIds.length} practices'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }
}
