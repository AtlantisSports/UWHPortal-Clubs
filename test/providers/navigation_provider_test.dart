import 'package:flutter_test/flutter_test.dart';
import 'package:clubs_mockup/core/providers/navigation_provider.dart';

void main() {
  group('NavigationProvider Tests', () {
    late NavigationProvider navigationProvider;

    setUp(() {
      navigationProvider = NavigationProvider();
    });

    test('should start with default state', () {
      expect(navigationProvider.selectedIndex, 3); // Clubs tab
      expect(navigationProvider.navigationHistory, isEmpty);
      expect(navigationProvider.isDrawerOpen, false);
      expect(navigationProvider.canGoBack, false);
    });

    test('should update selected tab and track history', () {
      // Navigate from Clubs (3) to Events (1)
      navigationProvider.selectTab(1);
      
      expect(navigationProvider.selectedIndex, 1);
      expect(navigationProvider.navigationHistory, [3]);
      expect(navigationProvider.canGoBack, true);
    });

    test('should handle phone back navigation correctly', () {
      // Set up navigation history: Clubs -> Events -> Programs
      navigationProvider.selectTab(1); // Events
      navigationProvider.selectTab(2); // Programs
      
      expect(navigationProvider.selectedIndex, 2);
      expect(navigationProvider.navigationHistory, [3, 1]);
      
      // Go back once - should return to Events
      bool handled = navigationProvider.handlePhoneBackNavigation();
      expect(handled, true);
      expect(navigationProvider.selectedIndex, 1);
      expect(navigationProvider.navigationHistory, [3]);
      
      // Go back again - should return to Clubs
      handled = navigationProvider.handlePhoneBackNavigation();
      expect(handled, true);
      expect(navigationProvider.selectedIndex, 3);
      expect(navigationProvider.navigationHistory, isEmpty);
      
      // Try to go back with no history - should return false
      handled = navigationProvider.handlePhoneBackNavigation();
      expect(handled, false);
    });

    test('should not handle back navigation when drawer is open', () {
      // Set up some navigation history
      navigationProvider.selectTab(1);
      navigationProvider.selectTab(2);
      
      // Open drawer
      navigationProvider.setDrawerState(true);
      
      // Try to handle back navigation - should return false
      bool handled = navigationProvider.handlePhoneBackNavigation();
      expect(handled, false);
      
      // State should remain unchanged
      expect(navigationProvider.selectedIndex, 2);
      expect(navigationProvider.navigationHistory, [3, 1]);
    });

    test('should update drawer state correctly', () {
      expect(navigationProvider.isDrawerOpen, false);
      
      navigationProvider.setDrawerState(true);
      expect(navigationProvider.isDrawerOpen, true);
      
      navigationProvider.setDrawerState(false);
      expect(navigationProvider.isDrawerOpen, false);
    });

    test('should reset to initial state', () {
      // Change some state
      navigationProvider.selectTab(1);
      navigationProvider.selectTab(2);
      navigationProvider.setDrawerState(true);
      
      // Reset
      navigationProvider.reset();
      
      // Should be back to initial state
      expect(navigationProvider.selectedIndex, 3);
      expect(navigationProvider.navigationHistory, isEmpty);
      expect(navigationProvider.isDrawerOpen, false);
    });

    test('should limit navigation history to 10 items', () {
      // Add more than 10 items to history
      for (int i = 0; i < 12; i++) {
        navigationProvider.selectTab(i % 5); // Cycle through tabs
      }
      
      // History should be limited to 10 items
      expect(navigationProvider.navigationHistory.length, lessThanOrEqualTo(10));
    });
  });
}
