/// Riverpod version of NavigationProvider
library;

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_riverpod.freezed.dart';
part 'navigation_riverpod.g.dart';

@freezed
abstract class NavigationState with _$NavigationState {
  const factory NavigationState({
    @Default(3) int selectedIndex, // Start with Clubs tab
    @Default([]) List<int> navigationHistory,
    @Default(false) bool isDrawerOpen,
  }) = _NavigationState;
}

@riverpod
class NavigationController extends _$NavigationController {
  // Map of tab-specific back handlers that return true if they handled internal navigation
  final Map<int, bool Function()> _tabBackHandlers = {};

  @override
  NavigationState build() {
    return const NavigationState();
  }

  // Getters for convenience
  int get selectedIndex => state.selectedIndex;
  List<int> get navigationHistory => state.navigationHistory;
  bool get isDrawerOpen => state.isDrawerOpen;
  bool get canGoBack => state.navigationHistory.isNotEmpty;

  /// Register a back handler for a specific tab
  void registerTabBackHandler(int tabIndex, bool Function() handler) {
    _tabBackHandlers[tabIndex] = handler;
    debugPrint('DEBUG: Registered back handler for tab: $tabIndex');
  }

  /// Unregister a back handler for a specific tab
  void unregisterTabBackHandler(int tabIndex) {
    _tabBackHandlers.remove(tabIndex);
    debugPrint('DEBUG: Unregistered back handler for tab: $tabIndex');
  }

  /// Update the selected tab and manage navigation history
  void selectTab(int index) {
    if (state.selectedIndex != index) {
      // Add current tab to history before switching
      final newHistory = [...state.navigationHistory, state.selectedIndex];
      
      // Keep history manageable (max 10 items)
      if (newHistory.length > 10) {
        newHistory.removeAt(0);
      }
      
      state = state.copyWith(
        selectedIndex: index,
        navigationHistory: newHistory,
      );
      
      debugPrint('DEBUG: Tab changed from ${state.selectedIndex} to $index');
      debugPrint('DEBUG: Navigation history: $newHistory');
      
      // If navigating to clubs tab (index 3), always reset to clubs list
      if (index == 3) {
        final clubsTabHandler = _tabBackHandlers[3];
        if (clubsTabHandler != null) {
          debugPrint('DEBUG: Navigating to Clubs tab - resetting to list view');
          clubsTabHandler();
        }
      }
    }
  }

  /// Update drawer state
  void setDrawerState(bool isOpen) {
    if (state.isDrawerOpen != isOpen) {
      state = state.copyWith(isDrawerOpen: isOpen);
      debugPrint('DEBUG: Drawer state changed: ${isOpen ? 'opened' : 'closed'}');
    }
  }

  /// Handle phone back button navigation
  bool handlePhoneBackNavigation() {
    // If drawer is open, don't handle tab navigation - let drawer close first
    if (state.isDrawerOpen) {
      return false; // Let the drawer handle the back press
    }

    // Check if current tab has its own back handler and if it can handle internal navigation
    final currentTabHandler = _tabBackHandlers[state.selectedIndex];
    if (currentTabHandler != null) {
      final handledInternally = currentTabHandler();
      if (handledInternally) {
        debugPrint('DEBUG: Tab-specific handler handled internal navigation for tab: ${state.selectedIndex}');
        return true;
      }
      debugPrint('DEBUG: Tab-specific handler had no internal navigation to handle for tab: ${state.selectedIndex}');
    }

    // If no internal navigation was handled, try to go back in tab history
    if (state.navigationHistory.isNotEmpty) {
      final previousTab = state.navigationHistory.last;
      final newHistory = [...state.navigationHistory]..removeLast();
      
      state = state.copyWith(
        selectedIndex: previousTab,
        navigationHistory: newHistory,
      );
      
      debugPrint('DEBUG: Phone back navigation to tab: $previousTab');
      debugPrint('DEBUG: Remaining history: $newHistory');
      return true;
    }

    debugPrint('DEBUG: No tab history for phone back navigation');
    return false; // No navigation history, let system handle back press
  }

  /// Reset to initial state
  void reset() {
    state = const NavigationState();
    debugPrint('DEBUG: Navigation state reset to initial values');
  }
}
