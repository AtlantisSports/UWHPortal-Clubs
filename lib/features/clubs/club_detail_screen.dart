

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/club.dart';
import '../../core/models/practice.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/rsvp_provider.dart';
import '../../base/widgets/buttons.dart';
import '../../base/widgets/shared_rsvp_button.dart';
import '../../base/widgets/rsvp_components.dart';
import '../../core/utils/responsive_helper.dart';
import '../../base/widgets/phone_modal_utils.dart';
import '../clubs/clubs_provider.dart';
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
// ...existing code...
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: Text('Clubs - ${widget.club.name}'),
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black87,
        elevation: 0,
        automaticallyImplyLeading: false,
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
      body: SingleChildScrollView(
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
          ],
        ),
      ),
    );
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

  void _showBulkRSVPModal(BuildContext context) async {
    await PhoneModalUtils.showPhoneModal(
      context: context,
      child: BulkRSVPModal(clubId: widget.club.id),
    );
  }
}

class BulkRSVPModal extends StatefulWidget {
  final String? clubId;
  
  const BulkRSVPModal({super.key, this.clubId});

  @override
  State<BulkRSVPModal> createState() => _BulkRSVPModalState();
}

class _BulkRSVPModalState extends State<BulkRSVPModal> {
  final Set<String> _selectedPracticeIds = {};
  final Set<String> _selectedLocations = {'All locations'};
  final Set<String> _selectedDays = {'All days'};
  RSVPStatus _selectedRSVPStatus = RSVPStatus.yes;
  String _selectedTimeframe = 'Announced'; // Default selection
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  
  final List<String> _locations = ['All locations', 'VMAC', 'Carmody'];
  final List<String> _timeframes = ['Announced', 'Custom', 'All future'];

  List<String> _getAvailableDays() {
    final clubsProvider = Provider.of<ClubsProvider>(context, listen: false);
    List<Practice> practices = [];
    
    // Get all practices from the current club
    if (widget.clubId != null) {
      final club = clubsProvider.getClubById(widget.clubId!);
      if (club != null) {
        practices.addAll(club.upcomingPractices.where((p) => p.isUpcoming));
      }
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
            // Timeframe options (left side) - styled like dropdown filters
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
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF3B82F6)
                                    : const Color(0xFFD1D5DB),
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Container(
                                    margin: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF3B82F6),
                                    ),
                                  )
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
                                if (timeframe == 'Announced' || timeframe == 'All future')
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
    
    // Get practices from specific club or all clubs
    if (widget.clubId != null) {
      final club = clubsProvider.getClubById(widget.clubId!);
      if (club != null) {
        practices = club.upcomingPractices.where((p) => p.isUpcoming).toList();
      }
    } else {
      for (final club in clubsProvider.clubs) {
        practices.addAll(club.upcomingPractices.where((p) => p.isUpcoming));
      }
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
      
      final clubId = selectedPractices.isNotEmpty ? selectedPractices.first.clubId : widget.clubId ?? '';
      
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
