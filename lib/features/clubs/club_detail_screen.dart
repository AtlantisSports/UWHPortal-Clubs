

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/club.dart';
import '../../core/models/practice.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/participation_provider.dart';
import '../../core/providers/navigation_provider.dart';
import '../../base/widgets/buttons.dart';
import '../../base/widgets/rsvp_components.dart';
import '../../base/widgets/calendar_widget.dart';
import '../../base/widgets/level_filter_modal.dart';
import '../../core/utils/responsive_helper.dart';
import 'practice_detail_screen.dart';
// ...existing code...

class ClubDetailScreen extends StatefulWidget {
  final Club club;
  final String currentUserId;
  final Function(String practiceId, ParticipationStatus status)? onRSVPChanged;
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
  final GlobalKey _tabBarKey = GlobalKey(); // Add GlobalKey for TabBar
  final bool _isMember = false;
  bool _isLoading = false;
  bool _showingBulkRSVP = false; // Temporarily disabled
  bool _isShowingLevelFilterModal = false;
  
  // Toast state
  bool _showToast = false;
  String _toastMessage = '';
  Color _toastColor = Colors.green;
  IconData? _toastIcon;
  String? _toastText;
// ...existing code...
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController = ScrollController();
    
    // Add listener to auto-scroll when tab is clicked (after frame is built)
    // Note: Using onTap in TabBar widget instead of controller listener to avoid conflicts
    /*
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabController.addListener(() {
        if (_tabController.indexIsChanging) {
          _autoScrollToTabsPosition();
        }
      });
    });
    */
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

  // Temporarily disabled bulk RSVP functionality
  // void _showBulkRSVPModal(BuildContext context) {
  //   setState(() {
  //     _showingBulkRSVP = true;
  //   });
  // }

  // Widget _buildBulkRSVPContent() {
  //   return BulkRSVPManager(
  //     club: widget.club,
  //     onCancel: () {
  //       setState(() {
  //         _showingBulkRSVP = false;
  //       });
  //     },
  //   );
  // }

