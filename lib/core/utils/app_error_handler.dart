/// Error handling utilities and custom exceptions
library;

import 'package:flutter/material.dart';

/// Base exception class for app-specific errors
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

/// Network-related errors
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.originalError});
}

/// Validation errors
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.originalError});
}

/// Business logic errors
class BusinessLogicException extends AppException {
  const BusinessLogicException(super.message, {super.code, super.originalError});
}

/// Error handling utilities
class ErrorHandler {
  static void showError(BuildContext context, AppException error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message),
        backgroundColor: Colors.red[600],
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static AppException handleError(dynamic error) {
    if (error is AppException) {
      return error;
    } else if (error.toString().contains('network') || error.toString().contains('connection')) {
      return NetworkException('Network connection error. Please check your internet connection.');
    } else {
      return BusinessLogicException('An unexpected error occurred. Please try again.');
    }
  }
}

/// Widget for handling loading states with error boundaries
class LoadingWrapper extends StatelessWidget {
  final bool isLoading;
  final AppException? error;
  final Widget child;
  final VoidCallback? onRetry;

  const LoadingWrapper({
    super.key,
    required this.isLoading,
    this.error,
    required this.child,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              error!.message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[700]),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      );
    }

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return child;
  }
}
