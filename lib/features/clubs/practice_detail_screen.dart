/// Simple placeholder practice detail screen
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/practice.dart';
import '../../core/models/club.dart';
import '../../core/providers/rsvp_provider.dart';
import '../../core/providers/navigation_provider.dart';
import '../../base/widgets/phone_frame.dart';
import '../../base/widgets/rsvp_components.dart';
import 'club_detail_screen.dart';

class PracticeDetailScreen extends StatefulWidget {
  final Practice practice;
  final Club club;
  final String currentUserId;
  final Function(String practiceId, RSVPStatus status)? onRSVPChanged;

  const PracticeDetailScreen({
    super.key,
    required this.practice,
    required this.club,
    required this.currentUserId,
    this.onRSVPChanged,
  });

  @override
  State<PracticeDetailScreen> createState() => _PracticeDetailScreenState();
}

class _PracticeDetailScreenState extends State<PracticeDetailScreen> {
  // Toast state
  bool _showToast = false;
  String _toastMessage = '';
  Color _toastColor = Colors.green;
  IconData? _toastIcon;
  String? _toastText;

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

  int _calculateAttendanceCount(Practice practice) {
    return practice.rsvpResponses.values
        .where((status) => status == RSVPStatus.yes)
        .length;
  }

  bool _getUserAttendanceStatus(Practice practice) {
    // For past practices, use the same logic as calendar widget to ensure consistency
    if (_isPastEvent(practice)) {
      // Use same hash-based mock data as calendar widget
      final practiceDate = DateTime(practice.dateTime.year, practice.dateTime.month, practice.dateTime.day);
      final hash = practiceDate.hashCode + practice.location.hashCode;
      return hash % 3 != 0; // Same logic as calendar: hash % 3 == 0 means notAttended, else attended
    }
    
    // For future practices, this method shouldn't be called, but return false as fallback
    return false;
  }

  Widget _buildAttendanceIndicator(bool attended) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: attended ? AppColors.success : AppColors.error,
      ),
      child: Icon(
        attended ? Icons.check : Icons.close,
        color: Colors.white,
        size: 14,
      ),
    );
  }

  String _formatTimeRange(DateTime startTime, Duration duration) {
    final endTime = startTime.add(duration);
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final minuteStr = minute == 0 ? '' : ':${minute.toString().padLeft(2, '0')}';
    return '$displayHour$minuteStr $amPm';
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
  Widget build(BuildContext context) {
    return PhoneFrameWrapper(
      onBackPressed: () => Navigator.of(context).pop(),
      child: Stack(
        children: [
          PopScope(
            canPop: true, // Allow system back button to work normally
            child: DefaultTabController(
              length: 3, // About, Gallery, and Forum tabs
          child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () {
              // Navigate back to Club Details page with proper mobile layout and app navigation
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => PhoneFrameWrapper(
                    child: ClubDetailScreen(
                      club: widget.club,
                      currentUserId: widget.currentUserId,
                      onRSVPChanged: widget.onRSVPChanged,
                    ),
                  ),
                ),
              );
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
        body: Column(
          children: [
            // Practice Title above RSVP card
            Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: EdgeInsets.all(10), // Reduced from 20 to 10 (50% reduction)
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.practice.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (widget.practice.tag != null) ...[
                    SizedBox(width: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Text(
                        widget.practice.tag!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // RSVP Card for future events, Attendance indicator for past events
            _isPastEvent(widget.practice)
                ? Container(
                    margin: EdgeInsets.fromLTRB(16, 8, 16, 16),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        _buildAttendanceIndicator(_getUserAttendanceStatus(widget.practice)),
                        SizedBox(width: 12),
                        Text(
                          _getUserAttendanceStatus(widget.practice)
                              ? 'You attended this practice'
                              : 'You did not attend this practice',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    margin: EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Consumer<RSVPProvider>(
                      builder: (context, rsvpProvider, child) {
                        return PracticeRSVPCard(
                          practice: widget.practice,
                          clubId: widget.club.id,
                          onRSVPChanged: widget.onRSVPChanged != null 
                              ? (status) {
                                  widget.onRSVPChanged!(widget.practice.id, status);
                                  // Show toast when RSVP changes
                                  String message = 'RSVP updated to: ${status.displayText}';
                                  Color toastColor = status.color;
                                  if (status == RSVPStatus.maybe) {
                                    _showCustomToast(message, toastColor, Icons.help);
                                  } else {
                                    _showCustomToast(message, toastColor, status.overlayIcon);
                                  }
                                }
                              : null,
                          onLocationTap: () => _handleLocationTap(context, widget.practice.location),
                          // No onInfoTap since we're already in practice details
                        );
                      },
                    ),
                  ),
            // TabBar positioned after RSVP card
            TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: 'About'),
                Tab(text: 'Gallery'),
                Tab(text: 'Forum'),
              ],
            ),
            // TabBarView for the tabs
            Expanded(
              child: TabBarView(
                children: [
                  _buildAboutTab(context),
                  _buildGalleryTab(context),
                  _buildForumTab(context),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Consumer<NavigationProvider>(
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
                if (index == 3) { // Clubs tab (0: Home, 1: Events, 2: Programs, 3: Clubs, 4: Profile)
                  // For Clubs tab, check if we can go back to Club Details
                  if (Navigator.of(context).canPop()) {
                    // If there's a previous screen in the stack, go back to it
                    Navigator.of(context).pop();
                  } else {
                    // If no previous screen, go to main app Clubs tab
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    navigationProvider.selectTab(index);
                  }
                } else {
                  // For other tabs, navigate back to main app with selected tab
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  navigationProvider.selectTab(index);
                }
              },
            );
          },
        ),
            ), // Close Scaffold
          ), // Close DefaultTabController
        ), // Close PopScope
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
        ],
      ),
    );
  }

  Widget _buildAboutTab(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            Container(
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
