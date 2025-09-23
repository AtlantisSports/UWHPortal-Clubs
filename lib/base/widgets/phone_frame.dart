import 'package:flutter/material.dart';
import '../../core/utils/navigation_service.dart';

/// Creates a realistic phone frame around the app content
class PhoneFrame extends StatefulWidget {
  final Widget child;
  final VoidCallback? onBackPressed;
  
  const PhoneFrame({
    super.key,
    required this.child,
    this.onBackPressed,
  });

  @override
  State<PhoneFrame> createState() => PhoneFrameState();
}

class PhoneFrameState extends State<PhoneFrame> {
  static PhoneFrameState? _instance;
  static final List<PhoneFrameState> _allInstances = [];
  
  Widget? _overlayWidget;

  @override
  void initState() {
    super.initState();
    _instance = this;
    _allInstances.add(this);
    // Clear any lingering overlay state when the widget is created
    _overlayWidget = null;
    debugPrint('PhoneFrame initState called, instance set to: $this (total instances: ${_allInstances.length})');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure instance is always current when dependencies change
    _instance = this;
    debugPrint('PhoneFrame didChangeDependencies - instance reset to: $this');
    
    // Also clear overlay when dependencies change (e.g., returning from navigation)
    if (_overlayWidget != null) {
      debugPrint('PhoneFrame didChangeDependencies - clearing overlay');
      _overlayWidget = null;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void activate() {
    super.activate();
    // Restore instance when widget becomes active again (e.g., returning from navigation)
    _instance = this;
    debugPrint('PhoneFrame activate called, instance restored to: $this');
  }

  @override
  void dispose() {
    _allInstances.remove(this);
    if (_instance == this) {
      // Find another active instance if available
      _instance = _allInstances.isNotEmpty ? _allInstances.last : null;
    }
    debugPrint('PhoneFrame dispose called, remaining instances: ${_allInstances.length}');
    super.dispose();
  }
  
  /// Show an overlay widget within the phone frame
  static void showOverlay(Widget overlay) {
    debugPrint('PhoneFrameState.showOverlay called');
    var state = _instance;
    debugPrint('Primary phone frame instance: $state');
    
    if (state != null && state.mounted) {
      state._showOverlay(overlay);
    } else {
      debugPrint('Primary instance is null or not mounted, trying fallback');
      // Try to find any mounted instance as fallback
      for (var instance in _allInstances) {
        if (instance.mounted) {
          debugPrint('Using fallback instance: $instance');
          _instance = instance; // Update primary instance
          instance._showOverlay(overlay);
          return;
        }
      }
      debugPrint('No valid PhoneFrame instances found!');
    }
  }
  
  /// Hide the current overlay
  static void hideOverlay() {
    debugPrint('PhoneFrameState.hideOverlay called');
    var state = _instance;
    if (state != null && state.mounted) {
      state._hideOverlay();
    } else {
      debugPrint('Primary instance not available for hiding overlay, trying fallback');
      // Try to find any mounted instance with an overlay
      for (var instance in _allInstances) {
        if (instance.mounted && instance._overlayWidget != null) {
          debugPrint('Using fallback instance for hiding: $instance');
          _instance = instance; // Update primary instance
          instance._hideOverlay();
          return;
        }
      }
      debugPrint('No instance with overlay found to hide');
    }
  }
  
  /// Force clear any overlay state (useful after navigation)
  static void clearOverlayState() {
    debugPrint('PhoneFrameState.clearOverlayState called');
    final state = _instance;
    if (state != null) {
      state._clearOverlayState();
    }
  }
  
  void _showOverlay(Widget overlay) {
    debugPrint('_showOverlay called with overlay: $overlay');
    debugPrint('Current overlay state: $_overlayWidget');
    
    // If we already have an overlay, force clear it first
    if (_overlayWidget != null) {
      debugPrint('Warning: Overlay already exists, clearing it first');
      _overlayWidget = null;
    }
    
    setState(() {
      _overlayWidget = overlay;
    });
    debugPrint('Overlay shown, triggering rebuild');
  }
  
  void _hideOverlay() {
    debugPrint('_hideOverlay called');
    setState(() {
      _overlayWidget = null;
    });
  }
  
  void _clearOverlayState() {
    debugPrint('_clearOverlayState called');
    _overlayWidget = null;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 393, // Galaxy S23 width
      height: 851, // Galaxy S23 height
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(25), // Galaxy S23 rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20), // Match Galaxy S23 inner radius
        child: Stack(
          children: [
            // Main phone content
            Column(
              children: [
                // Status Bar
                _buildStatusBar(),
                // App Content
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: widget.child,
                  ),
                ),
                // Navigation Bar (Home indicator for iPhone-style)
                _buildNavigationBar(),
              ],
            ),
            // Overlay for modals (appears above everything) - DEPRECATED: Use PhoneAwareModalUtils instead
            if (_overlayWidget != null)
              Positioned.fill(
                child: _overlayWidget!,
              ),
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
              // Use custom callback if provided
              if (widget.onBackPressed != null) {
                widget.onBackPressed!();
                return;
              }
              
              // Try to get the current navigator state
              final navigator = NavigationService.navigator;
              if (navigator == null) return;
              
              // First, try to close drawer if it's open
              // We'll look for the current route's context that has a Scaffold
              final context = navigator.context;
              try {
                // Try to find if there's a drawer open and close it
                final scaffoldState = Scaffold.maybeOf(context);
                if (scaffoldState != null && scaffoldState.isEndDrawerOpen) {
                  navigator.pop(); // This closes the drawer
                  return;
                }
              } catch (e) {
                // If we can't find a scaffold, just continue with normal navigation
              }
              
              // If drawer is not open, try to navigate back in the navigation stack
              if (navigator.canPop()) {
                navigator.pop();
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
      body: OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: Center(
          child: Transform.scale(
            scale: 1.0, // Fixed scale - never changes
            child: SizedBox(
              width: 393, // Fixed Galaxy S23 width - never changes
              height: 851, // Fixed Galaxy S23 height - never changes
              child: PhoneFrame(
                onBackPressed: onBackPressed,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
