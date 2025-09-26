/// Clubs feature - List screen showing all clubs with RSVP functionality
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/club.dart';
import '../../core/models/practice.dart';
import '../../core/models/practice_pattern.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/navigation_provider.dart';
import '../../core/providers/participation_provider.dart';
import '../../core/services/schedule_service.dart';
import '../../core/di/service_locator.dart';
import '../../base/widgets/cards.dart';
import '../../base/widgets/buttons.dart';
import 'club_detail_screen.dart';
import 'practice_detail_screen.dart';
import 'clubs_provider.dart';

class ClubsListScreen extends StatefulWidget {
  const ClubsListScreen({super.key});

  @override
  State<ClubsListScreen> createState() => _ClubsListScreenState();
}

class _ClubsListScreenState extends State<ClubsListScreen> {
  // Use UserService for consistent user ID
  String get _currentUserId => ServiceLocator.userService.currentUserId;
  final ScheduleService _scheduleService = ServiceLocator.scheduleService;
  final ScrollController _scrollController = ScrollController();

  // Global keys for measuring card heights dynamically
  final List<GlobalKey> _cardKeys = [];

  // Internal navigation state
  Club? _selectedClub;
  bool _showingClubDetail = false;

  // Toast state
  bool _showToast = false;
  String _toastMessage = '';
  Color _toastColor = Colors.green;
  IconData? _toastIcon;
  String? _toastText;
  bool _toastPersistent = false;


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
    _scrollController.dispose();
    super.dispose();
  }

  bool _resetToClubsList() {
    // Only reset if we're actually showing club detail
    if (_showingClubDetail) {
      setState(() {
        _selectedClub = null;
        _showingClubDetail = false;
      });
      debugPrint('DEBUG: Clubs handler - reset from detail to list');
      return true; // We handled internal navigation
    } else {
      debugPrint('DEBUG: Clubs handler - already showing list, no reset needed');
      return false; // No internal navigation to handle
    }
  }

  void _handleRSVPChange(String practiceId, ParticipationStatus newStatus) {
    // Use centralized participation provider
    final participationProvider = context.read<ParticipationProvider>();

    // Find the club that has this practice
    final clubsProvider = context.read<ClubsProvider>();
    String? clubId;
    for (final club in clubsProvider.clubs) {
      for (final practice in club.upcomingPractices) {
        if (practice.id == practiceId) {
          clubId = club.id;
          break;
        }
      }
      if (clubId != null) break;
    }

    if (clubId != null) {
      // Enforce Maybe limit (max 10) for list-card quick RSVP
      if (newStatus == ParticipationStatus.maybe &&
          participationProvider.getParticipationStatus(practiceId) != ParticipationStatus.maybe &&
          participationProvider.totalMaybeCount >= 10) {
        _showCustomToast(
          'Only 10 Maybe RSVPs are allowed, they are really not that useful and are basically equivalent to not providing an RSVP at all',
          const Color(0xFFF59E0B),
          Icons.help_outline,
          persistent: true,
        );
        return;
      }
      participationProvider.updateParticipationStatus(clubId, practiceId, newStatus);
    }

    // Show confirmation message
    if (mounted) {
      // Prepare toast content based on participation status
      String message = 'RSVP updated to: ${newStatus.displayText}';
      Color toastColor = newStatus.color;

      if (newStatus == ParticipationStatus.maybe) {
        _showCustomToast(message, toastColor, Icons.help);
      } else {
        _showCustomToast(message, toastColor, newStatus.overlayIcon);
      }
    }
  }

  void _showCustomToast(String message, Color color, IconData icon, {bool persistent = false}) {
    setState(() {
      _toastMessage = message;
      _toastColor = color;
      _toastIcon = icon;
      _toastText = null;
      _toastPersistent = persistent;
      _showToast = true;
    });

    // Auto-hide only if not persistent
    if (!persistent) {
      Timer(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _showToast = false;
          });
        }
      });
    }
  }

  void _onClubTap(Club club) {
    setState(() {
      _selectedClub = club;
      _showingClubDetail = true;
    });
  }

  void _onPracticeInfoTap(Club club, Practice practice) {
    // Navigate directly to Practice Detail Screen instead of Club Detail
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PracticeDetailScreen(
          practice: practice,
          club: club,
          currentUserId: _currentUserId,
          onParticipationChanged: (practiceId, status) {
            _handleRSVPChange(practiceId, status);
          },
        ),
      ),
    );
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

  /// Get recurring/template practices for club card display using ScheduleService
  List<PracticePattern> _getRecurringPractices(Club club) {
    return _scheduleService.getPracticePatterns(club.id);
  }

  /// Auto-scroll to ensure expanded dropdown content is visible
  void _ensureCardVisible(int cardIndex) {
    if (!_scrollController.hasClients) return;

    // Use addPostFrameCallback to ensure the expansion animation completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      // Safety check for card keys list bounds
      if (cardIndex >= _cardKeys.length) {
        return;
      }

      // Find the actual card widget using its global key
      final GlobalKey cardKey = _cardKeys[cardIndex];
      final BuildContext? cardContext = cardKey.currentContext;

      if (cardContext == null) {
        return;
      }

      final RenderBox? cardRenderBox = cardContext.findRenderObject() as RenderBox?;

      if (cardRenderBox == null) {
        return;
      }

      // Simple approach: use Scrollable.ensureVisible which handles all the math
      Scrollable.ensureVisible(
        cardContext,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        alignment: 0.1, // Show card near bottom of viewport (10% from bottom)
      );
    });
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
        onParticipationChanged: _handleRSVPChange,
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
              top: MediaQuery.of(context).padding.top + 12,
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
                      Expanded(
                        child: Text(
                          _toastMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (_toastPersistent)
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 20),
                          onPressed: () {
                            setState(() {
                              _showToast = false;
                              _toastPersistent = false;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
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
        // Ensure we have enough keys for all clubs - with safety checks
        if (clubsProvider.clubs.isNotEmpty) {
          while (_cardKeys.length < clubsProvider.clubs.length) {
            _cardKeys.add(GlobalKey());
          }
        }

        return Column(
          children: [
            // Clubs list
            Expanded(
              child: clubsProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : clubsProvider.clubs.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(AppSpacing.small),
                          itemCount: clubsProvider.clubs.length,
                          itemBuilder: (context, index) {
                            final club = clubsProvider.clubs[index];
                            final nextPractice = _getNextPractice(club);
                            final currentParticipationStatus = nextPractice != null
                                ? nextPractice.getParticipationStatus(_currentUserId)
                                : ParticipationStatus.blank;

                            return ClubCard(
                              key: index < _cardKeys.length ? _cardKeys[index] : null,
                              name: club.name,
                              location: club.location,
                              logoUrl: club.logoUrl,
                              nextPractice: nextPractice,
                              currentParticipationStatus: currentParticipationStatus,
                              allPractices: _getRecurringPractices(club), // Use recurring practices instead of upcoming
                              clubId: club.id, // Pass clubId for RSVP synchronization
                              onParticipationChanged: (status) {
                                if (nextPractice != null) {
                                  _handleRSVPChange(nextPractice.id, status);
                                }
                              },
                              onTap: () => _onClubTap(club),
                              onLocationTap: nextPractice != null ? () {
                                _openMapForPractice(nextPractice);
                              } : null,
                              onPracticeInfoTap: nextPractice != null ? () {
                                _onPracticeInfoTap(club, nextPractice);
                              } : null,
                              onRecurringPracticesExpanded: () => _ensureCardVisible(index),
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
            text: 'Create Club',
            onPressed: () {
              // TODO: Navigate to create club screen
            },
          ),
          const SizedBox(height: AppSpacing.medium),
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
            'Join your first club!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
