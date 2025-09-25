/// Screen demonstrating bulk RSVP functionality
/// Follows the same mobile layout format as Club Details and Practice Details
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/club.dart';
import '../../core/providers/navigation_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../base/widgets/bulk_rsvp_manager.dart';

/// Screen demonstrating bulk RSVP functionality
class BulkRSVPScreen extends StatefulWidget {
  final Club club;
  final String currentUserId;
  
  const BulkRSVPScreen({
    super.key, 
    required this.club,
    required this.currentUserId,
  });
  
  @override
  State<BulkRSVPScreen> createState() => _BulkRSVPScreenState();
}

class _BulkRSVPScreenState extends State<BulkRSVPScreen> {
  @override
  Widget build(BuildContext context) {
    // Match platform handling used by other screens
    final isMobileWeb = kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS ||
                                   defaultTargetPlatform == TargetPlatform.android);

    final scaffoldContent = PopScope(
      canPop: true, // Allow system back button to work normally
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: Colors.black87,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Bulk RSVP',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
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
        body: BulkRSVPManager(
          club: widget.club,
          onCancel: () => Navigator.of(context).pop(),
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
                // Navigate back to main app with selected tab
                Navigator.of(context).popUntil((route) => route.isFirst);
                navigationProvider.selectTab(index);
              },
            );
          },
        ),
      ),
    );

    // For mobile web, return scaffold directly; for desktop/browser, constrain width like other screens
    if (isMobileWeb) {
      return scaffoldContent;
    } else {
      return Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 393, // Match Galaxy S23 width / other screens
          ),
          child: scaffoldContent,
        ),
      );
    }
  }
}