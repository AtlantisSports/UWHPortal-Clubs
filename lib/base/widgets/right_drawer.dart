/// Right-side drawer menu matching UWH Portal design
library;

import 'package:flutter/material.dart';
import '../../core/utils/user_role_manager.dart';

class RightDrawer extends StatefulWidget {
  final Function(int)? onNavigateToTab;
  
  const RightDrawer({super.key, this.onNavigateToTab});

  @override
  State<RightDrawer> createState() => _RightDrawerState();
}

class _RightDrawerState extends State<RightDrawer> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // UWH Portal Logo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
              color: Colors.white,
              child: Center(
                child: Container(
                  height: 60,
                  child: Image.asset(
                    'assets/images/uwh_portal_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Show a cleaner version that matches your logo design
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // UWH text in blue - matching your logo
                          Text(
                            'UWH',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1976D2), // Blue from your logo
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Portal text in gray - matching your logo
                          Text(
                            'Portal',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF616161), // Gray from your logo
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            // Header with user info only
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              color: Colors.white,
              child: ListenableBuilder(
                listenable: UserRoleManager.instance,
                builder: (context, _) {
                  return Row(
                    children: [
                      // Avatar circle
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.blue[700],
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Username only
                      Text(
                        UserRoleManager.instance.currentUsername,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Menu Items - Simple scrollable list
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    _buildMenuItem(
                      title: 'Clubs',
                      onTap: () {
                        Navigator.pop(context);
                        widget.onNavigateToTab?.call(3); // Navigate to Clubs tab (index 3)
                      },
                    ),
                    _buildMenuItem(
                      title: 'Programs',
                      onTap: () {
                        Navigator.pop(context);
                        widget.onNavigateToTab?.call(2); // Navigate to Programs tab (index 2)
                      },
                    ),
                    _buildMenuItem(
                      title: 'Events',
                      onTap: () {
                        Navigator.pop(context);
                        widget.onNavigateToTab?.call(1); // Navigate to Events tab (index 1)
                      },
                    ),
                    _buildMenuItem(
                      title: 'Notifications',
                      onTap: () {
                        Navigator.pop(context);
                        widget.onNavigateToTab?.call(5); // Navigate to Notifications tab (index 5)
                      },
                    ),
                    _buildMenuItem(
                      title: 'Learn',
                      onTap: () {
                        Navigator.pop(context);
                        widget.onNavigateToTab?.call(6); // Navigate to Learn tab (index 6)
                      },
                    ),
                    _buildMenuItem(
                      title: 'About',
                      onTap: () {
                        Navigator.pop(context);
                        widget.onNavigateToTab?.call(7); // Navigate to About tab (index 7)
                      },
                    ),
                    _buildMenuItem(
                      title: 'FAQ',
                      onTap: () {
                        Navigator.pop(context);
                        widget.onNavigateToTab?.call(8); // Navigate to FAQ tab (index 8)
                      },
                    ),
                    _buildMenuItem(
                      title: 'Contact Us',
                      onTap: () {
                        Navigator.pop(context);
                        widget.onNavigateToTab?.call(9); // Navigate to Contact Us tab (index 9)
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Logout button at bottom
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
