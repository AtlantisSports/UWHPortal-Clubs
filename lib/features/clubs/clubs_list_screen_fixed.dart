/// Clubs feature - List screen showing all clubs with RSVP functionality
library;

import 'package:flutter/material.dart';
import '../../core/models/club.dart';
import '../../core/models/practice.dart';
import '../../core/constants/app_constants.dart';
import '../../base/widgets/cards.dart';
import '../../base/widgets/buttons.dart';
import '../../base/widgets/practice_card.dart';
import 'club_detail_screen.dart';

class ClubsListScreen extends StatefulWidget {
  const ClubsListScreen({super.key});
  
  @override
  State<ClubsListScreen> createState() => _ClubsListScreenState();
}

class _ClubsListScreenState extends State<ClubsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Club> _clubs = [];
  List<Practice> _upcomingPractices = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final String _currentUserId = 'user123'; // TODO: Get from auth service
  
  @override
  void initState() {
    super.initState();
    _loadClubs();
    _loadUpcomingPractices();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadClubs() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Replace with actual API call using ClubsService
      // For now, using mock data with practices
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      _clubs = _generateMockClubsWithPractices();
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading clubs: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _loadUpcomingPractices() async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      _upcomingPractices = _generateMockPractices();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading practices: $e')),
        );
      }
    }
  }
  
  void _handleRSVPChange(String practiceId, RSVPStatus newStatus) {
    setState(() {
      // Update practice in clubs list
      for (var club in _clubs) {
        for (var i = 0; i < club.upcomingPractices.length; i++) {
          if (club.upcomingPractices[i].id == practiceId) {
            final practice = club.upcomingPractices[i];
            final updatedRSVPs = Map<String, RSVPStatus>.from(practice.rsvpResponses);
            updatedRSVPs[_currentUserId] = newStatus;
            // In a real app, you'd update this practice through a service
            // final updatedPractice = practice.copyWith(rsvpResponses: updatedRSVPs);
            break;
          }
        }
      }
      
      // Update practice in upcoming practices list
      for (var i = 0; i < _upcomingPractices.length; i++) {
        if (_upcomingPractices[i].id == practiceId) {
          final updatedRSVPs = Map<String, RSVPStatus>.from(_upcomingPractices[i].rsvpResponses);
          updatedRSVPs[_currentUserId] = newStatus;
          _upcomingPractices[i] = _upcomingPractices[i].copyWith(rsvpResponses: updatedRSVPs);
          break;
        }
      }
    });
    
    // TODO: Send RSVP update to backend
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('RSVP updated to: ${newStatus.displayText}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  List<Club> get _filteredClubs {
    if (_searchQuery.isEmpty) {
      return _clubs;
    }
    return _clubs.where((club) {
      return club.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             club.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             club.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             club.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();
  }
  
  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }
  
  void _onClubTap(Club club) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ClubDetailScreen(
          club: club,
          currentUserId: _currentUserId,
          onRSVPChanged: _handleRSVPChange,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Clubs'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
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
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Clubs', icon: Icon(Icons.group)),
              Tab(text: 'Practices', icon: Icon(Icons.sports_hockey)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildClubsTab(),
            _buildPracticesTab(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildClubsTab() {
    return Column(
      children: [
        // Search bar
        Container(
          color: AppColors.primary,
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search clubs...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.medium,
                vertical: AppSpacing.small,
              ),
            ),
          ),
        ),
        
        // Clubs list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredClubs.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.small),
                      itemCount: _filteredClubs.length,
                      itemBuilder: (context, index) {
                        final club = _filteredClubs[index];
                        return ClubCard(
                          name: club.name,
                          location: club.location,
                          logoUrl: club.logoUrl,
                          onTap: () => _onClubTap(club),
                        );
                      },
                    ),
        ),
      ],
    );
  }
  
  Widget _buildPracticesTab() {
    return Column(
      children: [
        // Practices header
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.primary.withOpacity(0.1),
          child: Row(
            children: [
              Icon(
                Icons.sports_hockey,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Upcoming Practices',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              Text(
                '${_upcomingPractices.length} practices',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        
        // Practices list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _upcomingPractices.isEmpty
                  ? _buildNoPracticesState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _upcomingPractices.length,
                      itemBuilder: (context, index) {
                        final practice = _upcomingPractices[index];
                        return PracticeCard(
                          practice: practice,
                          currentUserId: _currentUserId,
                          onRSVPChanged: _handleRSVPChange,
                          onTap: () {
                            // TODO: Navigate to practice details
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Practice details for: ${practice.title}'),
                              ),
                            );
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }
  
  Widget _buildNoPracticesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'No upcoming practices',
            style: AppTextStyles.headline3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'Check back later for new practice sessions',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
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
            _searchQuery.isEmpty ? 'No clubs found' : 'No clubs match your search',
            style: AppTextStyles.headline3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            _searchQuery.isEmpty 
                ? 'Be the first to create a club!'
                : 'Try adjusting your search terms',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          if (_searchQuery.isEmpty)
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
      Club(
        id: '1',
        name: 'Pacific Northwest UWH',
        description: 'Competitive underwater hockey club focusing on tournament play and skill development.',
        location: 'Seattle, WA',
        contactEmail: 'contact@pnwuwh.com',
        website: 'https://pnwuwh.com',
        createdAt: now.subtract(const Duration(days: 365)),
        updatedAt: now,
        isActive: true,
        tags: const ['competitive', 'tournament', 'advanced'],
        memberCount: 24,
        upcomingPractices: [
          Practice(
            id: 'practice1',
            clubId: '1',
            title: 'Weekly Training',
            description: 'Regular practice session focusing on passing and positioning',
            dateTime: now.add(const Duration(days: 2)),
            location: 'Aquatic Center Pool',
            address: '123 Swimming Lane, Seattle, WA',
            rsvpResponses: const {
              'user123': RSVPStatus.yes,
              'user456': RSVPStatus.maybe,
              'user789': RSVPStatus.pending,
            },
          ),
        ],
      ),
      Club(
        id: '2',
        name: 'Vancouver Aquatic Club',
        description: 'Friendly community club welcoming players of all skill levels.',
        location: 'Vancouver, BC',
        contactEmail: 'info@vacuwh.ca',
        createdAt: now.subtract(const Duration(days: 200)),
        updatedAt: now,
        isActive: true,
        tags: const ['recreational', 'beginner-friendly', 'community'],
        memberCount: 18,
        upcomingPractices: [
          Practice(
            id: 'practice2',
            clubId: '2',
            title: 'Beginner Session',
            description: 'New player friendly practice with equipment provided',
            dateTime: now.add(const Duration(days: 1)),
            location: 'Community Pool',
            address: '456 Water St, Vancouver, BC',
            rsvpResponses: const {
              'user123': RSVPStatus.pending,
              'user456': RSVPStatus.yes,
            },
          ),
        ],
      ),
    ];
  }
  
  List<Practice> _generateMockPractices() {
    final now = DateTime.now();
    return [
      Practice(
        id: 'practice1',
        clubId: '1',
        title: 'Weekly Training',
        description: 'Regular practice session focusing on passing and positioning',
        dateTime: now.add(const Duration(days: 2)),
        location: 'Aquatic Center Pool',
        address: '123 Swimming Lane, Seattle, WA',
        rsvpResponses: {
          _currentUserId: RSVPStatus.yes,
          'user456': RSVPStatus.maybe,
          'user789': RSVPStatus.pending,
          'user101': RSVPStatus.no,
          'user202': RSVPStatus.yes,
        },
      ),
      Practice(
        id: 'practice2',
        clubId: '2',
        title: 'Beginner Session',
        description: 'New player friendly practice with equipment provided',
        dateTime: now.add(const Duration(days: 1)),
        location: 'Community Pool',
        address: '456 Water St, Vancouver, BC',
        rsvpResponses: {
          _currentUserId: RSVPStatus.pending,
          'user456': RSVPStatus.yes,
          'user789': RSVPStatus.maybe,
        },
      ),
      Practice(
        id: 'practice3',
        clubId: '1',
        title: 'Scrimmage Night',
        description: 'Full court scrimmage games for experienced players',
        dateTime: now.add(const Duration(days: 5)),
        location: 'Olympic Pool',
        address: '789 Champion Blvd, Seattle, WA',
        rsvpResponses: {
          _currentUserId: RSVPStatus.maybe,
          'user456': RSVPStatus.yes,
          'user789': RSVPStatus.yes,
          'user101': RSVPStatus.pending,
        },
      ),
      Practice(
        id: 'practice4',
        clubId: '2',
        title: 'Skills Workshop',
        description: 'Focused training on underwater breathing and puck handling',
        dateTime: now.add(const Duration(days: 7)),
        location: 'Training Pool',
        address: '321 Skill Ave, Vancouver, BC',
        rsvpResponses: {
          _currentUserId: RSVPStatus.no,
          'user456': RSVPStatus.pending,
          'user789': RSVPStatus.yes,
        },
      ),
    ];
  }
}
