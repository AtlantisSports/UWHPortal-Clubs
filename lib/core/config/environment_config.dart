/// Environment configuration for managing different app environments
/// 
/// This allows the app to easily switch between development (mock) and 
/// production (real API) configurations.
library;

enum AppEnvironment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static const AppEnvironment _currentEnvironment = AppEnvironment.development;
  
  static AppEnvironment get current => _currentEnvironment;
  
  static bool get isDevelopment => _currentEnvironment == AppEnvironment.development;
  static bool get isStaging => _currentEnvironment == AppEnvironment.staging;
  static bool get isProduction => _currentEnvironment == AppEnvironment.production;
  
  static String get apiBaseUrl {
    switch (_currentEnvironment) {
      case AppEnvironment.development:
        return 'https://dev-api.uwhportal.com';
      case AppEnvironment.staging:
        return 'https://staging-api.uwhportal.com';
      case AppEnvironment.production:
        return 'https://api.uwhportal.com';
    }
  }
  
  static bool get useMockServices => isDevelopment;
  
  // Add other environment-specific configurations here
  static bool get enableDebugLogging => !isProduction;
  static bool get enableCrashReporting => !isDevelopment;
}