  void _handlePracticeSelected(Practice practice) {
    // Navigate to separate Practice Detail Screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PracticeDetailScreen(
          practice: practice,
          club: widget.club,
          currentUserId: widget.currentUserId,
          onRSVPChanged: (practiceId, status) {
            // Handle RSVP changes if needed
          },
        ),
      ),
    );
  }
  
  Set<String> _getAvailableLevels() {
    final availableLevels = <String>{};
    for (final practice in widget.club.upcomingPractices) {
      if (practice.tag != null && practice.tag!.isNotEmpty) {
        availableLevels.add(practice.tag!);
      }
    }
    return availableLevels;
  }
  
  void _showLevelFilterModal() {
    setState(() {
      _isShowingLevelFilterModal = true;
    });
  }
  
  void _showCustomToast(String message, Color color, IconData icon) {
    setState(() {
      _toastMessage = message;
      _toastColor = color;
      _toastIcon = icon;
      _toastText = null;
      _showToast = true;
    });
    
    // Hide toast after 4 seconds
    Timer(Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showToast = false;
        });
      }
    });
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
    
    // Use GlobalKey + RenderBox approach for precise positioning
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      
      final RenderBox? tabBarRenderBox = _tabBarKey.currentContext?.findRenderObject() as RenderBox?;
      if (tabBarRenderBox == null) return;
      
      // Get the TabBar's position relative to the scroll view
      final tabBarPosition = tabBarRenderBox.localToGlobal(Offset.zero);
      
      // Get the scroll view's position
      final RenderBox? scrollViewRenderBox = _scrollController.position.context.storageContext.findRenderObject() as RenderBox?;
      if (scrollViewRenderBox == null) return;
      
      final scrollViewPosition = scrollViewRenderBox.localToGlobal(Offset.zero);
      
      // Calculate the TabBar's position within the scroll content
      final tabBarOffsetInScrollView = tabBarPosition.dy - scrollViewPosition.dy;
      
      // Add current scroll offset to get absolute position in content
      final tabBarAbsolutePosition = tabBarOffsetInScrollView + _scrollController.offset;
      
      // Target scroll position: bring TabBar to the top of the visible area
      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      final targetScrollPosition = tabBarAbsolutePosition.clamp(0.0, maxScrollExtent);
      
      // Animate to the calculated position
      _scrollController.animateTo(
        targetScrollPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
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
      child: Stack(
        children: [
          Scaffold(
      appBar: AppBar(
        title: Text(_showingBulkRSVP 
            ? 'BULK RSVP' 
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
          ? Container() // Temporarily disabled during migration
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
                  Consumer<ParticipationProvider>(builder: (context, participationProvider, child) {
                    final nextPractice = _getNextPractice();
                    if (nextPractice == null) return const SizedBox.shrink();
                    
                    // Initialize participation status if needed
                    participationProvider.initializePracticeParticipation(nextPractice);
                    
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
                          onRSVPChanged: (status) {
                            final participationStatus = status as ParticipationStatus;
                            // Show toast when RSVP changes
                            String message = 'RSVP updated to: ${participationStatus.displayText}';
                            Color toastColor = participationStatus.color;
                            if (participationStatus == ParticipationStatus.maybe) {
                              _showCustomToast(message, toastColor, Icons.help);
                            } else {
                              _showCustomToast(message, toastColor, participationStatus.overlayIcon);
                            }
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
                        key: _tabBarKey, // Add the GlobalKey here
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
      // Add bottom navigation when used as standalone page (not embedded in clubs list)
      bottomNavigationBar: widget.onBackPressed == null ? Consumer<NavigationProvider>(
        builder: (context, navigationProvider, child) {
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event),
                label: 'Events',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.groups),
                label: 'Programs',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.group),
                label: 'Clubs',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: navigationProvider.selectedIndex,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              // Navigate back to main app with selected tab
              Navigator.of(context).popUntil((route) => route.isFirst);
              navigationProvider.selectTab(index);
            },
          );
        },
      ) : null,
    ), // Close Scaffold
          // Custom toast positioned over the content
          if (_showToast)
            Positioned(
              top: kToolbarHeight + 48, // Position to cover the tab bar area
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
                      // Display either icon or text (skip if empty)
                      if (_toastIcon != null)
                        Icon(
                          _toastIcon!,
                          color: Colors.white,
                          size: 20,
                        )
                      else if (_toastText != null && _toastText!.isNotEmpty)
                        Text(
                          _toastText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Arial',
                          ),
                        ),
                      // Only add spacing if we have an icon or non-empty text
                      if ((_toastIcon != null) || (_toastText != null && _toastText!.isNotEmpty))
                        const SizedBox(width: 8),
                      Text(
                        _toastMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Modal overlays using the same pattern as profile screen
          _buildModalOverlays(),
        ],
      ),
    ); // Close ConstrainedBox
  }

  Widget _buildModalOverlays() {
    return Stack(
      children: [
        // Level Filter Modal
        if (_isShowingLevelFilterModal) ...[
          _buildModalBackdrop(() => setState(() => _isShowingLevelFilterModal = false)),
          _buildLevelFilterModal(),
        ],
      ],
    );
  }

  Widget _buildModalBackdrop(VoidCallback onTap) {
    return Positioned(
      top: kToolbarHeight, // Start below AppBar
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        color: Colors.black54,
        child: GestureDetector(
          onTap: onTap,
          child: Container(),
        ),
      ),
    );
  }

  Widget _buildModalContainer({required Widget child}) {
    return Positioned(
      left: 0,
      right: 0,
      top: kToolbarHeight + 100, // Position below AppBar
      bottom: 0, // Extend to bottom
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildLevelFilterModal() {
    return _buildModalContainer(
      child: LevelFilterModal(
        availableLevels: _getAvailableLevels(),
        onFiltersChanged: () {
          setState(() => _isShowingLevelFilterModal = false);
        },
      ),
    );
  }

  Widget _buildRSVPTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bulk RSVP Button - Temporarily Disabled
          SizedBox(
            width: double.infinity,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Bulk RSVP (Under Development)',
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            /*
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
            ), */
          ),
          
          const SizedBox(height: 16),
          
          // Practice Calendar
          Expanded(
            child: Consumer<ParticipationProvider>(
              builder: (context, participationProvider, child) {
                return PracticeCalendar(
                  club: widget.club,
                  onPracticeSelected: _handlePracticeSelected,
                  participationProvider: participationProvider,
                  onShowLevelFilter: _showLevelFilterModal,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypicalPracticesTab(BuildContext context) {
    final typicalPractices = _getTypicalPractices();
    
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
                  ...typicalPractices.asMap().entries.map((entry) {
                    final index = entry.key;
                    final practice = entry.value;
                    final isLast = index == typicalPractices.length - 1;
                    
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

  /// Get typical/template practices for the club (same as used in bulk RSVP)
  List<Practice> _getTypicalPractices() {
    final typicalPractices = <Practice>[
      Practice(
        id: 'typical-monday',
        clubId: widget.club.id,
        title: 'Monday Evening',
        description: 'Beginner-friendly; arrive 10 min early.',
        dateTime: DateTime(2025, 1, 6, 20, 15), // Template: Monday 8:15 PM (using first Monday of 2025)
        location: 'VMAC',
        address: '5310 E 136th Ave, Thornton, CO',
        tag: 'Open',
      ),
      Practice(
        id: 'typical-wednesday',
        clubId: widget.club.id,
        title: 'Wednesday Evening',
        description: 'Shallow end reserved. High-level participants only.',
        dateTime: DateTime(2025, 1, 1, 19, 0), // Template: Wednesday 7:00 PM (using first Wednesday of 2025)
        location: 'Carmody',
        address: '2200 S Kipling St, Lakewood, CO',
        tag: 'High-Level',
      ),
      Practice(
        id: 'typical-thursday',
        clubId: widget.club.id,
        title: 'Thursday Evening',
        description: 'Intermediate players welcome.',
        dateTime: DateTime(2025, 1, 2, 20, 0), // Template: Thursday 8:00 PM (using first Thursday of 2025)
        location: 'VMAC',
        address: '5310 E 136th Ave, Thornton, CO',
        tag: 'Intermediate',
      ),
      Practice(
        id: 'typical-sunday-morning',
        clubId: widget.club.id,
        title: 'Sunday Morning',
        description: 'Weekly practice for all skill levels.',
        dateTime: DateTime(2025, 1, 5, 10, 0), // Template: Sunday 10:00 AM (using first Sunday of 2025)
        location: 'Carmody',
        address: '2200 S Kipling St, Lakewood, CO',
        tag: 'Open',
      ),
      Practice(
        id: 'typical-sunday-afternoon',
        clubId: widget.club.id,
        title: 'Sunday Afternoon',
        description: 'Afternoon session.',
        dateTime: DateTime(2025, 1, 5, 15, 0), // Template: Sunday 3:00 PM (using first Sunday of 2025)
        location: 'Carmody',
        address: '2200 S Kipling St, Lakewood, CO',
        tag: 'Open',
      ),
    ];
    
    // Sort by day of week and time
    typicalPractices.sort((a, b) {
      final dayComparison = a.dateTime.weekday.compareTo(b.dateTime.weekday);
      if (dayComparison != 0) return dayComparison;
      return a.dateTime.hour.compareTo(b.dateTime.hour);
    });
    
    return typicalPractices;
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
