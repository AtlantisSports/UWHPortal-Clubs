/// Centralized error handling system for the application
/// 
/// This provides consistent error types, handling, and user messaging
/// across all features and services.
library;

import 'package:flutter/foundation.dart';

/// Base exception class for all app-specific errors
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  
  const AppException(this.message, {this.code, this.originalError});
  
  @override
  String toString() => 'AppException: $message';
}

/// Network-related errors
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.originalError});
}

/// API-specific errors
class ApiException extends AppException {
  final int? statusCode;
  
  const ApiException(super.message, {this.statusCode, super.code, super.originalError});
}

/// Validation errors
class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;
  
  const ValidationException(super.message, {this.fieldErrors, super.code});
}

/// Authentication/Authorization errors
class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.originalError});
}

/// Data parsing/serialization errors
class DataException extends AppException {
  const DataException(super.message, {super.code, super.originalError});
}

/// Generic app exception for unhandled cases
class GenericAppException extends AppException {
  const GenericAppException(super.message, {super.code, super.originalError});
}

/// Centralized error handler
class AppErrorHandler {
  static const String _genericErrorMessage = 'Something went wrong. Please try again.';
  
  /// Convert various error types to user-friendly messages
  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    
    if (error is NetworkException) {
      return 'Network error. Please check your connection.';
    }
    
    if (error is ApiException) {
      switch (error.statusCode) {
        case 400:
          return 'Invalid request. Please check your input.';
        case 401:
          return 'Please log in to continue.';
        case 403:
          return 'You do not have permission to perform this action.';
        case 404:
          return 'The requested resource was not found.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return error.message;
      }
    }
    
    // Log unknown errors in debug mode
    if (kDebugMode) {
      debugPrint('Unhandled error: $error');
    }
    
    return _genericErrorMessage;
  }
  
  /// Handle errors with optional callback
  static void handleError(
    dynamic error, {
    void Function(String message)? onError,
    bool showSnackbar = true,
  }) {
    final message = getErrorMessage(error);
    
    if (onError != null) {
      onError(message);
    }
    
    // Log error for debugging
    if (kDebugMode) {
      debugPrint('Error handled: $message');
      if (error is AppException && error.originalError != null) {
        debugPrint('Original error: ${error.originalError}');
      }
    }
  }
  
  /// Convert common exceptions to AppExceptions
  static AppException fromException(Exception exception) {
    if (exception is AppException) {
      return exception;
    }
    
    // Handle specific exception types
    final errorString = exception.toString();
    
    if (errorString.contains('SocketException') || 
        errorString.contains('TimeoutException')) {
      return NetworkException(
        'Network error. Please check your connection.',
        originalError: exception,
      );
    }
    
    if (errorString.contains('FormatException')) {
      return DataException(
        'Invalid data format received.',
        originalError: exception,
      );
    }
    
    // Generic fallback
    return GenericAppException(
      _genericErrorMessage,
      originalError: exception,
    );
  }
}
