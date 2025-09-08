/// Responsive utility classes for managing breakpoints and responsive layouts
library;

import 'package:flutter/material.dart';

/// Responsive breakpoints optimized for Galaxy S23 dimensions
class ResponsiveBreakpoints {
  // Galaxy S23 specific dimensions
  static const double galaxyS23Width = 393.0; // Galaxy S23 logical width
  static const double galaxyS23Height = 851.0; // Galaxy S23 logical height
  
  // Responsive breakpoints
  static const double mobile = 393; // Galaxy S23 width as mobile breakpoint
  static const double smallMobile = 320; // Smaller phones
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double largeDesktop = 1440;
}

/// Responsive utility class to help with responsive design decisions
class ResponsiveHelper {
  /// Check if current screen is small mobile size (very small phones)
  static bool isSmallMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < ResponsiveBreakpoints.smallMobile;
  }

  /// Check if current screen is mobile size
  static bool isMobile(BuildContext context) {
    // Force mobile layout for all screen sizes
    return true;
  }

  /// Check if current screen is tablet size
  static bool isTablet(BuildContext context) {
    // Force mobile layout - never show tablet layout
    return false;
  }

  /// Check if current screen is desktop size
  static bool isDesktop(BuildContext context) {
    // Force mobile layout - never show desktop layout
    return false;
  }

  /// Get responsive value based on screen size
  static T responsive<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(12.0); // Smaller padding for mobile
    } else if (isTablet(context)) {
      return const EdgeInsets.all(20.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  /// Get responsive app bar height
  static double getAppBarHeight(BuildContext context) {
    if (isMobile(context)) {
      return 140.0; // Much smaller height for mobile to fit viewport
    } else if (isTablet(context)) {
      return 200.0;
    } else {
      return 250.0; // Original desktop height
    }
  }

  /// Get responsive font size scaling
  static double getFontScale(BuildContext context) {
    if (isMobile(context)) {
      return 0.9; // Slightly smaller text on mobile
    } else if (isTablet(context)) {
      return 1.0;
    } else {
      return 1.1; // Slightly larger on desktop
    }
  }

  /// Get responsive column count for grids
  static int getColumnCount(BuildContext context, {int maxColumns = 4}) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < ResponsiveBreakpoints.mobile) {
      return 1;
    } else if (width < ResponsiveBreakpoints.tablet) {
      return 2;
    } else if (width < ResponsiveBreakpoints.desktop) {
      return 3;
    } else {
      return maxColumns;
    }
  }

  /// Get responsive spacing
  static double getSpacing(BuildContext context, {
    double mobileSpacing = 6.0,  // Reduced from 8.0
    double tabletSpacing = 10.0, // Reduced from 12.0
    double desktopSpacing = 16.0,
  }) {
    if (isMobile(context)) {
      return mobileSpacing;
    } else if (isTablet(context)) {
      return tabletSpacing;
    } else {
      return desktopSpacing;
    }
  }
}

/// Responsive layout builder widget
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveBreakpoints.desktop && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= ResponsiveBreakpoints.mobile && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Responsive container that adjusts its constraints based on screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? ResponsiveHelper.responsive(
          context: context,
          mobile: double.infinity,
          tablet: 800,
          desktop: 1200,
        ),
      ),
      padding: padding ?? ResponsiveHelper.getResponsivePadding(context),
      child: child,
    );
  }
}
