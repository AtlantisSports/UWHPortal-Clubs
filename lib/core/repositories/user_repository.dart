/// Repository interface for user-related data access
/// 
/// This abstracts all user-related data operations, allowing
/// easy swapping between mock and real implementations.
library;

import '../models/guest.dart';

/// Abstract repository for managing user data and preferences
/// 
/// This interface defines all operations related to:
/// - Current user identification
/// - User preferences and settings
/// - User-specific guest data generation
/// 
/// Mock implementation: MockUserRepository
/// Future production: HttpUserRepository
abstract class UserRepository {
  
  // === User Identity ===
  
  /// Get the current authenticated user's ID
  String get currentUserId;
  
  /// Get the current user's display name
  Future<String> getCurrentUserDisplayName();
  
  /// Check if the current user is authenticated
  Future<bool> isAuthenticated();
  
  // === User Preferences ===
  
  /// Get user preferences as a key-value map
  Future<Map<String, dynamic>> getUserPreferences();
  
  /// Update user preferences
  Future<void> updateUserPreferences(Map<String, dynamic> preferences);
  
  /// Get a specific preference value with optional default
  Future<T?> getPreference<T>(String key, {T? defaultValue});
  
  /// Set a specific preference value
  Future<void> setPreference<T>(String key, T value);
  
  // === Guest Data (Mock Development) ===
  
  /// Generate mock guest data for a practice (development only)
  /// This method provides realistic guest data for UI testing
  /// Will be replaced with real guest management in production
  Future<PracticeGuestList> getPracticeGuests(String practiceId, DateTime practiceDate);
  
  /// Get mock guest generation settings (development only)
  Future<MockGuestSettings> getMockGuestSettings();
  
  /// Update mock guest generation settings (development only)
  Future<void> updateMockGuestSettings(MockGuestSettings settings);
}

/// Configuration for mock guest data generation (development only)
class MockGuestSettings {
  final bool enableRandomGuests;
  final int minGuests;
  final int maxGuests;
  final double newPlayerProbability;
  final double visitorProbability;
  final double clubMemberProbability;
  final double dependentProbability;
  
  const MockGuestSettings({
    this.enableRandomGuests = true,
    this.minGuests = 0,
    this.maxGuests = 4,
    this.newPlayerProbability = 0.3,
    this.visitorProbability = 0.2,
    this.clubMemberProbability = 0.3,
    this.dependentProbability = 0.2,
  });
  
  factory MockGuestSettings.fromJson(Map<String, dynamic> json) {
    return MockGuestSettings(
      enableRandomGuests: json['enableRandomGuests'] ?? true,
      minGuests: json['minGuests'] ?? 0,
      maxGuests: json['maxGuests'] ?? 4,
      newPlayerProbability: json['newPlayerProbability'] ?? 0.3,
      visitorProbability: json['visitorProbability'] ?? 0.2,
      clubMemberProbability: json['clubMemberProbability'] ?? 0.3,
      dependentProbability: json['dependentProbability'] ?? 0.2,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'enableRandomGuests': enableRandomGuests,
      'minGuests': minGuests,
      'maxGuests': maxGuests,
      'newPlayerProbability': newPlayerProbability,
      'visitorProbability': visitorProbability,
      'clubMemberProbability': clubMemberProbability,
      'dependentProbability': dependentProbability,
    };
  }
}
