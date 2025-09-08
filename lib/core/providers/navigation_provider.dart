import 'package:flutter/foundation.dart';

/// Provider for managing navigation state and phone interactions
class NavigationProvider extends ChangeNotifier {
  int _selectedIndex = 3; // Start with Clubs tab
  final List<int> _navigationHistory = [];
  bool _isDrawerOpen = false;

  // Getters
  int get selectedIndex => _selectedIndex;
  List<int> get navigationHistory => List.unmodifiable(_navigationHistory);
  bool get isDrawerOpen => _isDrawerOpen;
  bool get canGoBack => _navigationHistory.isNotEmpty;

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
      notifyListeners();
      
      debugPrint('DEBUG: Tab changed from $_selectedIndex to $index');
      debugPrint('DEBUG: Navigation history: $_navigationHistory');
    }
  }

  /// Handle phone back button navigation
  bool handlePhoneBackNavigation() {
    // If drawer is open, don't handle tab navigation - let drawer close first
    if (_isDrawerOpen) {
      return false; // Let the drawer handle the back press
    }

    // Try to go back in tab history
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
