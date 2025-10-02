import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_error.freezed.dart';

/// Comprehensive error handling for the UWH Portal application
/// Covers network, authentication, validation, and business logic errors
@freezed
sealed class AppError with _$AppError {
  const factory AppError.network({
    required String message,
    required String details,
    int? statusCode,
  }) = NetworkError;

  const factory AppError.authentication({
    required String message,
    required String details,
  }) = AuthenticationError;

  const factory AppError.authorization({
    required String message,
    required String details,
  }) = AuthorizationError;

  const factory AppError.validation({
    required String message,
    required String details,
    Map<String, String>? fieldErrors,
  }) = ValidationError;

  const factory AppError.notFound({
    required String message,
    required String details,
  }) = NotFoundError;

  const factory AppError.conflict({
    required String message,
    required String details,
  }) = ConflictError;

  const factory AppError.rateLimit({
    required String message,
    required String details,
    Duration? retryAfter,
  }) = RateLimitError;

  const factory AppError.server({
    required String message,
    required String details,
    int? statusCode,
  }) = ServerError;

  const factory AppError.timeout({
    required String message,
    required String details,
  }) = TimeoutError;

  const factory AppError.offline({
    required String message,
    required String details,
  }) = OfflineError;

  const factory AppError.unknown({
    required String message,
    required String details,
    Object? originalError,
  }) = UnknownError;
}

/// Extension to provide user-friendly error messages
extension AppErrorExtension on AppError {
  /// Get a user-friendly error message suitable for display in UI
  String get userMessage {
    return when(
      network: (message, details, statusCode) {
        if (statusCode == 404) {
          return 'The requested information could not be found.';
        }
        if (statusCode != null && statusCode >= 500) {
          return 'Server is temporarily unavailable. Please try again later.';
        }
        return 'Network connection problem. Please check your internet connection.';
      },
      authentication: (message, details) => 
        'Your session has expired. Please log in again.',
      authorization: (message, details) => 
        'You don\'t have permission to perform this action.',
      validation: (message, details, fieldErrors) => 
        fieldErrors?.values.first ?? message,
      notFound: (message, details) => 
        'The requested information could not be found.',
      conflict: (message, details) => 
        message,
      rateLimit: (message, details, retryAfter) => 
        'Too many requests. Please wait a moment and try again.',
      server: (message, details, statusCode) => 
        'Server error occurred. Please try again later.',
      timeout: (message, details) => 
        'Request timed out. Please check your connection and try again.',
      offline: (message, details) => 
        'No internet connection. Please check your network settings.',
      unknown: (message, details, originalError) => 
        'An unexpected error occurred. Please try again.',
    );
  }

  /// Get the technical error message for logging
  String get technicalMessage {
    return when(
      network: (message, details, statusCode) =>
        'Network Error [$statusCode]: $message - $details',
      authentication: (message, details) =>
        'Auth Error: $message - $details',
      authorization: (message, details) =>
        'Authorization Error: $message - $details',
      validation: (message, details, fieldErrors) =>
        'Validation Error: $message - $details${fieldErrors != null ? ' Fields: $fieldErrors' : ''}',
      notFound: (message, details) =>
        'Not Found: $message - $details',
      conflict: (message, details) =>
        'Conflict: $message - $details',
      rateLimit: (message, details, retryAfter) =>
        'Rate Limited: $message - $details${retryAfter != null ? ' Retry after: $retryAfter' : ''}',
      server: (message, details, statusCode) =>
        'Server Error [$statusCode]: $message - $details',
      timeout: (message, details) =>
        'Timeout: $message - $details',
      offline: (message, details) =>
        'Offline: $message - $details',
      unknown: (message, details, originalError) =>
        'Unknown Error: $message - $details${originalError != null ? ' Original: $originalError' : ''}',
    );
  }

  /// Check if this error should trigger a retry
  bool get isRetryable {
    return when(
      network: (message, details, statusCode) => 
        statusCode == null || statusCode >= 500 || statusCode == 408,
      authentication: (message, details) => false,
      authorization: (message, details) => false,
      validation: (message, details, fieldErrors) => false,
      notFound: (message, details) => false,
      conflict: (message, details) => false,
      rateLimit: (message, details, retryAfter) => true,
      server: (message, details, statusCode) => true,
      timeout: (message, details) => true,
      offline: (message, details) => true,
      unknown: (message, details, originalError) => false,
    );
  }

  /// Get the severity level for logging
  ErrorSeverity get severity {
    return when(
      network: (message, details, statusCode) => 
        statusCode != null && statusCode >= 500 ? ErrorSeverity.high : ErrorSeverity.medium,
      authentication: (message, details) => ErrorSeverity.medium,
      authorization: (message, details) => ErrorSeverity.medium,
      validation: (message, details, fieldErrors) => ErrorSeverity.low,
      notFound: (message, details) => ErrorSeverity.low,
      conflict: (message, details) => ErrorSeverity.medium,
      rateLimit: (message, details, retryAfter) => ErrorSeverity.medium,
      server: (message, details, statusCode) => ErrorSeverity.high,
      timeout: (message, details) => ErrorSeverity.medium,
      offline: (message, details) => ErrorSeverity.low,
      unknown: (message, details, originalError) => ErrorSeverity.high,
    );
  }
}

/// Error severity levels for logging and monitoring
enum ErrorSeverity {
  low,    // User errors, validation issues
  medium, // Network issues, auth problems
  high,   // Server errors, unknown errors
}

/// Result type for operations that can fail
@freezed
class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(AppError error) = Failure<T>;
}

/// Extension methods for Result type
extension ResultExtension<T> on Result<T> {
  /// Check if the result is successful
  bool get isSuccess => when(
    success: (_) => true,
    failure: (_) => false,
  );

  /// Check if the result is a failure
  bool get isFailure => !isSuccess;

  /// Get the data if successful, null otherwise
  T? get dataOrNull => when(
    success: (data) => data,
    failure: (_) => null,
  );

  /// Get the error if failed, null otherwise
  AppError? get errorOrNull => when(
    success: (_) => null,
    failure: (error) => error,
  );

  /// Transform the data if successful
  Result<R> map<R>(R Function(T data) transform) {
    return when(
      success: (data) => Result.success(transform(data)),
      failure: (error) => Result.failure(error),
    );
  }

  /// Handle both success and failure cases
  R fold<R>(
    R Function(T data) onSuccess,
    R Function(AppError error) onFailure,
  ) {
    return when(
      success: onSuccess,
      failure: onFailure,
    );
  }
}
