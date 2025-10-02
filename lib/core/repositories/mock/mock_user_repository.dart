/// Mock implementation of UserRepository for development and testing
/// 
/// This provides realistic mock user data and guest generation
/// while maintaining the same interface as the future production implementation.
library;

import 'dart:math';
import '../../models/guest.dart';
import '../user_repository.dart';

/// Mock repository that simulates user data and preferences
/// 
/// Features:
/// - Realistic guest data generation
/// - In-memory preference storage
/// - Configurable mock settings
class MockUserRepository implements UserRepository {
  
  // === Mock Data ===
  static const String _mockUserId = 'mock-user-123';
  static const String _mockUserDisplayName = 'Test User';
  
  final Map<String, dynamic> _preferences = {
    'notifications_enabled': true,
    'default_rsvp_reminder': 24, // hours
    'preferred_guest_types': ['New Player', 'Visitor'],
  };
  
  MockGuestSettings _mockGuestSettings = const MockGuestSettings();
  final Random _random = Random();
  
  // === User Identity ===
  
  @override
  String get currentUserId => _mockUserId;
  
  @override
  Future<String> getCurrentUserDisplayName() async {
    await Future.delayed(Duration(milliseconds: 50));
    return _mockUserDisplayName;
  }
  
  @override
  Future<bool> isAuthenticated() async {
    await Future.delayed(Duration(milliseconds: 10));
    return true; // Always authenticated in mock
  }
  
  // === User Preferences ===
  
  @override
  Future<Map<String, dynamic>> getUserPreferences() async {
    await Future.delayed(Duration(milliseconds: 100));
    return Map.from(_preferences);
  }
  
  @override
  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    await Future.delayed(Duration(milliseconds: 150));
    _preferences.addAll(preferences);
  }
  
  @override
  Future<T?> getPreference<T>(String key, {T? defaultValue}) async {
    await Future.delayed(Duration(milliseconds: 50));
    final value = _preferences[key];
    if (value is T) return value;
    return defaultValue;
  }
  
  @override
  Future<void> setPreference<T>(String key, T value) async {
    await Future.delayed(Duration(milliseconds: 100));
    _preferences[key] = value;
  }
  
  // === Guest Data (Mock Development) ===
  
  @override
  Future<PracticeGuestList> getPracticeGuests(String practiceId, DateTime practiceDate) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(200)));
    
    if (!_mockGuestSettings.enableRandomGuests) {
      return const PracticeGuestList();
    }
    
    // Generate deterministic but varied guest count based on practice ID
    final practiceHash = practiceId.hashCode.abs();
    final guestCount = _mockGuestSettings.minGuests + 
        (practiceHash % (_mockGuestSettings.maxGuests - _mockGuestSettings.minGuests + 1));
    
    if (guestCount == 0) {
      return const PracticeGuestList();
    }
    
    final guests = <Guest>[];
    
    for (int i = 0; i < guestCount; i++) {
      final guestType = _generateRandomGuestType(practiceHash + i);
      final guest = _generateMockGuest(guestType, i + 1);
      guests.add(guest);
    }
    
    return PracticeGuestList(guests: guests);
  }
  
  @override
  Future<MockGuestSettings> getMockGuestSettings() async {
    await Future.delayed(Duration(milliseconds: 50));
    return _mockGuestSettings;
  }
  
  @override
  Future<void> updateMockGuestSettings(MockGuestSettings settings) async {
    await Future.delayed(Duration(milliseconds: 100));
    _mockGuestSettings = settings;
  }
  
  // === Private Helper Methods ===
  
  GuestType _generateRandomGuestType(int seed) {
    final random = Random(seed);
    final roll = random.nextDouble();
    
    if (roll < _mockGuestSettings.newPlayerProbability) {
      return GuestType.newPlayer;
    } else if (roll < _mockGuestSettings.newPlayerProbability + _mockGuestSettings.visitorProbability) {
      return GuestType.visitor;
    } else if (roll < _mockGuestSettings.newPlayerProbability + _mockGuestSettings.visitorProbability + _mockGuestSettings.clubMemberProbability) {
      return GuestType.clubMember;
    } else {
      return GuestType.dependent;
    }
  }
  
  Guest _generateMockGuest(GuestType type, int index) {
    final names = [
      'Alex Johnson', 'Sam Wilson', 'Jordan Lee', 'Casey Brown',
      'Taylor Davis', 'Morgan Smith', 'Riley Jones', 'Avery Miller',
      'Quinn Garcia', 'Sage Rodriguez', 'River Martinez', 'Skyler Anderson'
    ];

    final name = names[index % names.length];
    final id = 'guest_${type.name}_$index';

    switch (type) {
      case GuestType.newPlayer:
        return NewPlayerGuest(
          id: id,
          name: name,
          waiverSigned: _random.nextBool(),
        );

      case GuestType.visitor:
        return VisitorGuest(
          id: id,
          name: name,
          homeClub: _random.nextBool() ? 'Other Club' : null,
          waiverSigned: _random.nextBool(),
        );

      case GuestType.clubMember:
        return ClubMemberGuest(
          id: id,
          name: name,
          memberId: 'CM${1000 + index}',
          hasPermission: true,
        );

      case GuestType.dependent:
        return DependentGuest(
          id: id,
          name: name,
          waiverSigned: _random.nextBool(),
        );
    }
  }

}
