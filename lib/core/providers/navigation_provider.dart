import 'package:flutter/foundation.dart';

/// Provider for managing navigation state and phone interactions
class NavigationProvider extends ChangeNotifier {
  int _selectedIndex = 3; // Start with Clubs tab
  final List<int> _navigationHistory = [];
  bool _isDrawerOpen = false;
  
  // Map of tab-specific back handlers that return true if they handled internal navigation
  final Map<int, bool Function()> _tabBackHandlers = {};

  // Getters
  int get selectedIndex => _selectedIndex;
  List<int> get navigationHistory => List.unmodifiable(_navigationHistory);
  bool get isDrawerOpen => _isDrawerOpen;
  bool get canGoBack => _navigationHistory.isNotEmpty;

  /// Register a back handler for a specific tab that returns true if it handled internal navigation
  void registerTabBackHandler(int tabIndex, bool Function() handler) {
    _tabBackHandlers[tabIndex] = handler;
  }

  /// Unregister a back handler for a specific tab
  void unregisterTabBackHandler(int tabIndex) {
    _tabBackHandlers.remove(tabIndex);
  }

  /// Update the selected tab and manage navigation history
  void selectTab(int index) {
    if (_selectedIndex != index) {
      // Add current tab to history before switching
      _navigationHistory.add(_selectedIndex);
      
      // Keep history manageable (max 10 items)
      if (_navigationHistory.length > 10) {
        _navigationHistory.removeAt(0);
      }
      
      _selectedIndex = index;
      
      // If navigating to clubs tab (index 3), always reset to clubs list
      if (index == 3) {
        final clubsTabHandler = _tabBackHandlers[3];
        if (clubsTabHandler != null) {
          debugPrint('DEBUG: Navigating to Clubs tab - resetting to list view');
          clubsTabHandler();
        }
      }
      
      notifyListeners();
      
      debugPrint('DEBUG: Tab changed from ${_navigationHistory.last} to $index');
      debugPrint('DEBUG: Navigation history: $_navigationHistory');
    } else if (index == 3) {
      // If clicking on the same clubs tab (index 3), reset to clubs list
      final clubsTabHandler = _tabBackHandlers[3];
      if (clubsTabHandler != null) {
        debugPrint('DEBUG: Clubs tab clicked - attempting to reset to list view');
        clubsTabHandler();
      }
    }
  }

  /// Handle phone back button navigation
  bool handlePhoneBackNavigation() {
    // If drawer is open, don't handle tab navigation - let drawer close first
    if (_isDrawerOpen) {
      return false; // Let the drawer handle the back press
    }

    // Check if current tab has its own back handler and if it can handle internal navigation
    final currentTabHandler = _tabBackHandlers[_selectedIndex];
    if (currentTabHandler != null) {
      final handledInternally = currentTabHandler();
      if (handledInternally) {
        debugPrint('DEBUG: Tab-specific handler handled internal navigation for tab: $_selectedIndex');
        return true;
      }
      debugPrint('DEBUG: Tab-specific handler had no internal navigation to handle for tab: $_selectedIndex');
    }

    // Try to go back in tab history if no internal navigation was handled
    if (_navigationHistory.isNotEmpty) {
      final previousTab = _navigationHistory.removeLast();
      _selectedIndex = previousTab;
      notifyListeners();
      
      debugPrint('DEBUG: Phone back navigation to tab: $previousTab');
      debugPrint('DEBUG: Remaining history: $_navigationHistory');
      return true;
    }
    
    debugPrint('DEBUG: No tab history for phone back navigation');
    return false;
  }

  /// Update drawer open state
  void setDrawerState(bool isOpen) {
    if (_isDrawerOpen != isOpen) {
      _isDrawerOpen = isOpen;
      notifyListeners();
      debugPrint('DEBUG: Drawer state changed: ${isOpen ? "opened" : "closed"}');
    }
  }

  /// Reset navigation state (useful for testing)
  void reset() {
    _selectedIndex = 3;
    _navigationHistory.clear();
    _isDrawerOpen = false;
    notifyListeners();
  }
}
