import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'app_error.dart';

/// Global error handler for the application
/// Converts various error types into standardized AppError instances
class ErrorHandler {
  /// Convert any error into an AppError
  static AppError handleError(Object error, [StackTrace? stackTrace]) {
    if (error is AppError) {
      return error;
    }

    // Note: Dio error handling will be added when Dio dependency is included

    if (error is SocketException) {
      return const AppError.offline(
        message: 'No internet connection',
        details: 'Please check your network settings and try again.',
      );
    }

    if (error is TimeoutException) {
      return const AppError.timeout(
        message: 'Request timed out',
        details: 'The operation took too long to complete.',
      );
    }

    if (error is FormatException) {
      return AppError.validation(
        message: 'Invalid data format',
        details: error.message,
      );
    }

    // Log unknown errors for debugging
    if (kDebugMode) {
      print('Unknown error: $error');
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }

    return AppError.unknown(
      message: 'An unexpected error occurred',
      details: error.toString(),
      originalError: error,
    );
  }

  /// Handle HTTP response errors (placeholder for when Dio is added)
  static AppError handleHttpError(Map<String, dynamic> response) {
    final statusCode = response['statusCode'] as int? ?? 0;
    final data = response['data'];

    // Try to extract error message from response
    String message = 'HTTP Error $statusCode';
    String? details;

    if (data is Map<String, dynamic>) {
      // Standard error response format
      if (data.containsKey('error')) {
        final errorData = data['error'];
        if (errorData is Map<String, dynamic>) {
          message = errorData['message'] ?? message;
          details = errorData['details'];
        } else if (errorData is String) {
          message = errorData;
        }
      }
      // Alternative error formats
      else if (data.containsKey('message')) {
        message = data['message'];
      } else if (data.containsKey('title')) {
        message = data['title'];
        details = data['detail'];
      }
    } else if (data is String) {
      message = data;
    }

    switch (statusCode) {
      case 400:
        // Check for validation errors
        Map<String, String>? fieldErrors;
        if (data is Map<String, dynamic> && data.containsKey('errors')) {
          final errors = data['errors'];
          if (errors is Map<String, dynamic>) {
            fieldErrors = errors.map((key, value) => 
              MapEntry(key, value is List ? value.first.toString() : value.toString()));
          }
        }
        
        return AppError.validation(
          message: message,
          details: details ?? 'Please check your input and try again',
          fieldErrors: fieldErrors,
        );

      case 401:
        return AppError.authentication(
          message: message,
          details: details ?? 'Authentication is required',
        );

      case 403:
        return AppError.authorization(
          message: message,
          details: details ?? 'Access to this resource is forbidden',
        );

      case 404:
        return AppError.notFound(
          message: message,
          details: details ?? 'The requested resource was not found',
        );

      case 409:
        return AppError.conflict(
          message: message,
          details: details ?? 'This action conflicts with existing data',
        );

      case 429:
        Duration? retryAfter;
        final headers = response['headers'] as Map<String, dynamic>?;
        final retryAfterHeader = headers?['retry-after'] as String?;
        if (retryAfterHeader != null) {
          final seconds = int.tryParse(retryAfterHeader);
          if (seconds != null) {
            retryAfter = Duration(seconds: seconds);
          }
        }
        
        return AppError.rateLimit(
          message: message,
          details: details ?? 'Too many requests, please wait before trying again',
          retryAfter: retryAfter,
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return AppError.server(
          message: message,
          details: details ?? 'The server encountered an error',
          statusCode: statusCode,
        );

      default:
        return AppError.network(
          message: message,
          details: details ?? 'A network error occurred',
          statusCode: statusCode,
        );
    }
  }

  /// Execute an operation with error handling
  static Future<Result<T>> execute<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();
      return Result.success(result);
    } catch (error, stackTrace) {
      final appError = handleError(error, stackTrace);
      return Result.failure(appError);
    }
  }

  /// Execute an operation with retry logic
  static Future<Result<T>> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 10),
  }) async {
    int attempt = 0;
    Duration currentDelay = delay;

    while (attempt <= maxRetries) {
      final result = await execute(operation);
      
      if (result.isSuccess) {
        return result;
      }

      final error = result.errorOrNull!;
      
      // Don't retry if error is not retryable
      if (!error.isRetryable || attempt == maxRetries) {
        return result;
      }

      // Wait before retrying
      await Future.delayed(currentDelay);
      
      // Exponential backoff
      currentDelay = Duration(
        milliseconds: (currentDelay.inMilliseconds * 1.5).round(),
      );
      if (currentDelay > maxDelay) {
        currentDelay = maxDelay;
      }
      
      attempt++;
    }

    // This should never be reached, but just in case
    return Result.failure(const AppError.unknown(
      message: 'Max retries exceeded',
      details: 'The operation failed after multiple retry attempts',
    ));
  }
}

/// Mixin for classes that need error handling
mixin ErrorHandlerMixin {
  /// Handle errors and convert to Result
  Future<Result<T>> handleAsync<T>(Future<T> Function() operation) {
    return ErrorHandler.execute(operation);
  }

  /// Handle errors with retry logic
  Future<Result<T>> handleAsyncWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) {
    return ErrorHandler.executeWithRetry(
      operation,
      maxRetries: maxRetries,
      delay: delay,
    );
  }

  /// Convert any error to AppError
  AppError convertError(Object error, [StackTrace? stackTrace]) {
    return ErrorHandler.handleError(error, stackTrace);
  }
}
