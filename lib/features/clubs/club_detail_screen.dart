/// Clubs feature - Detail screen for individual club
library;

import 'package:flutter/material.dart';
import '../../core/models/club.dart';
import '../../core/models/practice.dart';
import '../../core/constants/app_constants.dart';
import '../../base/widgets/buttons.dart';

class ClubDetailScreen extends StatefulWidget {
  final Club club;
  final String currentUserId;
  final Function(String practiceId, RSVPStatus status)? onRSVPChanged;
  
  const ClubDetailScreen({
    super.key,
    required this.club,
    required this.currentUserId,
    this.onRSVPChanged,
  });
  
  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isMember = false; // TODO: Get from actual membership status
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      
      setState(() => _isMember = !_isMember);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isMember ? 'Joined club successfully!' : 'Left club successfully!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
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
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.club.name,
                style: AppTextStyles.headline3.copyWith(color: Colors.white),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                  ),
                ),
                child: widget.club.logoUrl != null
                    ? Image.network(
                        widget.club.logoUrl!,
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.group,
                        size: 100,
                        color: Colors.white54,
                      ),
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            // Club info header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        widget.club.location,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    widget.club.description,
                    style: AppTextStyles.bodyMedium,
                  ),
                  if (widget.club.tags.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.medium),
                    Wrap(
                      spacing: AppSpacing.small,
                      runSpacing: AppSpacing.xs,
                      children: widget.club.tags.map((tag) => Chip(
                        label: Text(
                          tag,
                          style: AppTextStyles.caption,
                        ),
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.medium),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          text: _isMember ? 'Leave Club' : 'Join Club',
                          onPressed: _toggleMembership,
                          isLoading: _isLoading,
                          icon: _isMember ? Icons.exit_to_app : Icons.group_add,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.small),
                      SecondaryButton(
                        text: 'Contact',
                        onPressed: () {
                          // TODO: Open email or contact form
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Contact feature coming soon!')),
                          );
                        },
                        icon: Icons.email,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Tabs
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'Events'),
                  Tab(text: 'Members'),
                  Tab(text: 'About'),
                ],
              ),
            ),
            
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEventsTab(),
                  _buildMembersTab(),
                  _buildAboutTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEventsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event,
            size: 64,
            color: AppColors.textDisabled,
          ),
          SizedBox(height: AppSpacing.medium),
          Text(
            'No upcoming events',
            style: AppTextStyles.headline3,
          ),
          SizedBox(height: AppSpacing.small),
          Text(
            'Events will appear here when available',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  Widget _buildMembersTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people,
            size: 64,
            color: AppColors.textDisabled,
          ),
          SizedBox(height: AppSpacing.medium),
          Text(
            'Members list',
            style: AppTextStyles.headline3,
          ),
          SizedBox(height: AppSpacing.small),
          Text(
            'Member information coming soon',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAboutTab() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About ${widget.club.name}',
            style: AppTextStyles.headline3,
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            widget.club.description,
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.large),
          
          // Contact information
          Text(
            'Contact Information',
            style: AppTextStyles.headline3,
          ),
          const SizedBox(height: AppSpacing.medium),
          
          ListTile(
            leading: const Icon(Icons.email, color: AppColors.primary),
            title: Text(widget.club.contactEmail),
            contentPadding: EdgeInsets.zero,
            onTap: () {
              // TODO: Open email client
            },
          ),
          
          if (widget.club.website != null)
            ListTile(
              leading: const Icon(Icons.web, color: AppColors.primary),
              title: Text(widget.club.website!),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                // TODO: Open website
              },
            ),
          
          ListTile(
            leading: const Icon(Icons.location_on, color: AppColors.primary),
            title: Text(widget.club.location),
            contentPadding: EdgeInsets.zero,
            onTap: () {
              // TODO: Open maps
            },
          ),
        ],
      ),
    );
  }
}
