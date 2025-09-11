

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/club.dart';
import '../../core/models/practice.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/rsvp_provider.dart';
import '../../base/widgets/buttons.dart';
import '../../base/widgets/rsvp_components.dart';
import '../../base/widgets/phone_modal_utils.dart';
import '../../core/utils/responsive_helper.dart';
// ...existing code...

class ClubDetailScreen extends StatefulWidget {
  final Club club;
  final String currentUserId;
  final Function(String practiceId, RSVPStatus status)? onRSVPChanged;
  final VoidCallback? onBackPressed;
  
  const ClubDetailScreen({
    super.key,
    required this.club,
    required this.currentUserId,
    this.onRSVPChanged,
    this.onBackPressed,
  });
  
  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final bool _isMember = false;
  bool _isLoading = false;
  bool _showingBulkRSVP = false;
  bool _showingPracticeDetails = false;
  Practice? _selectedPractice;

  // Calendar and practice data
  late Map<DateTime, List<Practice>> _calendarPractices;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _generateCalendarPractices();
  // Removed call to _initializeRSVPStatus (method no longer exists)
  }

  // ...existing code...
    // Removed _initializeRSVPStatus();
  void _handleLocationTap() async {
    final nextPractice = _getNextPractice();
    if (nextPractice != null) {
      // Create a Google Maps search URL for the location
      final encodedLocation = Uri.encodeComponent(nextPractice.location);
      final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedLocation');
      
      try {
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          // Fallback: show a snackbar if URL launcher fails
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open location: ${nextPractice.location}')),
            );
          }
        }
      } catch (e) {
        // Handle any errors
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error opening location: ${nextPractice.location}')),
          );
        }
      }
    }
  }

  /// Get the next upcoming practice (same logic as My Clubs view)
  Practice? _getNextPractice() {
    if (widget.club.upcomingPractices.isEmpty) return null;
    
    final now = DateTime.now();
    final upcomingPractices = widget.club.upcomingPractices
        .where((practice) => practice.dateTime.isAfter(now))
        .toList();
    
    if (upcomingPractices.isEmpty) return null;
    
    // Sort by date and return the earliest one
    upcomingPractices.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return upcomingPractices.first;
  }

  void _showBulkRSVPModal(BuildContext context) {
    setState(() {
      _showingBulkRSVP = true;
    });
  }

  void _generateCalendarPractices() {
    _calendarPractices = {};
    
    // Define practice schedules based on club
    List<Map<String, dynamic>> practiceTemplates = [];
    
    if (widget.club.name.contains('Denver')) {
      practiceTemplates = [
        {'day': DateTime.monday, 'time': '8:15 PM - 9:30 PM', 'location': 'VMAC'},
        {'day': DateTime.wednesday, 'time': '7:00 PM - 8:30 PM', 'location': 'Carmody'},
        {'day': DateTime.thursday, 'time': '8:15 PM - 9:30 PM', 'location': 'VMAC'},
        {'day': DateTime.sunday, 'time': '10:00 AM - 11:30 AM', 'location': 'VMAC'},
        {'day': DateTime.sunday, 'time': '3:00 PM - 4:30 PM', 'location': 'Carmody'},
      ];
    } else if (widget.club.name.contains('Sydney')) {
      practiceTemplates = [
        {'day': DateTime.friday, 'time': '7:00 PM - 9:00 PM', 'location': 'Ryde'},
      ];
    }
    
    // Generate practices for September through November 2025
    final startDate = DateTime(2025, 9, 1);
    final endDate = DateTime(2025, 11, 30);
    
    for (var date = startDate; date.isBefore(endDate.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
      final dayOfWeek = date.weekday;
      
      for (var template in practiceTemplates) {
        if (template['day'] == dayOfWeek) {
          final practice = Practice(
            id: 'practice_${date.millisecondsSinceEpoch}_${template['location']}',
            clubId: widget.club.id,
            title: 'Regular practice',
            dateTime: date,
            location: template['location'],
            address: template['location'],
            duration: const Duration(hours: 1, minutes: 30),
            description: 'Regular practice at ${template['location']}',
            maxParticipants: 20,
            participants: _generateRandomParticipantsList(),
          );
          
          if (_calendarPractices[date] == null) {
            _calendarPractices[date] = [];
          }
          _calendarPractices[date]!.add(practice);
        }
      }
    }
  }
  
  List<String> _generateRandomParticipantsList() {
    // Generate random participant count between 8-18
    final count = 8 + (DateTime.now().millisecondsSinceEpoch % 11).toInt();
    return List.generate(count, (index) => 'user_$index');
  }
  
  RSVPStatus _generateMockRSVPStatus(DateTime practiceDate) {
    final now = DateTime.now();
    final isPast = practiceDate.isBefore(now);
    
    if (isPast) {
      // For past practices, generate attended/not attended based on random pattern
      final random = (practiceDate.millisecondsSinceEpoch % 100);
      return random < 75 ? RSVPStatus.yes : RSVPStatus.no; // 75% attendance rate
    } else {
      // For future practices, mix of pending and various RSVP statuses
      final random = (practiceDate.millisecondsSinceEpoch % 100);
      if (random < 40) return RSVPStatus.pending;
      if (random < 65) return RSVPStatus.yes;
      if (random < 80) return RSVPStatus.maybe;
      return RSVPStatus.no;
    }
  }

  Widget _buildBulkRSVPContent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bulk RSVP Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Future: implement actual bulk RSVP functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bulk RSVP functionality coming soon!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Bulk RSVP',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Announced Practices Section
            const Text(
              'Announced Practices',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Calendar for September 2025
            _buildCalendarMonth(DateTime(2025, 9)),
            const SizedBox(height: 24),
            
            // Calendar for October 2025
            _buildCalendarMonth(DateTime(2025, 10)),
            const SizedBox(height: 24),
            
            // Calendar for November 2025
            _buildCalendarMonth(DateTime(2025, 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeDetailsContent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'PRACTICE DETAILS COMING SOON',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _toggleMembership() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Implement actual API call using ClubsService
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
                 // RSVP change logic handled elsewhere
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isMember ? 'Joined club successfully!' : 'Left club successfully!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Force mobile layout since we're always within a phone frame
    final EdgeInsets responsivePadding = const EdgeInsets.all(16.0);
    
    // Ensure content fits within phone frame constraints
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 393, // Galaxy S23 width - match phone frame
      ),
      child: Scaffold(
      appBar: AppBar(
        title: Text(_showingPracticeDetails 
            ? 'Practice Details' 
            : _showingBulkRSVP 
                ? 'BULK RSVP' 
                : widget.club.name),
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_showingPracticeDetails) {
              // Return to bulk RSVP view
              setState(() {
                _showingPracticeDetails = false;
                _selectedPractice = null;
              });
            } else if (_showingBulkRSVP) {
              // Close the bulk RSVP modal
              setState(() {
                _showingBulkRSVP = false;
              });
            } else {
              // Go back to clubs list
              if (widget.onBackPressed != null) {
                widget.onBackPressed!();
              } else {
                Navigator.pop(context);
              }
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              size: 28.8, // Match other tabs
            ),
            onPressed: () {
              // TODO: Implement notifications functionality
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.menu,
              size: 28.8, // Match other tabs
            ),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ],
      ),
      body: _showingPracticeDetails
          ? _buildPracticeDetailsContent()
          : _showingBulkRSVP 
              ? _buildBulkRSVPContent()
              : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Club header section with image/icon - added padding to match event details
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 2.0, bottom: 0.0), // No bottom padding
              child: Container(
                width: double.infinity,
                height: 200.0, // Mobile height
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0), // Add rounded corners like event page
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                  ),
                ),
                clipBehavior: Clip.hardEdge, // Ensure image respects border radius
                child: widget.club.logoUrl != null
                    ? Image.network(
                        widget.club.logoUrl!,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.group,
                        size: 80, // Mobile size
                        color: Colors.white54,
                      ),
              ),
            ),
            
            // Club info content
            Padding(
              padding: responsivePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 0), // No padding above club name
                  
                  // Full club name - centered
                  Center(
                    child: Text(
                      widget.club.longName,
                      style: AppTextStyles.headline2.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  SizedBox(height: ResponsiveHelper.getSpacing(context)),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: PrimaryButton(
                            text: _isMember ? 'Leave' : 'Join',
                            onPressed: _toggleMembership,
                            isLoading: _isLoading,
                            icon: _isMember ? Icons.exit_to_app : Icons.group_add,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: SecondaryButton(
                            text: 'Contact',
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Contact feature coming soon!')),
                              );
                            },
                            icon: Icons.email,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: ResponsiveHelper.getSpacing(context, mobileSpacing: 16.0)),
                  
                  // Next Practice Card (same as clubs page)
                  Consumer<RSVPProvider>(builder: (context, rsvpProvider, child) {
                    final nextPractice = _getNextPractice();
                    if (nextPractice == null) return const SizedBox.shrink();
                    
                    // Initialize RSVP status if needed
                    rsvpProvider.initializePracticeRSVP(nextPractice);
                    
                    return NextPracticeCard(
                      practice: nextPractice,
                      clubId: widget.club.id,
                      currentRSVP: rsvpProvider.getRSVPStatus(nextPractice.id),
                                                onRSVPChanged: (status) {
                                                  // Implement RSVP update logic here if needed
                                                },
                      onLocationTap: _handleLocationTap,
                    );
                  }),
                  
                  Builder(builder: (context) {
                    final nextPractice = _getNextPractice();
                    return nextPractice != null
                        ? SizedBox(height: ResponsiveHelper.getSpacing(context, mobileSpacing: 8.0))
                        : const SizedBox.shrink();
                  }),
                  
                  // Tabs section
                  Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorColor: AppColors.primary,
                        labelStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                        tabs: const [
                          Tab(text: 'RSVP'),
                          Tab(text: 'Typical Practices'),
                          Tab(text: 'Gallery'),
                          Tab(text: 'Forum'),
                        ],
                      ),
                      SizedBox(
                        height: 300.0, // Mobile height
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildRSVPTab(context),
                            _buildTypicalPracticesTab(context),
                            _buildGalleryTab(context),
                            _buildForumTab(context),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ], // Close Column children
        ), // Close Column
      ), // Close SingleChildScrollView
    ), // Close Scaffold
    ); // Close ConstrainedBox
  }

  Widget _buildRSVPTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bulk RSVP Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showBulkRSVPModal(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Bulk RSVP',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Announced Practices Section
            const Text(
              'Announced Practices',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Calendar for September 2025
            _buildCalendarMonth(DateTime(2025, 9)),
            const SizedBox(height: 24),
            
            // Calendar for October 2025
            _buildCalendarMonth(DateTime(2025, 10)),
            const SizedBox(height: 24),
            
            // Calendar for November 2025
            _buildCalendarMonth(DateTime(2025, 11)),
          ],
        ),
      ),
    );
  }
  }

  Widget _buildTypicalPracticesTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Typical Practice Schedule',
              style: AppTextStyles.headline3.copyWith(
                fontSize: 20,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            
            // Sample practice items
            _buildPracticeItem(context,
              day: 'Monday',
              time: '7:00 PM - 9:00 PM', 
              location: 'UBC Pool',
              description: 'Regular team practice with scrimmage',
            ),
            _buildPracticeItem(context,
              day: 'Wednesday', 
              time: '7:00 PM - 9:00 PM',
              location: 'UBC Pool',
              description: 'Skills training and conditioning',
            ),
            _buildPracticeItem(context,
              day: 'Saturday',
              time: '10:00 AM - 12:00 PM',
              location: 'UBC Pool', 
              description: 'Game strategy and team building',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeItem(BuildContext context, {
    required String day,
    required String time,
    required String location,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  day,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                time,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGalleryTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library,
              size: 48,
              color: AppColors.textDisabled,
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            Text(
              'Club Gallery',
              style: AppTextStyles.headline3.copyWith(
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context, mobileSpacing: 4.0)),
            Text(
              'Photos and videos coming soon',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForumTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum,
              size: 48,
              color: AppColors.textDisabled,
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            Text(
              'Club Forum',
              style: AppTextStyles.headline3.copyWith(
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context, mobileSpacing: 4.0)),
            Text(
              'Discussions and announcements coming soon',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Calendar-related methods moved here to ensure they're inside the class
  Widget _buildCalendarMonth(DateTime month) {
    final monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header
        Text(
          '${monthNames[month.month]} ${month.year}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // Calendar grid
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Day headers
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                      .map((day) => Expanded(
                            child: Text(
                              day,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              
              // Calendar days
              ..._buildCalendarWeeks(month),
            ],
          ),
        ),
      ],
    );
  }
  
  List<Widget> _buildCalendarWeeks(DateTime month) {
    final weeks = <Widget>[];
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    
    // Calculate the first day to show (including previous month's days)
    final startDate = firstDay.subtract(Duration(days: firstDay.weekday % 7));
    
    for (var weekStart = startDate; 
         weekStart.isBefore(lastDay.add(const Duration(days: 7))); 
         weekStart = weekStart.add(const Duration(days: 7))) {
      
      final weekDays = <Widget>[];
      for (var i = 0; i < 7; i++) {
        final day = weekStart.add(Duration(days: i));
        final isCurrentMonth = day.month == month.month;
        final practices = _calendarPractices[DateTime(day.year, day.month, day.day)] ?? [];
        
        weekDays.add(
          Expanded(
            child: GestureDetector(
              onTap: isCurrentMonth && practices.isNotEmpty 
                  ? () => _handleDayTap(day, practices)
                  : null,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey[300]!),
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Stack(
                  children: [
                    // Day number
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isCurrentMonth ? Colors.black87 : Colors.grey[400],
                          fontWeight: isCurrentMonth ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                    
                    // Practice indicators
                    if (isCurrentMonth && practices.isNotEmpty)
                      Positioned.fill(
                        child: _buildPracticeIndicators(practices),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      
      weeks.add(Row(children: weekDays));
      
      // Stop if we've reached the end of the month
      if (weekStart.add(const Duration(days: 6)).month != month.month && 
          weekStart.add(const Duration(days: 6)).isAfter(lastDay)) {
        break;
      }
    }
    
    return weeks;
  }
  
  Widget _buildPracticeIndicators(List<Practice> practices) {
    if (practices.isEmpty) return const SizedBox();
    
    final indicators = <Widget>[];
    final circleSize = practices.length == 1 ? 20.0 : 
                     practices.length == 2 ? 16.0 :
                     practices.length == 3 ? 12.0 : 10.0;
    
    for (var i = 0; i < practices.length && i < 4; i++) {
      final practice = practices[i];
      final rsvpStatus = _generateMockRSVPStatus(practice.dateTime);
      final isPast = practice.dateTime.isBefore(DateTime.now());
      
      Widget indicator;
      
      if (isPast) {
        // Past practice: solid color with white icon
        final isAttended = rsvpStatus == RSVPStatus.yes;
        indicator = Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isAttended ? AppColors.accent : Colors.red[300],
          ),
          child: Icon(
            isAttended ? Icons.check : Icons.close,
            color: Colors.white,
            size: circleSize * 0.6,
          ),
        );
      } else {
        // Future practice: hollow circle with colored border
        if (rsvpStatus == RSVPStatus.pending) {
          // Pending: circle with question mark
          indicator = Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange, width: 2),
            ),
            child: Icon(
              Icons.help_outline,
              color: Colors.orange,
              size: circleSize * 0.6,
            ),
          );
        } else {
          // Other statuses: simple colored circle
          indicator = Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              color: rsvpStatus.color,
              border: Border.all(color: rsvpStatus.color, width: 2),
              shape: BoxShape.circle,
            ),
            child: rsvpStatus.overlayIcon,
          );
        }
      }
      
      indicators.add(indicator);
    }
    
    // Arrange indicators based on count
    if (practices.length == 1) {
      return indicators[0];
    } else if (practices.length == 2) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          indicators[0],
          const SizedBox(height: 2),
          indicators[1],
        ],
      );
    } else if (practices.length == 3) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          indicators[0],
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              indicators[1],
              const SizedBox(width: 2),
              indicators[2],
            ],
          ),
        ],
      );
    } else {
      // 4 or more in a 2x2 grid
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              indicators[0],
              const SizedBox(width: 2),
              indicators[1],
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              indicators[2],
              const SizedBox(width: 2),
              if (indicators.length > 3) indicators[3],
            ],
          ),
        ],
      );
    }
  }
  
  void _handleDayTap(DateTime day, List<Practice> practices) {
    if (practices.length == 1) {
      // Navigate directly to practice details
      setState(() {
        _selectedPractice = practices[0];
        _showingPracticeDetails = true;
      });
    } else {
      // Show selection modal for multiple practices
      _showPracticeSelectionModal(practices);
    }
  }
  
  void _showPracticeSelectionModal(List<Practice> practices) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Practice',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...practices.map((practice) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(practice.location),
                subtitle: Text('Practice session'),
                trailing: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _generateMockRSVPStatus(practice.dateTime).color,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedPractice = practice;
                    _showingPracticeDetails = true;
                  });
                },
              )),
            ],
          ),
        ),
      ),
    );
  }
}
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header
        Text(
          '${monthNames[month.month]} ${month.year}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // Calendar grid
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Day headers
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                      .map((day) => Expanded(
                            child: Text(
                              day,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              
              // Calendar days
              ..._buildCalendarWeeks(month),
            ],
          ),
        ),
      ],
    );
  }
  
  List<Widget> _buildCalendarWeeks(DateTime month) {
    final weeks = <Widget>[];
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    
    // Calculate the first day to show (including previous month's days)
    final startDate = firstDay.subtract(Duration(days: firstDay.weekday % 7));
    
    for (var weekStart = startDate; 
         weekStart.isBefore(lastDay.add(const Duration(days: 7))); 
         weekStart = weekStart.add(const Duration(days: 7))) {
      
      final weekDays = <Widget>[];
      for (var i = 0; i < 7; i++) {
        final day = weekStart.add(Duration(days: i));
        final isCurrentMonth = day.month == month.month;
        final practices = _calendarPractices[DateTime(day.year, day.month, day.day)] ?? [];
        
        weekDays.add(
          Expanded(
            child: GestureDetector(
              onTap: isCurrentMonth && practices.isNotEmpty 
                  ? () => _handleDayTap(day, practices)
                  : null,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey[300]!),
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Stack(
                  children: [
                    // Day number
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isCurrentMonth ? Colors.black87 : Colors.grey[400],
                          fontWeight: isCurrentMonth ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                    
                    // Practice indicators
                    if (isCurrentMonth && practices.isNotEmpty)
                      Positioned.fill(
                        child: _buildPracticeIndicators(practices),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      
      weeks.add(Row(children: weekDays));
      
      // Stop if we've reached the end of the month
      if (weekStart.add(const Duration(days: 6)).month != month.month && 
          weekStart.add(const Duration(days: 6)).isAfter(lastDay)) {
        break;
      }
    }
    
    return weeks;
  }
  
  Widget _buildPracticeIndicators(List<Practice> practices) {
    if (practices.isEmpty) return const SizedBox();
    
    final indicators = <Widget>[];
    final circleSize = practices.length == 1 ? 20.0 : 
                     practices.length == 2 ? 16.0 :
                     practices.length == 3 ? 12.0 : 10.0;
    
    for (var i = 0; i < practices.length && i < 4; i++) {
      final practice = practices[i];
      final rsvpStatus = _generateMockRSVPStatus(practice.dateTime);
      final isPast = practice.dateTime.isBefore(DateTime.now());
      
      Widget indicator;
      
      if (isPast) {
        // Past practice: solid color with white icon
        final isAttended = rsvpStatus == RSVPStatus.yes;
        indicator = Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isAttended ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
          child: Icon(
            isAttended ? Icons.check : Icons.close,
            size: circleSize * 0.6,
            color: Colors.white,
          ),
        );
      } else {
        // Future practice: match RSVP button styles
        if (rsvpStatus == RSVPStatus.pending) {
          indicator = Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey, width: 2),
              color: Colors.transparent,
            ),
          );
        } else {
          indicator = Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: rsvpStatus.color,
              border: Border.all(color: rsvpStatus.color, width: 2),
            ),
            child: Icon(
              rsvpStatus.overlayIcon,
              size: circleSize * 0.5,
              color: Colors.white,
            ),
          );
        }
      }
      
      indicators.add(indicator);
    }
    
    // Layout indicators based on count
    if (practices.length == 1) {
      return Center(child: indicators[0]);
    } else if (practices.length == 2) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          indicators[0],
          const SizedBox(height: 2),
          indicators[1],
        ],
      );
    } else if (practices.length == 3) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          indicators[0],
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              indicators[1],
              const SizedBox(width: 2),
              indicators[2],
            ],
          ),
        ],
      );
    } else {
      // 4 or more in a 2x2 grid
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              indicators[0],
              const SizedBox(width: 2),
              indicators[1],
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              indicators[2],
              const SizedBox(width: 2),
              if (indicators.length > 3) indicators[3],
            ],
          ),
        ],
      );
    }
  
  void _handleDayTap(DateTime day, List<Practice> practices) {
    if (practices.length == 1) {
      // Navigate directly to practice details
      setState(() {
        _selectedPractice = practices[0];
        _showingPracticeDetails = true;
      });
    } else {
      // Show selection modal for multiple practices
      _showPracticeSelectionModal(practices);
    }
  }
  
  void _showPracticeSelectionModal(List<Practice> practices) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Practice',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...practices.map((practice) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(practice.location),
                subtitle: Text('Practice session'),
                trailing: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _generateMockRSVPStatus(practice.dateTime).color,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedPractice = practice;
                    _showingPracticeDetails = true;
                  });
                },
              )),
            ],
          ),
        ),
      ),
    );
  }
}
