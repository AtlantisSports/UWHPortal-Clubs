/// App constants matching uwhportal branding and configuration
library;

import 'package:flutter/material.dart';

class AppConstants {
  // API Configuration (use EnvironmentConfig.apiBaseUrl for actual URL)
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

  // Announced practices (mock) cutoff: dynamically set ~6 weeks ahead from "now"
  // Using a getter ensures this stays current across app restarts without hard-coding dates
  static DateTime get mockAnnouncedCutoff => DateTime.now().add(const Duration(days: 45));

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

  // RSVP visual colors (centralized)
  static const Color maybe = Color(0xFFF59E0B);      // Tailwind Amber 500
  static const Color selection = Color(0xFF7C3AED);  // Tailwind Violet 600

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

/// Environment configuration with support for multiple deployment targets
class EnvironmentConfig {
  // Environment detection
  static Environment get currentEnvironment {
    const environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
    switch (environment.toLowerCase()) {
      case 'production':
      case 'prod':
        return Environment.production;
      case 'staging':
      case 'stage':
        return Environment.staging;
      case 'development':
      case 'dev':
      default:
        return Environment.development;
    }
  }

  // Feature flags
  static bool get useMockServices {
    const useMocks = String.fromEnvironment('USE_MOCK_SERVICES', defaultValue: '');
    if (useMocks.isNotEmpty) {
      return useMocks.toLowerCase() == 'true';
    }
    return currentEnvironment == Environment.development;
  }

  static bool get enableAnalytics => currentEnvironment != Environment.development;
  static bool get enableCrashReporting => currentEnvironment == Environment.production;
  static bool get enableDebugLogging => currentEnvironment == Environment.development;
  static bool get enablePerformanceMonitoring => currentEnvironment == Environment.production;

  // API Configuration
  static String get apiBaseUrl {
    const customUrl = String.fromEnvironment('API_BASE_URL');
    if (customUrl.isNotEmpty) {
      return customUrl;
    }

    switch (currentEnvironment) {
      case Environment.production:
        return 'https://api.uwhportal.com';
      case Environment.staging:
        return 'https://staging-api.uwhportal.com';
      case Environment.development:
        return 'http://localhost:5000';
    }
  }

  static String get websocketUrl {
    final baseUrl = apiBaseUrl;
    return baseUrl.replaceFirst('http', 'ws').replaceFirst('https', 'wss');
  }

  // Authentication Configuration
  static String get authDomain {
    switch (currentEnvironment) {
      case Environment.production:
        return 'auth.uwhportal.com';
      case Environment.staging:
        return 'staging-auth.uwhportal.com';
      case Environment.development:
        return 'localhost:5001';
    }
  }

  static String get clientId {
    switch (currentEnvironment) {
      case Environment.production:
        return 'uwhportal-mobile-prod';
      case Environment.staging:
        return 'uwhportal-mobile-staging';
      case Environment.development:
        return 'uwhportal-mobile-dev';
    }
  }

  // Logging Configuration
  static LogLevel get logLevel {
    switch (currentEnvironment) {
      case Environment.production:
        return LogLevel.warning;
      case Environment.staging:
        return LogLevel.info;
      case Environment.development:
        return LogLevel.debug;
    }
  }

  // Cache Configuration
  static bool get enableCaching => true;
  static Duration get cacheExpiry {
    switch (currentEnvironment) {
      case Environment.production:
        return const Duration(hours: 24);
      case Environment.staging:
        return const Duration(hours: 1);
      case Environment.development:
        return const Duration(minutes: 15);
    }
  }

  // Network Configuration
  static Duration get apiTimeout {
    switch (currentEnvironment) {
      case Environment.production:
        return const Duration(seconds: 45);
      case Environment.staging:
        return const Duration(seconds: 30);
      case Environment.development:
        return const Duration(seconds: 15);
    }
  }

  static int get maxRetries {
    switch (currentEnvironment) {
      case Environment.production:
        return 5;
      case Environment.staging:
        return 3;
      case Environment.development:
        return 1;
    }
  }
}

/// Deployment environment enumeration
enum Environment {
  development,
  staging,
  production,
}

/// Logging level enumeration
enum LogLevel {
  debug,
  info,
  warning,
  error,
}
