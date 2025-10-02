import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../errors/app_error.dart';

/// Comprehensive logging framework for the UWH Portal application
/// Provides structured logging with different levels and analytics integration
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  /// Log a debug message (development only)
  static void debug(String message, {Map<String, dynamic>? data, String? tag}) {
    if (EnvironmentConfig.logLevel.index <= LogLevel.debug.index) {
      _log(LogLevel.debug, message, data: data, tag: tag);
    }
  }

  /// Log an info message
  static void info(String message, {Map<String, dynamic>? data, String? tag}) {
    if (EnvironmentConfig.logLevel.index <= LogLevel.info.index) {
      _log(LogLevel.info, message, data: data, tag: tag);
    }
  }

  /// Log a warning message
  static void warning(String message, {Map<String, dynamic>? data, String? tag}) {
    if (EnvironmentConfig.logLevel.index <= LogLevel.warning.index) {
      _log(LogLevel.warning, message, data: data, tag: tag);
    }
  }

  /// Log an error message
  static void error(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? data, String? tag}) {
    if (EnvironmentConfig.logLevel.index <= LogLevel.error.index) {
      _log(LogLevel.error, message, error: error, stackTrace: stackTrace, data: data, tag: tag);
    }
  }

  /// Log an AppError with appropriate level
  static void logAppError(AppError appError, {String? context, Map<String, dynamic>? additionalData}) {
    final level = getLogLevelForError(appError);
    final data = <String, dynamic>{
      'errorType': appError.runtimeType.toString(),
      'severity': appError.severity.name,
      'isRetryable': appError.isRetryable,
      if (context != null) 'context': context,
      if (additionalData != null) ...additionalData,
    };

    _log(level, appError.technicalMessage, data: data, tag: 'ERROR');
  }

  /// Internal logging implementation
  static void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
    String? tag,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final logTag = tag ?? 'APP';
    final logMessage = '[$timestamp] [${level.name.toUpperCase()}] [$logTag] $message';

    // Console logging
    if (kDebugMode) {
      switch (level) {
        case LogLevel.debug:
          developer.log(logMessage, name: logTag, level: 500);
          break;
        case LogLevel.info:
          developer.log(logMessage, name: logTag, level: 800);
          break;
        case LogLevel.warning:
          developer.log(logMessage, name: logTag, level: 900);
          break;
        case LogLevel.error:
          developer.log(
            logMessage,
            name: logTag,
            level: 1000,
            error: error,
            stackTrace: stackTrace,
          );
          break;
      }

      // Print additional data if available
      if (data != null && data.isNotEmpty) {
        developer.log('Data: $data', name: logTag);
      }
    }

    // Send to analytics/crash reporting in production
    if (EnvironmentConfig.enableCrashReporting && level == LogLevel.error) {
      sendToCrashReporting(message, error, stackTrace, data);
    }

    // Send to analytics for user behavior tracking
    if (EnvironmentConfig.enableAnalytics && data != null) {
      sendToAnalytics(level, message, data, tag);
    }
  }

  /// Get appropriate log level for AppError
  static LogLevel getLogLevelForError(AppError appError) {
    return appError.when(
      network: (message, details, statusCode) => LogLevel.warning,
      authentication: (message, details) => LogLevel.warning,
      authorization: (message, details) => LogLevel.warning,
      validation: (message, details, fieldErrors) => LogLevel.info,
      notFound: (message, details) => LogLevel.info,
      conflict: (message, details) => LogLevel.warning,
      rateLimit: (message, details, retryAfter) => LogLevel.warning,
      server: (message, details, statusCode) => LogLevel.error,
      timeout: (message, details) => LogLevel.warning,
      offline: (message, details) => LogLevel.info,
      unknown: (message, details, originalError) => LogLevel.error,
    );
  }

  /// Send error to crash reporting service (placeholder)
  static void sendToCrashReporting(
    String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  ) {
    // TODO: Integrate with Firebase Crashlytics or similar service
    if (kDebugMode) {
      print('CRASH_REPORTING: $message');
      if (data != null) print('CRASH_DATA: $data');
    }
  }

  /// Send event to analytics service (placeholder)
  static void sendToAnalytics(
    LogLevel level,
    String message,
    Map<String, dynamic> data,
    String? tag,
  ) {
    // TODO: Integrate with Firebase Analytics or similar service
    if (kDebugMode) {
      print('ANALYTICS: [$level] $message - $data');
    }
  }
}

