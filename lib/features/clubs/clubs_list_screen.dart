/// Clubs feature - List screen showing all clubs with RSVP functionality
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/club.dart';
import '../../core/models/practice.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/navigation_provider.dart';
import '../../base/widgets/cards.dart';
import '../../base/widgets/buttons.dart';
import 'club_detail_screen.dart';
import 'clubs_provider.dart';

class ClubsListScreen extends StatefulWidget {
  const ClubsListScreen({super.key});
  
  @override
  State<ClubsListScreen> createState() => _ClubsListScreenState();
}

class _ClubsListScreenState extends State<ClubsListScreen> {
  final String _currentUserId = 'user123'; // TODO: Get from auth service
  
  // Internal navigation state
  Club? _selectedClub;
  bool _showingClubDetail = false;
  
  // Toast state
  bool _showToast = false;
  String _toastMessage = '';
  Color _toastColor = Colors.green;
  IconData? _toastIcon;
  String? _toastText;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClubsProvider>().loadClubs();
      
      // Register clubs tab handler for reset functionality
      final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
      navigationProvider.registerTabBackHandler(3, _resetToClubsList);
    });
  }
  
  @override
  void dispose() {
    // Unregister tab handler when widget is disposed
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    navigationProvider.unregisterTabBackHandler(3);
    super.dispose();
  }
  
  void _resetToClubsList() {
    if (_showingClubDetail) {
      setState(() {
        _selectedClub = null;
        _showingClubDetail = false;
      });
    }
  }
  
  void _handleRSVPChange(String practiceId, RSVPStatus newStatus) {
    context.read<ClubsProvider>().handleRSVPChange(practiceId, newStatus);
    
    // Show confirmation message
    if (mounted) {
      // Prepare toast content based on RSVP status
      String message = 'RSVP updated to: ${newStatus.displayText}';
      Color toastColor = newStatus.color;
      
      if (newStatus == RSVPStatus.maybe) {
        _showCustomToast(message, toastColor, Icons.help);
      } else {
        _showCustomToast(message, toastColor, newStatus.overlayIcon);
      }
    }
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

  void _onClubTap(Club club) {
    setState(() {
      _selectedClub = club;
      _showingClubDetail = true;
    });
  }
  
  void _navigateBackToList() {
    setState(() {
      _selectedClub = null;
      _showingClubDetail = false;
    });
  }
  
  /// Get the next upcoming practice for a club
  Practice? _getNextPractice(Club club) {
    if (club.upcomingPractices.isEmpty) return null;
    
    final now = DateTime.now();
    final upcomingPractices = club.upcomingPractices
        .where((practice) => practice.dateTime.isAfter(now))
        .toList();
    
    if (upcomingPractices.isEmpty) return null;
    
    // Sort by date and return the earliest
    upcomingPractices.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return upcomingPractices.first;
  }
  
  /// Open map for practice location
  void _openMapForPractice(Practice practice) {
    // TODO: Implement map opening functionality
    // For now, show a placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening map for: ${practice.address}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show club detail if selected
    if (_showingClubDetail && _selectedClub != null) {
      return ClubDetailScreen(
        club: _selectedClub!,
        currentUserId: _currentUserId,
        onRSVPChanged: _handleRSVPChange,
        onBackPressed: _navigateBackToList,
      );
    }
    
    // Show clubs list
    return DefaultTabController(
      length: 2,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text('Clubs'),
              backgroundColor: Colors.grey[100],
              foregroundColor: Colors.black87,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    size: 28.8, // 20% larger than default 24
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.menu,
                    size: 28.8, // 20% larger than default 24
                  ),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
              ],
              bottom: const TabBar(
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.black54,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: 'My Clubs', icon: Icon(Icons.group)),
                  Tab(text: 'Find a club', icon: Icon(Icons.search)),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildClubsTab(),
                _buildFindClubTab(),
              ],
            ),
          ),
          // Custom toast positioned over the tab area
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
        ],
      ),
    );
  }
  
  Widget _buildClubsTab() {
    return Consumer<ClubsProvider>(
      builder: (context, clubsProvider, child) {
        return Column(
          children: [
            // Clubs list
            Expanded(
              child: clubsProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : clubsProvider.clubs.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppSpacing.small),
                          itemCount: clubsProvider.clubs.length,
                          itemBuilder: (context, index) {
                            final club = clubsProvider.clubs[index];
                            final nextPractice = _getNextPractice(club);
                            final currentRSVP = nextPractice != null 
                                ? nextPractice.getRSVPStatus(_currentUserId)
                                : RSVPStatus.pending;
                            
                            return ClubCard(
                              name: club.name,
                              location: club.location,
                              logoUrl: club.logoUrl,
                              nextPractice: nextPractice,
                              currentRSVP: currentRSVP,
                              allPractices: club.upcomingPractices, // Add all practices for dropdown
                              onRSVPChanged: (status) {
                                if (nextPractice != null) {
                                  _handleRSVPChange(nextPractice.id, status);
                                }
                              },
                              onTap: () => _onClubTap(club),
                              onLocationTap: nextPractice != null ? () {
                                _openMapForPractice(nextPractice);
                              } : null,
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildFindClubTab() {
    return Column(
      children: [
        // Find club header
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.primary.withValues(alpha: 0.1),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Find a Club',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        
        // Find club placeholder
        Expanded(
          child: _buildFindClubPlaceholder(),
        ),
      ],
    );
  }
  
  Widget _buildFindClubPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'Find Clubs Near You',
            style: AppTextStyles.headline3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'This feature is coming soon!\nYou\'ll be able to search and discover clubs in your area.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          PrimaryButton(
            text: 'Get Notified',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('We\'ll notify you when this feature is available!'),
                  duration: Duration(seconds: 4),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_off,
            size: 64,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'No clubs found',
            style: AppTextStyles.headline3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'Be the first to create a club!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          PrimaryButton(
            text: 'Create Club',
            onPressed: () {
              // TODO: Navigate to create club screen
            },
          ),
        ],
      ),
    );
  }
  
  List<Club> _generateMockClubsWithPractices() {
    final now = DateTime.now();
    return [
      // Denver UWH - from portal-rsvp-demo repository
      Club(
        id: 'denver-uwh',
        name: 'Denver UWH',
        description: 'Denver Underwater Hockey - Multiple practice sessions throughout the week at VMAC and Carmody facilities.',
        location: 'Denver, CO',
        contactEmail: 'contact@denveruwh.com',
        website: 'https://www.meetup.com/denver-underwater-hockey/',
        createdAt: now.subtract(const Duration(days: 500)),
        updatedAt: now,
        isActive: true,
        tags: const ['competitive', 'beginner-friendly', 'multi-location'],
        memberCount: 42,
        upcomingPractices: [
          Practice(
            id: 'denver-monday',
            clubId: 'denver-uwh',
            title: 'Monday Practice',
            description: 'Beginner-friendly; arrive 10 min early.',
            dateTime: _getNextPracticeDate(now, DateTime.monday, 20, 15), // 8:15 PM
            location: 'VMAC',
            address: '5310 E 136th Ave, Thornton, CO',
            rsvpResponses: {
              'user123': RSVPStatus.pending, // Current user starts with no selection
              'user456': RSVPStatus.maybe,
              'user789': RSVPStatus.pending,
              'user101': RSVPStatus.yes,
              'user202': RSVPStatus.no,
            },
          ),
          Practice(
            id: 'denver-wednesday',
            clubId: 'denver-uwh',
            title: 'Wednesday Practice',
            description: 'Shallow end reserved. High-level participants only.',
            dateTime: _getNextPracticeDate(now, DateTime.wednesday, 19, 0), // 7:00 PM
            location: 'Carmody',
            address: '2200 S Kipling St, Lakewood, CO',
            rsvpResponses: {
              'user123': RSVPStatus.pending,
              'user456': RSVPStatus.yes,
              'user789': RSVPStatus.maybe,
              'user101': RSVPStatus.no,
            },
          ),
          Practice(
            id: 'denver-thursday',
            clubId: 'denver-uwh',
            title: 'Thursday Scrimmage',
            description: 'Scrimmage heavy. High-level participants only.',
            dateTime: _getNextPracticeDate(now, DateTime.thursday, 20, 15), // 8:15 PM
            location: 'VMAC',
            address: '5310 E 136th Ave, Thornton, CO',
            rsvpResponses: {
              'user123': RSVPStatus.pending, // Current user starts with no selection
              'user456': RSVPStatus.yes,
              'user789': RSVPStatus.yes,
              'user101': RSVPStatus.pending,
              'user202': RSVPStatus.yes,
            },
          ),
          Practice(
            id: 'denver-sunday-morning',
            clubId: 'denver-uwh',
            title: 'Sunday Morning Training',
            description: 'Drills + conditioning.',
            dateTime: _getNextPracticeDate(now, DateTime.sunday, 10, 0), // 10:00 AM
            location: 'VMAC',
            address: '5310 E 136th Ave, Thornton, CO',
            rsvpResponses: {
              'user123': RSVPStatus.pending, // Current user starts with no selection
              'user456': RSVPStatus.pending,
              'user789': RSVPStatus.yes,
              'user101': RSVPStatus.maybe,
            },
          ),
          Practice(
            id: 'denver-sunday-afternoon',
            clubId: 'denver-uwh',
            title: 'Sunday Afternoon Session',
            description: 'Afternoon session.',
            dateTime: _getNextPracticeDate(now, DateTime.sunday, 15, 0), // 3:00 PM
            location: 'Carmody',
            address: '2200 S Kipling St, Lakewood, CO',
            rsvpResponses: {
              'user123': RSVPStatus.pending, // Current user starts with no selection
              'user456': RSVPStatus.yes,
              'user789': RSVPStatus.maybe,
            },
          ),
        ],
      ),
      // Sydney Kings UWH - from portal-rsvp-demo repository
      Club(
        id: 'sydney-uwh',
        name: 'Sydney Kings',
        description: 'Sydney Kings Underwater Hockey Club - All levels welcome; bring fins & mouthguard.',
        location: 'Sydney, NSW',
        contactEmail: 'info@sydneykingsuwh.com.au',
        website: 'https://nswunderwaterhockey.com/clubs/sydney',
        createdAt: now.subtract(const Duration(days: 300)),
        updatedAt: now,
        isActive: true,
        tags: const ['all-levels', 'community', 'friday-night'],
        memberCount: 28,
        upcomingPractices: [
          Practice(
            id: 'sydney-friday',
            clubId: 'sydney-uwh',
            title: 'Friday Night Practice',
            description: 'All levels; bring fins & mouthguard.',
            dateTime: _getNextPracticeDate(now, DateTime.friday, 19, 0), // 7:00 PM
            location: 'Ryde Pool',
            address: '504 Victoria Rd, Ryde, NSW',
            rsvpResponses: {
              'user123': RSVPStatus.pending,
              'user456': RSVPStatus.yes,
              'user789': RSVPStatus.maybe,
              'user101': RSVPStatus.yes,
              'user202': RSVPStatus.no,
              'user303': RSVPStatus.yes,
            },
          ),
        ],
      ),
    ];
  }
  
  // Helper method to calculate next practice date for a given day of week
  DateTime _getNextPracticeDate(DateTime now, int targetDayOfWeek, int hour, int minute) {
    int daysToAdd = targetDayOfWeek - now.weekday;
    if (daysToAdd <= 0) {
      daysToAdd += 7; // Next week
    }
    
    DateTime targetDate = now.add(Duration(days: daysToAdd));
    return DateTime(targetDate.year, targetDate.month, targetDate.day, hour, minute);
  }
  
  List<Practice> _generateMockPractices() {
    final now = DateTime.now();
    return [
      // Denver UWH practices
      Practice(
        id: 'denver-monday',
        clubId: 'denver-uwh',
        title: 'Monday Practice',
        description: 'Beginner-friendly; arrive 10 min early.',
        dateTime: _getNextPracticeDate(now, DateTime.monday, 20, 15), // 8:15 PM
        location: 'VMAC',
        address: '5310 E 136th Ave, Thornton, CO',
        rsvpResponses: {
          _currentUserId: RSVPStatus.pending, // Current user starts with no selection
          'user456': RSVPStatus.maybe,
          'user789': RSVPStatus.pending,
          'user101': RSVPStatus.yes,
          'user202': RSVPStatus.no,
        },
      ),
      Practice(
        id: 'denver-wednesday',
        clubId: 'denver-uwh',
        title: 'Wednesday Practice',
        description: 'Shallow end reserved. High-level participants only.',
        dateTime: _getNextPracticeDate(now, DateTime.wednesday, 19, 0), // 7:00 PM
        location: 'Carmody',
        address: '2200 S Kipling St, Lakewood, CO',
        rsvpResponses: {
          _currentUserId: RSVPStatus.pending,
          'user456': RSVPStatus.yes,
          'user789': RSVPStatus.maybe,
          'user101': RSVPStatus.no,
        },
      ),
      Practice(
        id: 'denver-thursday',
        clubId: 'denver-uwh',
        title: 'Thursday Scrimmage',
        description: 'Scrimmage heavy. High-level participants only.',
        dateTime: _getNextPracticeDate(now, DateTime.thursday, 20, 15), // 8:15 PM
        location: 'VMAC',
        address: '5310 E 136th Ave, Thornton, CO',
        rsvpResponses: {
          _currentUserId: RSVPStatus.maybe,
          'user456': RSVPStatus.yes,
          'user789': RSVPStatus.yes,
          'user101': RSVPStatus.pending,
          'user202': RSVPStatus.yes,
        },
      ),
      Practice(
        id: 'denver-sunday-morning',
        clubId: 'denver-uwh',
        title: 'Sunday Morning Training',
        description: 'Drills + conditioning.',
        dateTime: _getNextPracticeDate(now, DateTime.sunday, 10, 0), // 10:00 AM
        location: 'VMAC',
        address: '5310 E 136th Ave, Thornton, CO',
        rsvpResponses: {
          _currentUserId: RSVPStatus.pending, // Current user starts with no selection
          'user456': RSVPStatus.pending,
          'user789': RSVPStatus.yes,
          'user101': RSVPStatus.maybe,
        },
      ),
      Practice(
        id: 'sydney-friday',
        clubId: 'sydney-uwh',
        title: 'Friday Night Practice',
        description: 'All levels; bring fins & mouthguard.',
        dateTime: _getNextPracticeDate(now, DateTime.friday, 19, 0), // 7:00 PM
        location: 'Ryde Pool',
        address: '504 Victoria Rd, Ryde, NSW',
        rsvpResponses: {
          _currentUserId: RSVPStatus.pending,
          'user456': RSVPStatus.yes,
          'user789': RSVPStatus.maybe,
          'user101': RSVPStatus.yes,
          'user202': RSVPStatus.no,
        },
      ),
    ];
  }
}
