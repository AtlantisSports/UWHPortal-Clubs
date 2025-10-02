/// Simple placeholder practice detail screen
library;

import 'dart:async';

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/participation_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/practice.dart';
import '../../core/models/club.dart';
// import '../../core/providers/participation_provider.dart';
import '../../core/providers/navigation_riverpod.dart';
import '../../core/utils/time_utils.dart';

import '../../base/widgets/rsvp_components.dart';

class PracticeDetailScreen extends ConsumerStatefulWidget {
  final Practice practice;
  final Club club;
  final String currentUserId;
  final Function(String practiceId, ParticipationStatus status)? onParticipationChanged;

  const PracticeDetailScreen({
    super.key,
    required this.practice,
    required this.club,
    required this.currentUserId,
    this.onParticipationChanged,
  });

  @override
  ConsumerState<PracticeDetailScreen> createState() => _PracticeDetailScreenState();
}

class _PracticeDetailScreenState extends ConsumerState<PracticeDetailScreen> with SingleTickerProviderStateMixin {
  // Toast state
  final bool _showToast = false;
  final String _toastMessage = '';
  final Color _toastColor = Colors.green;
  IconData? _toastIcon;
  String? _toastText;

  // Base counts for other members (excluding current user's dynamic contribution)
  int _baseYes = 0;
  int _baseMaybe = 0;
  // Randomized baseline (session-persistent per practice) to augment mock named users
  static final Map<String, Map<String, int>> _mockSummaryByPracticeId = {};
  final Random _rand = Random(42);
  int _randYes = 0;
  int _randMaybe = 0;
  int _randNo = 0;

  int _baseNo = 0;

  // Tab controller for pinned TabBar
  late final TabController _tabController;
  final GlobalKey _tabBarKey = GlobalKey();