/// Analytics event tracking for user behavior monitoring
class Analytics {
  /// Track user action events
  static void trackUserAction(String action, {Map<String, dynamic>? properties}) {
    if (!EnvironmentConfig.enableAnalytics) return;

    final data = <String, dynamic>{
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
      'environment': EnvironmentConfig.currentEnvironment.name,
      if (properties != null) ...properties,
    };

    AppLogger.info('User action: $action', data: data, tag: 'ANALYTICS');
  }

  /// Track screen view events
  static void trackScreenView(String screenName, {Map<String, dynamic>? properties}) {
    if (!EnvironmentConfig.enableAnalytics) return;

    final data = <String, dynamic>{
      'screen': screenName,
      'timestamp': DateTime.now().toIso8601String(),
      if (properties != null) ...properties,
    };

    AppLogger.info('Screen view: $screenName', data: data, tag: 'ANALYTICS');
  }

  /// Track RSVP events
  static void trackRSVP(String practiceId, String status, {bool isBulk = false, int? guestCount}) {
    trackUserAction('rsvp_changed', properties: {
      'practiceId': practiceId,
      'status': status,
      'isBulk': isBulk,
      if (guestCount != null) 'guestCount': guestCount,
    });
  }

  /// Track club interactions
  static void trackClubAction(String action, String clubId, {Map<String, dynamic>? properties}) {
    trackUserAction('club_$action', properties: {
      'clubId': clubId,
      if (properties != null) ...properties,
    });
  }

  /// Track performance metrics
  static void trackPerformance(String operation, Duration duration, {bool success = true}) {
    if (!EnvironmentConfig.enablePerformanceMonitoring) return;

    AppLogger.info('Performance: $operation', data: {
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      'success': success,
    }, tag: 'PERFORMANCE');
  }

  /// Track errors for analytics
  static void trackError(AppError error, String context) {
    if (!EnvironmentConfig.enableAnalytics) return;

    trackUserAction('error_occurred', properties: {
      'errorType': error.runtimeType.toString(),
      'context': context,
      'severity': error.severity.name,
      'isRetryable': error.isRetryable,
    });
  }
}

/// Performance monitoring utilities
class PerformanceMonitor {
  static final Map<String, DateTime> _startTimes = {};

  /// Start timing an operation
  static void startTimer(String operation) {
    _startTimes[operation] = DateTime.now();
  }

  /// End timing an operation and log the result
  static void endTimer(String operation, {bool success = true}) {
    final startTime = _startTimes.remove(operation);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      Analytics.trackPerformance(operation, duration, success: success);
    }
  }

  /// Time a future operation
  static Future<T> timeOperation<T>(String operation, Future<T> Function() operationFunc) async {
    startTimer(operation);
    try {
      final result = await operationFunc();
      endTimer(operation, success: true);
      return result;
    } catch (error) {
      endTimer(operation, success: false);
      rethrow;
    }
  }
}

/// Mixin for classes that need logging capabilities
mixin LoggerMixin {
  void logDebug(String message, {Map<String, dynamic>? data}) {
    AppLogger.debug(message, data: data, tag: runtimeType.toString());
  }

  void logInfo(String message, {Map<String, dynamic>? data}) {
    AppLogger.info(message, data: data, tag: runtimeType.toString());
  }

  void logWarning(String message, {Map<String, dynamic>? data}) {
    AppLogger.warning(message, data: data, tag: runtimeType.toString());
  }

  void logError(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? data}) {
    AppLogger.error(message, error: error, stackTrace: stackTrace, data: data, tag: runtimeType.toString());
  }

  void logAppError(AppError error, {Map<String, dynamic>? additionalData}) {
    AppLogger.logAppError(error, context: runtimeType.toString(), additionalData: additionalData);
  }
}
