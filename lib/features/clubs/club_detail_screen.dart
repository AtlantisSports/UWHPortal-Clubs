

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/club.dart';
import '../../core/models/practice.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/rsvp_provider.dart';
import '../../base/widgets/buttons.dart';
import '../../base/widgets/rsvp_components.dart';
import '../../base/widgets/calendar_widget.dart';
import '../../base/widgets/bulk_rsvp_manager.dart';
import '../../core/utils/responsive_helper.dart';
// ...existing code...

class ClubDetailScreen extends StatefulWidget {
  final Club club;
  final String currentUserId;
  final Function(String practiceId, RSVPStatus status)? onRSVPChanged;
  final VoidCallback? onBackPressed;
  final Practice? initialSelectedPractice; // Add parameter for initial practice selection
  
  const ClubDetailScreen({
    super.key,
    required this.club,
    required this.currentUserId,
    this.onRSVPChanged,
    this.onBackPressed,
    this.initialSelectedPractice,
  });
  
  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  final bool _isMember = false;
  bool _isLoading = false;
  bool _showingBulkRSVP = false;
  bool _showingPracticeDetail = false;
  Practice? _selectedPractice;
// ...existing code...
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController = ScrollController();
    
    // Initialize with the provided practice if available
    if (widget.initialSelectedPractice != null) {
      _selectedPractice = widget.initialSelectedPractice;
      _showingPracticeDetail = true;
    }
    
