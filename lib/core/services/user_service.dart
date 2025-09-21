/// User service for handling user-related operations
/// 
/// This service abstracts user data access and provides a clean interface
/// for user-related operations across the application.
library;

import '../data/mock_data_service.dart';
import '../models/guest.dart';

abstract class UserService {
  String get currentUserId;
  Future<PracticeGuestList> getPracticeGuests(String practiceId, DateTime practiceDate);
}

/// Mock implementation of UserService for development
class MockUserService implements UserService {
  @override
  String get currentUserId => MockDataService.currentUserId;
  
  @override
  Future<PracticeGuestList> getPracticeGuests(String practiceId, DateTime practiceDate) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    return MockDataService.getMockGuestsForPractice(practiceId, practiceDate);
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