import 'package:flutter/material.dart';
import '../../core/utils/navigation_service.dart';

/// Creates a realistic phone frame around the app content
class PhoneFrame extends StatelessWidget {
  final Widget child;
  final VoidCallback? onBackPressed;
  
  const PhoneFrame({
    super.key,
    required this.child,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 375, // iPhone width
      height: 812, // iPhone height
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Column(
          children: [
            // Status Bar
            _buildStatusBar(),
            // App Content
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: child,
              ),
            ),
            // Navigation Bar (Home indicator for iPhone-style)
            _buildNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      height: 44, // Standard iOS status bar height
      width: double.infinity,
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Time
          const Text(
            '9:41',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Right side - Status icons
          Row(
            children: [
              // Signal strength
              Container(
                width: 18,
                height: 12,
                margin: const EdgeInsets.only(right: 6),
                child: Row(
                  children: List.generate(4, (index) => Container(
                    width: 3,
                    height: 3 + (index * 2.0),
                    margin: const EdgeInsets.only(right: 1),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  )),
                ),
              ),
              // WiFi icon
              Container(
                width: 16,
                height: 12,
                margin: const EdgeInsets.only(right: 6),
                child: const Icon(
                  Icons.wifi,
                  color: Colors.black,
                  size: 16,
                ),
              ),
              // Battery
              Container(
                width: 26,
                height: 13,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Stack(
                  children: [
                    // Battery fill (80% charge)
                    Positioned(
                      left: 1,
                      top: 1,
                      bottom: 1,
                      child: Container(
                        width: 18, // 80% of ~22px inner width
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                    // Battery tip
                    Positioned(
                      right: -3,
                      top: 4,
                      child: Container(
                        width: 2,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      height: 48, // Android navigation bar height
      width: double.infinity,
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Recent apps button (left)
          _buildNavButton(
            icon: Icons.apps,
            onTap: () {
              // Visual feedback only - no function needed
            },
          ),
          // Home button (center)
          _buildNavButton(
            icon: Icons.radio_button_unchecked,
            onTap: () {
              // Visual feedback only - no function needed
            },
          ),
          // Back button (right) - functional
          _buildNavButton(
            icon: Icons.arrow_back,
            onTap: () {
              // Use custom callback if provided, otherwise try default navigation
              if (onBackPressed != null) {
                onBackPressed!();
              } else {
                // Fallback to trying to pop the navigation stack
                final navContext = NavigationService.context;
                if (navContext != null && Navigator.of(navContext).canPop()) {
                  Navigator.of(navContext).pop();
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.8),
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// Wrapper widget to display any widget inside a phone frame
class PhoneFrameWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onBackPressed;
  
  const PhoneFrameWrapper({
    super.key,
    required this.child,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light gray background
      body: Center(
        child: PhoneFrame(
          onBackPressed: onBackPressed,
          child: child,
        ),
      ),
    );
  }
}
