/// Clubs feature - List screen showing all clubs
library;

import 'package:flutter/material.dart';
import '../../core/models/club.dart';
import '../../core/constants/app_constants.dart';
import '../../base/widgets/cards.dart';
import '../../base/widgets/buttons.dart';
import 'club_detail_screen.dart';

class ClubsListScreen extends StatefulWidget {
  const ClubsListScreen({super.key});
  
  @override
  State<ClubsListScreen> createState() => _ClubsListScreenState();
}

class _ClubsListScreenState extends State<ClubsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Club> _clubs = [];
  bool _isLoading = true;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _loadClubs();
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
      // For now, using mock data
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      _clubs = _generateMockClubs();
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading clubs: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  List<Club> _generateMockClubs() {
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
        tags: ['competitive', 'tournaments', 'training'],
      ),
      Club(
        id: '2',
        name: 'Golden Gate Underwater Hockey',
        description: 'Friendly club welcoming players of all skill levels. Weekly training and social events.',
        location: 'San Francisco, CA',
        contactEmail: 'info@gguwh.org',
        createdAt: now.subtract(const Duration(days: 200)),
        updatedAt: now,
        tags: ['beginner-friendly', 'social', 'weekly-training'],
      ),
      Club(
        id: '3',
        name: 'Austin Aquatic Warriors',
        description: 'Texas-based club with a focus on youth development and community outreach.',
        location: 'Austin, TX',
        contactEmail: 'warriors@austinuwh.com',
        createdAt: now.subtract(const Duration(days: 150)),
        updatedAt: now,
        tags: ['youth', 'community', 'development'],
      ),
    ];
  }
  
  List<Club> get _filteredClubs {
    if (_searchQuery.isEmpty) return _clubs;
    
    return _clubs.where((club) =>
      club.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      club.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      club.description.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }
  
  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
  }
  
  void _onClubTap(Club club) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClubDetailScreen(club: club),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      ),
      body: Column(
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
                            description: club.description,
                            location: club.location,
                            logoUrl: club.logoUrl,
                            tags: club.tags,
                            onTap: () => _onClubTap(club),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create club screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create club feature coming soon!')),
          );
        },
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
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
}
