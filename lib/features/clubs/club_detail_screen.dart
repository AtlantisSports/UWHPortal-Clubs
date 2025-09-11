

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
import '../../base/widgets/calendar_widget.dart';
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
  late ScrollController _scrollController;
  final bool _isMember = false;
  bool _isLoading = false;
  bool _showingBulkRSVP = false;
// ...existing code...
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController = ScrollController();
    
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
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'BULK RSVPs COMING SOON',
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
        title: Text(_showingBulkRSVP ? 'BULK RSVP' : widget.club.name),
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
            child: PracticeCalendar(club: widget.club),
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
}
