/// Clubs feature - List screen showing all clubs with RSVP functionality
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/club.dart';
import '../../core/models/practice.dart';
import '../../core/models/practice_pattern.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/navigation_riverpod.dart';
import '../../core/di/riverpod_providers.dart';
import '../../base/widgets/cards.dart';
import '../../base/widgets/buttons.dart';
import 'club_detail_screen.dart';
import 'practice_detail_screen.dart';
import '../../core/providers/clubs_riverpod.dart';

class ClubsListScreen extends ConsumerStatefulWidget {
  const ClubsListScreen({super.key});

  @override
  ConsumerState<ClubsListScreen> createState() => _ClubsListScreenState();
}

class _ClubsListScreenState extends ConsumerState<ClubsListScreen> {
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
      ref.read(clubsControllerProvider.notifier).loadClubs();

      // Register clubs tab handler for reset functionality
      ref.read(navigationControllerProvider.notifier).registerTabBackHandler(3, _resetToClubsList);
    });
  }

  @override
  void dispose() {
    // Unregister tab handler when widget is disposed
    ref.read(navigationControllerProvider.notifier).unregisterTabBackHandler(3);
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
    // Riverpod handles participation updates in UI components now.
    // Keep a toast for feedback.
    if (!mounted) return;
    final message = 'RSVP updated to: ${newStatus.displayText}';
    final toastColor = newStatus.color;
    if (newStatus == ParticipationStatus.maybe) {
      _showCustomToast(message, toastColor, Icons.help);
    } else {
      _showCustomToast(message, toastColor, newStatus.overlayIcon);
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
          currentUserId: ref.read(userServiceProvider).currentUserId,
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
    final scheduleService = ref.read(scheduleServiceProvider);
    return scheduleService.getPracticePatterns(club.id);
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
        currentUserId: ref.read(userServiceProvider).currentUserId,
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
    final clubsState = ref.watch(clubsControllerProvider);
    final userService = ref.watch(userServiceProvider);

    // Ensure we have enough keys for all clubs - with safety checks
    if (clubsState.clubs.isNotEmpty) {
      while (_cardKeys.length < clubsState.clubs.length) {
        _cardKeys.add(GlobalKey());
      }
    }

    return Column(
      children: [
        // Clubs list
        Expanded(
          child: clubsState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : clubsState.clubs.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(AppSpacing.small),
                      itemCount: clubsState.clubs.length,
                      itemBuilder: (context, index) {
                        final club = clubsState.clubs[index];
                        final nextPractice = _getNextPractice(club);
                        final currentParticipationStatus = nextPractice != null
                            ? nextPractice.getParticipationStatus(userService.currentUserId)
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
