/// User service for handling user-related operations
///
/// This service abstracts user data access and provides a clean interface
/// for user-related operations across the application.
library;

import 'dart:math';
import '../constants/app_constants.dart';
import '../data/mock_data_service.dart';
import '../errors/app_error.dart';
import '../models/guest.dart';

abstract class UserService {
  String get currentUserId;
  Future<PracticeGuestList> getPracticeGuests(String practiceId, DateTime practiceDate);
}

/// Mock implementation of UserService for development with error simulation
class MockUserService implements UserService {
  static final Random _random = Random();

  // Error simulation configuration
  static const double _errorRate = 0.05; // 5% chance of errors in development
  static const double _timeoutRate = 0.02; // 2% chance of timeouts
  static const double _networkErrorRate = 0.03; // 3% chance of network errors

  @override
  String get currentUserId => MockDataService.currentUserId;

  @override
  Future<PracticeGuestList> getPracticeGuests(String practiceId, DateTime practiceDate) async {
    // Simulate error scenarios if enabled
    if (EnvironmentConfig.enableDebugLogging) {
      await _simulateNetworkConditions();
    }

    // Simulate realistic API delay
    await Future.delayed(Duration(milliseconds: 50 + _random.nextInt(200)));

    return MockDataService.getMockGuestsForPractice(practiceId, practiceDate);
  }

  /// Simulate various network conditions and errors
  Future<void> _simulateNetworkConditions() async {
    final errorChance = _random.nextDouble();

    if (errorChance < _timeoutRate) {
      // Simulate timeout
      await Future.delayed(const Duration(seconds: 2));
      throw const AppError.timeout(
        message: 'Request timed out',
        details: 'The server took too long to respond',
      );
    }

    if (errorChance < _timeoutRate + _networkErrorRate) {
      // Simulate network error
      throw const AppError.network(
        message: 'Network connection failed',
        details: 'Unable to connect to the server',
        statusCode: 503,
      );
    }

    if (errorChance < _timeoutRate + _networkErrorRate + _errorRate) {
      // Simulate various API errors
      final errorType = _random.nextInt(4);
      switch (errorType) {
        case 0:
          throw const AppError.authentication(
            message: 'Authentication failed',
            details: 'Your session has expired',
          );
        case 1:
          throw const AppError.authorization(
            message: 'Access denied',
            details: 'You don\'t have permission to access this resource',
          );
        case 2:
          throw const AppError.server(
            message: 'Internal server error',
            details: 'The server encountered an unexpected error',
            statusCode: 500,
          );
        case 3:
          throw AppError.rateLimit(
            message: 'Too many requests',
            details: 'Please wait before making another request',
            retryAfter: const Duration(seconds: 30),
          );
      }
    }
  }
}

/// Production implementation would connect to real user API
class ApiUserService implements UserService {
  @override
  String get currentUserId {
    // TODO: Get from authentication service/token
    throw UnimplementedError('Production user service not implemented');
  }
  
  @override
  Future<PracticeGuestList> getPracticeGuests(String practiceId, DateTime practiceDate) async {
    // TODO: Implement API call to get practice guests
    throw UnimplementedError('Production user service not implemented');
  }
}