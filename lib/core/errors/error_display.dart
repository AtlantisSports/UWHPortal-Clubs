import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'app_error.dart';

/// User-friendly error display widgets and utilities
class ErrorDisplay {
  /// Show an error snackbar
  static void showErrorSnackBar(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              getErrorIcon(error),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error.userMessage,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: getErrorColor(error),
        duration: getErrorDuration(error),
        action: error.isRetryable
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () {
                  // Retry logic will be handled by the calling widget
                },
              )
            : null,
      ),
    );
  }

  /// Show an error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
    String? title,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                getErrorIcon(error),
                color: getErrorColor(error),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(title ?? 'Error'),
            ],
          ),
          content: Text(error.userMessage),
          actions: [
            if (error.isRetryable && onRetry != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: const Text('Retry'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Get appropriate icon for error type
  static IconData getErrorIcon(AppError error) {
    return error.when(
      network: (message, details, statusCode) => Icons.wifi_off,
      authentication: (message, details) => Icons.lock,
      authorization: (message, details) => Icons.security,
      validation: (message, details, fieldErrors) => Icons.warning,
      notFound: (message, details) => Icons.search_off,
      conflict: (message, details) => Icons.error_outline,
      rateLimit: (message, details, retryAfter) => Icons.hourglass_empty,
      server: (message, details, statusCode) => Icons.dns,
      timeout: (message, details) => Icons.access_time,
      offline: (message, details) => Icons.cloud_off,
      unknown: (message, details, originalError) => Icons.help_outline,
    );
  }

  /// Get appropriate color for error type
  static Color getErrorColor(AppError error) {
    return error.when(
      network: (message, details, statusCode) => Colors.orange,
      authentication: (message, details) => Colors.red,
      authorization: (message, details) => Colors.red,
      validation: (message, details, fieldErrors) => Colors.amber,
      notFound: (message, details) => Colors.grey,
      conflict: (message, details) => Colors.orange,
      rateLimit: (message, details, retryAfter) => Colors.blue,
      server: (message, details, statusCode) => Colors.red,
      timeout: (message, details) => Colors.orange,
      offline: (message, details) => Colors.grey,
      unknown: (message, details, originalError) => Colors.red,
    );
  }

  /// Get appropriate duration for error snackbar
  static Duration getErrorDuration(AppError error) {
    return error.when(
      network: (message, details, statusCode) => const Duration(seconds: 4),
      authentication: (message, details) => const Duration(seconds: 6),
      authorization: (message, details) => const Duration(seconds: 5),
      validation: (message, details, fieldErrors) => const Duration(seconds: 4),
      notFound: (message, details) => const Duration(seconds: 3),
      conflict: (message, details) => const Duration(seconds: 4),
      rateLimit: (message, details, retryAfter) => const Duration(seconds: 5),
      server: (message, details, statusCode) => const Duration(seconds: 5),
      timeout: (message, details) => const Duration(seconds: 4),
      offline: (message, details) => const Duration(seconds: 6),
      unknown: (message, details, originalError) => const Duration(seconds: 4),
    );
  }
}

/// Widget to display error states in place of content
class ErrorStateWidget extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final String? message;
  final bool showRetryButton;

  const ErrorStateWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.message,
    this.showRetryButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              ErrorDisplay.getErrorIcon(error),
              size: 64,
              color: ErrorDisplay.getErrorColor(error),
            ),
            const SizedBox(height: 16),
            Text(
              message ?? error.userMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            if (showRetryButton && error.isRetryable && onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget to display loading states with error fallback
class AsyncStateWidget<T> extends StatelessWidget {
  final Future<T>? future;
  final Widget Function(T data) builder;
  final Widget? loadingWidget;
  final Widget Function(AppError error)? errorBuilder;
  final VoidCallback? onRetry;

  const AsyncStateWidget({
    super.key,
    required this.future,
    required this.builder,
    this.loadingWidget,
    this.errorBuilder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ??
              const Center(
                child: CircularProgressIndicator(),
              );
        }

        if (snapshot.hasError) {
          final error = snapshot.error;
          final appError = error is AppError
              ? error
              : AppError.unknown(
                  message: 'An error occurred',
                  details: error.toString(),
                  originalError: error,
                );

          return errorBuilder?.call(appError) ??
              ErrorStateWidget(
                error: appError,
                onRetry: onRetry,
              );
        }

        if (snapshot.hasData) {
          return builder(snapshot.data as T);
        }

        return const Center(
          child: Text('No data available'),
        );
      },
    );
  }
}

/// Mixin for widgets that need error display functionality
mixin ErrorDisplayMixin {
  /// Show error snackbar
  void showError(BuildContext context, AppError error) {
    ErrorDisplay.showErrorSnackBar(context, error);
  }

  /// Show error dialog
  Future<void> showErrorDialog(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
    String? title,
  }) {
    return ErrorDisplay.showErrorDialog(
      context,
      error,
      onRetry: onRetry,
      title: title,
    );
  }

  /// Handle result and show error if needed
  void handleResult<T>(
    BuildContext context,
    Result<T> result, {
    void Function(T data)? onSuccess,
    void Function(AppError error)? onError,
    bool showSnackBar = true,
  }) {
    result.when(
      success: (data) => onSuccess?.call(data),
      failure: (error) {
        if (showSnackBar) {
          showError(context, error);
        }
        onError?.call(error);
      },
    );
  }
}
