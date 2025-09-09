/// Clubs feature - Streamlined detail screen for individual club
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/club.dart';
import '../../core/models/practice.dart';
import '../../core/constants/app_constants.dart';
import '../../base/widgets/rsvp_components.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/utils/app_error_handler.dart';
import 'widgets/club_header.dart';
import 'widgets/club_action_buttons.dart';
import 'widgets/club_detail_tabs.dart';

class ClubDetailScreenRefactored extends StatefulWidget {
  final Club club;
  final String currentUserId;
  final Function(String practiceId, RSVPStatus status)? onRSVPChanged;
  final VoidCallback? onBackPressed;
  
  const ClubDetailScreenRefactored({
    super.key,
    required this.club,
    required this.currentUserId,
    this.onRSVPChanged,
    this.onBackPressed,
  });

  @override
  State<ClubDetailScreenRefactored> createState() => _ClubDetailScreenRefactoredState();
}

class _ClubDetailScreenRefactoredState extends State<ClubDetailScreenRefactored>
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  bool _isLoading = false;
  RSVPStatus? _currentRSVPStatus;
  AppException? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeRSVPStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeRSVPStatus() {
    final nextPractice = _getNextPractice();
    if (nextPractice != null) {
      _currentRSVPStatus = nextPractice.getRSVPStatus(widget.currentUserId);
    }
  }

  void _updateRSVP(RSVPStatus status) {
    final nextPractice = _getNextPractice();
    if (nextPractice != null) {
      setState(() {
        _currentRSVPStatus = status;
      });
      widget.onRSVPChanged?.call(nextPractice.id, status);
    }
  }

  void _handleLocationTap() async {
    final nextPractice = _getNextPractice();
    if (nextPractice != null) {
      final encodedLocation = Uri.encodeComponent(nextPractice.location);
      final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedLocation');
      
      try {
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open location: ${nextPractice.location}')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error opening location: ${nextPractice.location}')),
          );
        }
      }
    }
  }

  Practice? _getNextPractice() {
    if (widget.club.upcomingPractices.isEmpty) return null;
    
    final now = DateTime.now();
    final upcomingPractices = widget.club.upcomingPractices
        .where((practice) => practice.dateTime.isAfter(now))
        .toList();
    
    if (upcomingPractices.isEmpty) return null;
    
    upcomingPractices.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return upcomingPractices.first;
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 393, // Galaxy S23 width - match phone frame
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Clubs - ${widget.club.name}'),
          backgroundColor: Colors.grey[100],
          foregroundColor: Colors.black87,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 24.0),
              onPressed: () {
                // TODO: Implement notifications functionality
              },
            ),
            IconButton(
              icon: const Icon(Icons.menu, size: 24.0),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ],
        ),
        body: LoadingWrapper(
          isLoading: _isLoading,
          error: _error,
          onRetry: _initializeRSVPStatus,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Club header with banner and name
                ClubHeader(club: widget.club),
                
                // Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ClubActionButtons(club: widget.club),
                ),
                
                SizedBox(height: ResponsiveHelper.getSpacing(context, mobileSpacing: 16.0)),
                
                // Next Practice Card
                _buildNextPracticeSection(),
                
                SizedBox(height: ResponsiveHelper.getSpacing(context, mobileSpacing: 16.0)),
                
                // Detail tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ClubDetailTabs(tabController: _tabController),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextPracticeSection() {
    return Builder(
      builder: (context) {
        final nextPractice = _getNextPractice();
        if (nextPractice == null) return const SizedBox.shrink();
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              NextPracticeCard(
                practice: nextPractice,
                currentRSVP: _currentRSVPStatus,
                onRSVPChanged: (status) => _updateRSVP(status),
                onLocationTap: _handleLocationTap,
              ),
              SizedBox(height: ResponsiveHelper.getSpacing(context, mobileSpacing: 8.0)),
            ],
          ),
        );
      },
    );
  }
}