  @override
  void initState() {
    super.initState();
    _initRandomBaseline();
    _computeBaseCounts();

    _tabController = TabController(length: 5, vsync: this);

    // Also auto-scroll when user swipes between tabs (not just taps)
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _autoScrollToTabsPosition();
      }
    });

  }

  void _computeBaseCounts() {
    // Derive base Yes/Maybe/No from the practice snapshot, excluding current user
    final uid = widget.currentUserId;
    int yes = 0, maybe = 0, no = 0;
    widget.practice.participationResponses.forEach((userId, status) {
      if (userId == uid) return;
      if (status == ParticipationStatus.yes) {
        yes++;
      } else if (status == ParticipationStatus.maybe) {
        maybe++;
      } else if (status == ParticipationStatus.no) {
        no++;
      }
    });
    setState(() {
      _baseYes = yes;
      _baseMaybe = maybe;
      _baseNo = no;
    });
  }

  void _initRandomBaseline() {
    final id = widget.practice.id;
    final cached = _mockSummaryByPracticeId[id];
    if (cached != null) {
      _randYes = cached['yes'] ?? 0;
      _randMaybe = cached['maybe'] ?? 0;
      _randNo = cached['no'] ?? 0;
      return;
    }
    final yes = 4 + _rand.nextInt(3); // 4..6
    final maybe = 1 + _rand.nextInt(5); // 1..5
    final no = 1 + _rand.nextInt(5); // 1..5
    _mockSummaryByPracticeId[id] = {'yes': yes, 'maybe': maybe, 'no': no};
    _randYes = yes;
    _randMaybe = maybe;
    _randNo = no;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _autoScrollToTabsPosition() {
    final ctx = _tabBarKey.currentContext;
    if (ctx == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    });
  }

  // Compute header title as "<DayOfWeek> <Morning/Afternoon/Evening>"
  String _computeHeaderTitle(Practice p) {
    final day = TimeUtils.formatDayName(p.dateTime.weekday);
    final h = p.dateTime.hour;
    // Use existing app convention for non-recurring practices: Morning/Afternoon/Evening buckets
    String period;
    if (h < 12) {
      period = 'Morning';
    } else if (h < 17) {
      period = 'Afternoon';
    } else {
      period = 'Evening';
    }
    return '$day $period';
  }



  // Safe parser for trailing parenthetical (recurrence) from title
  String? _getRecurringTextSafe() {
    final t = widget.practice.title.trim();
    if (t.endsWith(')')) {
      final start = t.lastIndexOf('(');
      if (start != -1 && start < t.length - 1) {
        final inner = t.substring(start + 1, t.length - 1).trim();
        if (inner.isNotEmpty) return inner;
      }
    }
    return null;
  }


  Widget _buildRSVPsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Consumer(
        builder: (context, ref, _) {
          // Live totals: base (others) + my current status and guests
          final practiceId = widget.practice.id;
          final controller = ref.read(participationControllerProvider.notifier);
          final state = ref.watch(participationControllerProvider);
          final myStatus = state.participationStatusMap[practiceId] ?? controller.getParticipationStatus(practiceId);
          final bringGuests = controller.getBringGuestState(practiceId);
          final myGuests = bringGuests ? controller.getPracticeGuests(practiceId).totalGuests : 0;
          final int myContribution = 1 + myGuests.toInt();

          final int yesTotal = _randYes + _baseYes + (myStatus == ParticipationStatus.yes ? myContribution : 0);
          final int maybeTotal = _randMaybe + _baseMaybe + (myStatus == ParticipationStatus.maybe ? myContribution : 0);
          final int noTotal = _randNo + _baseNo + (myStatus == ParticipationStatus.no ? myContribution : 0);

          // Effective Yes equals the Yes total (for now)
          final int effectiveYes = yesTotal;

          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Yes (Effective Yes)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Yes (Effective Yes)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text('$effectiveYes',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.success)),
              ]),
            ),
            const SizedBox(height: 12),
            // Maybe and No
            Row(children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Maybe',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Text('$maybeTotal',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.maybe)),
                  ]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('No',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Text('$noTotal',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.error)),
                  ]),
                ),
              ),
            ]),
          ]);
        },
      ),
    );
  }

  Future<void> _handleLocationTap(BuildContext context, String location) async {
    // Create a Google Maps search URL for the location
    final encodedLocation = Uri.encodeComponent(location);
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedLocation');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open maps')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening maps: $e')),
        );
      }
    }
  }

  bool _isPastEvent(Practice practice) {
    final now = DateTime.now();
    final practiceEndTime = practice.dateTime.add(practice.duration);
    return practiceEndTime.isBefore(now);
  }



  @override
  Widget build(BuildContext context) {
    // Check if we're on mobile web (real mobile browser)
    final isMobileWeb = kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS ||
                                  defaultTargetPlatform == TargetPlatform.android);

    final scaffoldContent = Stack(
        children: [
          PopScope(
            canPop: true, // Allow system back button to work normally
            child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () {
              // Standard back: return to previous route (usually Club Details)
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                // Fallback: go to app root and select Clubs tab
                Navigator.of(context).popUntil((route) => route.isFirst);
                ref.read(navigationControllerProvider.notifier).selectTab(3);
              }
            },
          ),
          title: Text(
            'Practice Details',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            // Notification icon
            Container(
              margin: EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textPrimary,
                  size: 28.8,
                ),
                onPressed: () {
                  // Handle notification tap
                },
              ),
            ),
            // Hamburger menu icon
            Container(
              margin: EdgeInsets.only(right: 16),
              child: IconButton(
                icon: Icon(
                  Icons.menu,
                  color: AppColors.textPrimary,
                  size: 28.8,
                ),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // Title in header (non-pinned, matches Club Details layout pattern)
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Center(
                    child: Text(
                      _computeHeaderTitle(widget.practice),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // RSVP Card for future events, Attendance card for past events
                    _isPastEvent(widget.practice)
                        ? Container(
                            margin: EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: PracticeStatusCard(
                              practice: widget.practice,
                              mode: PracticeStatusCardMode.readOnly,
                              showAttendanceStatus: true,
                            ),
                          )
                        : Container(
                            margin: EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: PracticeStatusCard(
                              practice: widget.practice,
                              mode: PracticeStatusCardMode.clickable,
                              clubId: widget.club.id,
                              onParticipationChanged: widget.onParticipationChanged != null
                                  ? (status) {
                                      widget.onParticipationChanged!(widget.practice.id, status);
                                      // Toasts are handled after commit by PracticeStatusCard; suppress here.
                                    }
                                  : null,
                              onLocationTap: () => _handleLocationTap(context, widget.practice.location),
                              // No onInfoTap since we're already in practice details
                            ),
                          ),
                  ],
                ),
              ),

              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(
                  Container(
                    color: AppColors.background,
                    child: TabBar(
                      key: _tabBarKey,
                      controller: _tabController,
                      isScrollable: false,
                      labelPadding: EdgeInsets.symmetric(horizontal: 8),
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.primary,
                      onTap: (index) {
                        if (index == 0) {
                          Future.delayed(const Duration(milliseconds: 50), _autoScrollToTabsPosition);
                        } else {
                          _autoScrollToTabsPosition();
                        }
                      },
                      tabs: const [
                        Tab(text: 'About'),
                        Tab(text: 'RSVPs'),
                        Tab(text: 'Teams'),
                        Tab(text: 'Gallery'),
                        Tab(text: 'Forum'),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildAboutTab(context),
              _buildRSVPsTab(context),
              _buildTeamsTab(context),
              _buildGalleryTab(context),
              _buildForumTab(context),
            ],
          ),
        ),
        bottomNavigationBar: Consumer(
          builder: (context, ref, child) {
            final navigationState = ref.watch(navigationControllerProvider);
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
              currentIndex: navigationState.selectedIndex,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.grey,
              onTap: (index) {
                // Always go to the root and select the tapped tab
                Navigator.of(context).popUntil((route) => route.isFirst);
                ref.read(navigationControllerProvider.notifier).selectTab(index);
              },
            );
          },
        ),
            ), // Close Scaffold
        ), // Close PopScope
          // Custom toast positioned over the content (top of screen, over AppBar)
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
      );

    // Return with or without phone frame constraints based on platform
    if (isMobileWeb) {
      // For mobile web, return scaffold directly without phone frame
      return scaffoldContent;
    } else {
      // For desktop/browser, constrain width to match phone width
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 393),
          child: scaffoldContent,
        ),
      );
    }
  }

  Widget _buildAboutTab(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recurring pattern (moved from title), when present
            if (_getRecurringTextSafe() != null)
              Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  _getRecurringTextSafe()!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

            // Description
            Container(
              width: double.infinity,
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
                    widget.practice.description,
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

  Widget _buildTeamsTab(BuildContext context) {
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
            SizedBox(height: 16),
            Text(
              'Practice Teams',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Team assignments and rosters coming soon',
              style: TextStyle(
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
            SizedBox(height: 16),
            Text(
              'Practice Gallery',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,

              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Photos and videos coming soon',
              style: TextStyle(
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
            SizedBox(height: 16),
            Text(
              'Practice Forum',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,


            ),
            SizedBox(height: 8),
            Text(
              'Discussion board coming soon',
              style: TextStyle(
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


class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyTabBarDelegate(this.child);

  @override
  double get minExtent => kToolbarHeight;

  @override
  double get maxExtent => kToolbarHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      alignment: Alignment.centerLeft,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}