    // Add listener to auto-scroll when tab is clicked (after frame is built)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabController.addListener(() {
        if (_tabController.indexIsChanging) {
          _autoScrollToTabsPosition();
        }
      });
    });
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

  Widget _buildBulkRSVPContent() {
    return BulkRSVPManager(
      club: widget.club,
      onCancel: () {
        setState(() {
          _showingBulkRSVP = false;
        });
      },
    );
  }

  void _handlePracticeSelected(Practice practice) {
    setState(() {
      _selectedPractice = practice;
      _showingPracticeDetail = true;
    });
  }

  void _handleBackFromPracticeDetail() {
    setState(() {
      _showingPracticeDetail = false;
      _selectedPractice = null;
    });
  }

  Widget _buildPracticeDetailContent() {
    if (_selectedPractice == null) return Container();
    
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Practice Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedPractice!.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, 
                           color: AppColors.primary, size: 16),
                      SizedBox(width: 8),
                      Text(
                        '${_selectedPractice!.dateTime.day}/${_selectedPractice!.dateTime.month}/${_selectedPractice!.dateTime.year}',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, 
                           color: AppColors.primary, size: 16),
                      SizedBox(width: 8),
                      Text(
                        _formatPracticeTime(_selectedPractice!.dateTime),
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, 
                           color: AppColors.primary, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedPractice!.location,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            
            // RSVP Section (positioned above description)
            Consumer<RSVPProvider>(
              builder: (context, rsvpProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PracticeRSVPCard(
                      practice: _selectedPractice!,
                      clubId: widget.club.id,
                      // No onInfoTap here since we're already in practice details
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 24),
            
            // Description
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    _selectedPractice!.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
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

  String _formatPracticeTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteStr $amPm';
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
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

  /// Calculate dynamic height for tab content to allow tab bar to stick at top when scrolled
  double _calculateDynamicTabHeight(BuildContext context) {
    // Since this is a phone mockup in a browser, use realistic phone screen dimensions
    // Galaxy S23 dimensions: 393x852 dp
    const phoneScreenHeight = 852.0;
    const phoneStatusBarHeight = 44.0; // From phone frame implementation
    const appBottomNavHeight = 56.0; // App's bottom navigation bar (Home, Events, etc.)
    const systemNavBarHeight = 48.0; // System navigation bar (black bar with home button)
    const tabBarHeight = 48.0; // The tab bar itself (RSVP, Typical Practices, etc.)
    const paddingAdjustment = 16.0; // Account for various paddings and margins
    final appBarHeight = AppBar().preferredSize.height; // 56px
    
    // Calculate the space available for tab content when tab bar is at the desired position
    // Tab bar should remain visible, so subtract its height too
    final tabContentHeight = phoneScreenHeight - phoneStatusBarHeight - appBarHeight - tabBarHeight - appBottomNavHeight - systemNavBarHeight - paddingAdjustment;
    
    // Ensure minimum usable height for calendar content
    const minHeight = 300.0;
    
    final finalHeight = tabContentHeight > minHeight ? tabContentHeight : minHeight;
    
    // Return the larger of calculated height or minimum height
    return finalHeight;
  }

  /// Auto-scroll to the position where tab bar is at the top
  void _autoScrollToTabsPosition() {
    if (!_scrollController.hasClients) return;
    
    // Scroll to the maximum extent to bring tab bar to the sticky position
    // This matches the height calculation we did for the tab content
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    
    // Animate to the maximum scroll position (full scroll down)
    _scrollController.animateTo(
      maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
        title: Text(_showingBulkRSVP 
            ? 'BULK RSVP' 
            : _showingPracticeDetail 
                ? 'Practice Details'
                : widget.club.name),
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_showingBulkRSVP) {
              // Close the bulk RSVP modal
              setState(() {
                _showingBulkRSVP = false;
              });
            } else if (_showingPracticeDetail) {
              // Close the practice detail view
              _handleBackFromPracticeDetail();
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
      body: _showingBulkRSVP 
          ? _buildBulkRSVPContent()
          : _showingPracticeDetail
              ? _buildPracticeDetailContent()
              : SingleChildScrollView(
        controller: _scrollController,
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
                  
                  // Next Practice Section
                  Consumer<RSVPProvider>(builder: (context, rsvpProvider, child) {
                    final nextPractice = _getNextPractice();
                    if (nextPractice == null) return const SizedBox.shrink();
                    
                    // Initialize RSVP status if needed
                    rsvpProvider.initializePracticeRSVP(nextPractice);
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next Practice',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 12),
                        PracticeRSVPCard(
                          practice: nextPractice,
                          clubId: widget.club.id,
                          currentRSVP: rsvpProvider.getRSVPStatus(nextPractice.id),
                                                        onRSVPChanged: (status) {
                                                            // Implement RSVP update logic here if needed
                                                          },
                          onLocationTap: _handleLocationTap,
                          onInfoTap: () => _handlePracticeSelected(nextPractice),
                        ),
                      ],
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
                        onTap: (index) {
                          // Very short delay for RSVP tab to prevent animation conflict
                          if (index == 0) {
                            // Minimal delay for RSVP tab
                            Future.delayed(const Duration(milliseconds: 50), () {
                              _autoScrollToTabsPosition();
                            });
                          } else {
                            // Immediate scroll for other tabs
                            _autoScrollToTabsPosition();
                          }
                        },
                        tabs: const [
                          Tab(text: 'RSVP'),
                          Tab(text: 'Typical Practices'),
                          Tab(text: 'Gallery'),
                          Tab(text: 'Forum'),
                        ],
                      ),
                      SizedBox(
                        height: _calculateDynamicTabHeight(context),
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
          
          const SizedBox(height: 16),
          
          // Practice Calendar
          Expanded(
            child: Consumer<RSVPProvider>(
              builder: (context, rsvpProvider, child) {
                return PracticeCalendar(
                  club: widget.club,
                  onPracticeSelected: _handlePracticeSelected,
                  rsvpProvider: rsvpProvider,
                );
              },
            ),
          ),
        ],
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
            
            // Single container for all practices
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Practice items with dividers
                  ...widget.club.upcomingPractices.asMap().entries.map((entry) {
                    final index = entry.key;
                    final practice = entry.value;
                    final isLast = index == widget.club.upcomingPractices.length - 1;
                    
                    return Column(
                      children: [
                        _buildPracticeRow(practice),
                        if (!isLast) ...[
                          const SizedBox(height: 12),
                          Divider(
                            color: Colors.grey.shade200,
                            thickness: 1,
                            height: 1,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeRow(Practice practice) {
    final dayName = _getDayName(practice.dateTime.weekday);
    final startTime = practice.dateTime;
    final endTime = practice.dateTime.add(practice.duration);
    final timeStr = '${_formatTime(startTime)} - ${_formatTime(endTime)}';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main row with day, time, and location
        Row(
          children: [
            // Day text (no background)
            Text(
              dayName,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            // Time
            Text(
              timeStr,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            // Separator
            Text(
              '•',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: 8),
            // Location (clickable)
            Expanded(
              child: GestureDetector(
                onTap: () => _launchLocationUrl(practice.mapsUrl),
                child: Text(
                  practice.location,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    color: const Color(0xFF0284C7), // Blue color to indicate it's clickable
                    decoration: TextDecoration.underline,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        // Second row with description and tag
        if (practice.tag != null || practice.description.isNotEmpty) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description text (left side)
                if (practice.description.isNotEmpty) ...[
                  Expanded(
                    child: Text(
                      practice.description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ] else ...[
                  // Empty space when no description
                  const Expanded(child: SizedBox()),
                ],
                // Practice tag (right side)
                if (practice.tag != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      practice.tag!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
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

  /// Helper method to get day name from weekday number
  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday: return 'Monday';
      case DateTime.tuesday: return 'Tuesday';
      case DateTime.wednesday: return 'Wednesday';
      case DateTime.thursday: return 'Thursday';
      case DateTime.friday: return 'Friday';
      case DateTime.saturday: return 'Saturday';
      case DateTime.sunday: return 'Sunday';
      default: return '';
    }
  }

  /// Helper method to format time in 12-hour format
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteStr $period';
  }

  /// Launch location URL in maps app or browser
  Future<void> _launchLocationUrl(String url) async {
    try {
      // For web, this will open in a new tab
      // For mobile, this will try to open in maps app
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback: show a snackbar with the address
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open location: $url'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Error handling: show snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening location: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
