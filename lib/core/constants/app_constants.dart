/// App constants matching uwhportal branding and configuration
library;

import 'package:flutter/material.dart';

class AppConstants {
  // API Configuration
  static const String baseApiUrl = 'https://api.uwhportal.com';
  static const String apiVersion = 'v1';

  // App Information
  static const String appName = 'UWH Portal - Clubs';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userPreferencesKey = 'user_preferences';
  static const String themeKey = 'theme_mode';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration cacheTimeout = Duration(minutes: 5);

  // Announced practices (mock) cutoff
  // For mock data, treat "Announced" practices as those on or before this date (inclusive).
  // Adjust as needed per test scenario.
  static final DateTime mockAnnouncedCutoff = DateTime(2025, 11, 9, 23, 59, 59);

  // Asset Paths
  static const String logoAsset = 'assets/images/logo.png';
  static const String placeholderImage = 'assets/images/placeholder.png';
}

/// App Colors matching uwhportal branding
class AppColors {
  // Primary Colors (Underwater Hockey theme)
  static const Color primary = Color(0xFF0077BE); // Ocean blue
  static const Color primaryDark = Color(0xFF005A9C);
  static const Color primaryLight = Color(0xFF33A1DB);

  // Secondary Colors
  static const Color secondary = Color(0xFF00C853); // Success green
  static const Color secondaryDark = Color(0xFF00A644);
  static const Color secondaryLight = Color(0xFF5EFC82);

  // Neutral Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF121212);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Club/Event specific colors
  static const Color eventActive = Color(0xFF4CAF50);
  static const Color eventUpcoming = Color(0xFF2196F3);
  static const Color eventCancelled = Color(0xFF9E9E9E);
}

/// Text Styles following uwhportal design system
class AppTextStyles {
  // Headlines
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle headline3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  // Buttons
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  // Captions
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}

/// Spacing constants
class AppSpacing {
  static const double xs = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Border radius constants
class AppRadius {
  static const double small = 4.0;
  static const double medium = 8.0;
  static const double large = 12.0;
  static const double xl = 16.0;
}

/// Animation durations
class AppDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}
