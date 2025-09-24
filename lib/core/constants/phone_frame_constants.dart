/// Phone frame simulation constants
/// Consolidates all hardcoded phone measurements for easier management
library;

/// Phone frame dimensions and measurements for Galaxy S23 simulation
class PhoneFrameConstants {
  // === GALAXY S23 DIMENSIONS ===
  /// Galaxy S23 logical width in dp
  static const double phoneWidth = 393.0;
  
  /// Galaxy S23 logical height in dp  
  static const double phoneHeight = 851.0;
  
  /// Alternative height reference (used in some calculations)
  static const double phoneScreenHeight = 852.0;
  
  // === PHONE FRAME UI ELEMENTS ===
  /// Status bar height (top of phone)
  static const double statusBarHeight = 44.0;
  
  /// System navigation bar height (bottom of phone with home button)
  static const double systemNavBarHeight = 48.0;
  
  /// App's bottom navigation bar height (Home, Events, Clubs, etc.)
  static const double appBottomNavHeight = 56.0;
  
  /// Tab bar height (RSVP, Recurring Practices, etc.)
  static const double tabBarHeight = 48.0;
  
  /// App bar height (standard Flutter AppBar)
  static const double appBarHeight = 56.0;
  
  // === PHONE FRAME STYLING ===
  /// Phone frame border radius (outer)
  static const double phoneFrameBorderRadius = 25.0;
  
  /// Phone frame inner border radius
  static const double phoneFrameInnerRadius = 20.0;
  
  // === CALCULATED DIMENSIONS ===
  /// Available content height (phone height minus status bar and nav bar)
  /// 851.0 - 44.0 - 48.0 = 759.0
  static const double contentHeight = 759.0;
  
  /// Available content height for tab views (minus additional UI elements)
  /// 759.0 - 56.0 - 48.0 = 655.0
  static const double tabContentHeight = 655.0;
  
  // === MODAL CONSTRAINTS ===
  /// Maximum modal width within phone frame
  static const double maxModalWidth = 345.0;
  
  /// Maximum modal height
  static const double maxModalHeight = 500.0;
  
  /// Maximum bottom sheet height (75% of content area)
  static double get maxBottomSheetHeight => contentHeight * 0.75;
  
  // === RESPONSIVE BREAKPOINTS ===
  /// Mobile breakpoint (same as phone width)
  static const double mobileBreakpoint = phoneWidth;
  
  /// Small mobile breakpoint
  static const double smallMobileBreakpoint = 320.0;
  
  // === UTILITY METHODS ===
  /// Calculate phone frame center X position for given screen width
  static double getPhoneCenterX(double screenWidth) {
    return (screenWidth - phoneWidth) / 2;
  }
  
  /// Calculate phone frame center Y position for given screen height  
  static double getPhoneCenterY(double screenHeight) {
    return (screenHeight - phoneHeight) / 2;
  }
  
  /// Calculate modal backdrop top position
  static double getModalBackdropTop(double screenHeight) {
    return getPhoneCenterY(screenHeight) + statusBarHeight;
  }
  
  /// Calculate modal backdrop height
  static double getModalBackdropHeight() {
    return phoneHeight - statusBarHeight - systemNavBarHeight;
  }
  
  /// Calculate bottom sheet bottom position
  static double getBottomSheetBottom(double screenHeight) {
    return getPhoneCenterY(screenHeight) + systemNavBarHeight;
  }
}

/// Legacy constants for backward compatibility
/// TODO: Replace these with PhoneFrameConstants usage throughout codebase
@Deprecated('Use PhoneFrameConstants.phoneWidth instead')
const double phoneContentWidth = PhoneFrameConstants.phoneWidth;

@Deprecated('Use PhoneFrameConstants.contentHeight instead') 
const double phoneContentHeight = PhoneFrameConstants.contentHeight;

@Deprecated('Use PhoneFrameConstants.phoneScreenHeight instead')
const double phoneScreenHeight = PhoneFrameConstants.phoneScreenHeight;
