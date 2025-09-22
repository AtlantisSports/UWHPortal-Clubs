

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/club.dart';
import '../../core/models/practice.dart';
import '../../core/models/practice_pattern.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/participation_provider.dart';
import '../../core/services/schedule_service.dart';
import '../../core/di/service_locator.dart';
import '../../core/providers/navigation_provider.dart';
import '../../core/utils/responsive_helper.dart';
import '../../base/widgets/buttons.dart';
import '../../base/widgets/rsvp_components.dart';
import '../../base/widgets/calendar_widget.dart';
import '../../base/widgets/practice_filter_modal.dart';
import '../../base/widgets/recurring_practices_widget.dart';
import '../bulk_rsvp/bulk_rsvp_screen.dart';
import 'practice_detail_screen.dart';

class ClubDetailScreen extends StatefulWidget {
  final Club club;
  final String currentUserId;
  final Function(String practiceId, ParticipationStatus status)? onParticipationChanged;
  final VoidCallback? onBackPressed;
  
  const ClubDetailScreen({
    super.key,
    required this.club,
    required this.currentUserId,
    this.onParticipationChanged,
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
  final GlobalKey _recurringPracticesKey = GlobalKey(); // Add GlobalKey for recurring practices container
  final ScheduleService _scheduleService = ServiceLocator.scheduleService;
  final bool _isMember = false;
  bool _isLoading = false;
  bool _showingBulkRSVP = false; // Temporarily disabled
  bool _isShowingPracticeFilterModal = false;
  bool _isRecurringPracticesExpanded = false; // Track expansion state for recurring practices dropdown
  
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
    _tabController = TabController(length: 5, vsync: this);
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
          onParticipationChanged: (practiceId, status) {
            // Update the participation provider to ensure calendar syncs
            final participationProvider = Provider.of<ParticipationProvider>(context, listen: false);
            participationProvider.updateParticipationStatus(widget.club.id, practiceId, status);
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
  
  Set<String> _getAvailableLocations() {
    final availableLocations = <String>{};
    for (final practice in widget.club.upcomingPractices) {
      if (practice.location.isNotEmpty) {
        availableLocations.add(practice.location);
      }
    }
    return availableLocations;
  }
  
  void _showPracticeFilterModal() {
    setState(() {
      _isShowingPracticeFilterModal = true;
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
    const tabBarHeight = 48.0; // The tab bar itself (RSVP, Recurring Practices, etc.)
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
                    
                    // Initialize participation status if needed (async call deferred)
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      participationProvider.initializePracticeParticipation(nextPractice);
                    });
                    
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
                        PracticeStatusCard(
                          practice: nextPractice,
                          mode: PracticeStatusCardMode.clickable,
                          clubId: widget.club.id,
                          onParticipationChanged: (status) {
                            // Show toast when RSVP changes
                            String message = 'RSVP updated to: ${status.displayText}';
                            Color toastColor = status.color;
                            if (status == ParticipationStatus.maybe) {
                              _showCustomToast(message, toastColor, Icons.help);
                            } else {
                              _showCustomToast(message, toastColor, status.overlayIcon);
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
                          Tab(text: 'Groups'),
                          Tab(text: 'About'),
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
                            _buildGroupsTab(context),
                            _buildAboutTab(context),
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
        if (_isShowingPracticeFilterModal) ...[
          _buildModalBackdrop(() => setState(() => _isShowingPracticeFilterModal = false)),
          _buildPracticeFilterModal(),
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

  Widget _buildPracticeFilterModal() {
    return _buildModalContainer(
      child: PracticeFilterModal(
        availableLevels: _getAvailableLevels(),
        availableLocations: _getAvailableLocations(),
        club: widget.club,
        onFiltersChanged: () {
          setState(() => _isShowingPracticeFilterModal = false);
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
          // Bulk RSVP Button - Now Enabled
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BulkRSVPScreen(
                      club: widget.club,
                      currentUserId: widget.currentUserId,
                    ),
                  ),
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
          
          const SizedBox(height: 16),
          
          // Practice Calendar
          Expanded(
            child: Consumer<ParticipationProvider>(
              builder: (context, participationProvider, child) {
                return PracticeCalendar(
                  club: widget.club,
                  onPracticeSelected: _handlePracticeSelected,
                  participationProvider: participationProvider,
                  onShowLevelFilter: _showPracticeFilterModal,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Get recurring/template practices for the club using ScheduleService
  List<PracticePattern> _getRecurringPractices() {
    return _scheduleService.getPracticePatterns(widget.club.id);
  }

  Widget _buildGroupsTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups,
              size: 48,
              color: AppColors.textDisabled,
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            Text(
              'Club Groups',
              style: AppTextStyles.headline3.copyWith(
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context, mobileSpacing: 4.0)),
            Text(
              'Training groups and teams coming soon',
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

  /// Auto-scroll to show the recurring practices when expanded
  void _scrollToRecurringPractices() {
    if (!_scrollController.hasClients) return;
    
    // Wait for the expansion animation to complete
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted || !_scrollController.hasClients) return;
      
      // Simple approach: scroll down by a fixed amount to show the expanded content
      final currentOffset = _scrollController.offset;
      final maxOffset = _scrollController.position.maxScrollExtent;
      final targetOffset = (currentOffset + 200).clamp(0.0, maxOffset);
      
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Widget _buildAboutTab(BuildContext context) {
    final recurringPractices = _getRecurringPractices();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Recurring Practices Dropdown
            RecurringPracticesWidget(
              key: _recurringPracticesKey,
              practices: recurringPractices,
              isExpanded: _isRecurringPracticesExpanded,
              onToggle: () {
                setState(() {
                  _isRecurringPracticesExpanded = !_isRecurringPracticesExpanded;
                });
                
                // Auto-scroll to show the expanded recurring practices list
                if (_isRecurringPracticesExpanded) {
                  _scrollToRecurringPractices();
                }
              },
            ),
            
            const SizedBox(height: 24),
            
            // About content placeholder
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: AppColors.textDisabled,
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context)),
                  Text(
                    'About ${widget.club.name}',
                    style: AppTextStyles.headline3.copyWith(
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context, mobileSpacing: 4.0)),
                  Text(
                    'Club information and history coming soon',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
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
