/// Mock implementation of practice repository
/// Uses the existing mock data for development and testing
library;

import '../interfaces/practice_repository.dart';
import '../../models/practice.dart';
import '../../models/practice_pattern.dart';
import '../../data/mock_data_service.dart';

/// Mock implementation of PracticeRepository using existing mock data
class MockPracticeRepository implements PracticeRepository {
  @override
  Future<List<Practice>> getClubPractices(String clubId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final clubs = await MockDataService.getClubs();
    final club = clubs.where((c) => c.id == clubId).firstOrNull;
    return club?.upcomingPractices ?? [];
  }

  @override
  Future<List<Practice>> getPracticesInRange({
    required String clubId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final practices = await getClubPractices(clubId);
    return practices.where((practice) {
      return practice.dateTime.isAfter(startDate.subtract(const Duration(days: 1))) &&
             practice.dateTime.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Future<List<Practice>> getUpcomingPractices(String clubId, {int? limit}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final practices = await getClubPractices(clubId);
    final now = DateTime.now();
    var upcoming = practices.where((p) => p.dateTime.isAfter(now)).toList();
    upcoming.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    if (limit != null && upcoming.length > limit) {
      upcoming = upcoming.take(limit).toList();
    }
    
    return upcoming;
  }

  @override
  Future<List<Practice>> getPastPractices(String clubId, {int? limit}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final practices = await getClubPractices(clubId);
    final now = DateTime.now();
    var past = practices.where((p) => p.dateTime.isBefore(now)).toList();
    past.sort((a, b) => b.dateTime.compareTo(a.dateTime)); // Most recent first
    
    if (limit != null && past.length > limit) {
      past = past.take(limit).toList();
    }
    
    return past;
  }

  @override
  Future<Practice?> getPracticeById(String practiceId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final clubs = await MockDataService.getClubs();
    for (final club in clubs) {
      try {
        return club.upcomingPractices.firstWhere((p) => p.id == practiceId);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  @override
  Future<List<Practice>> getPracticesByPattern(String patternId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final clubs = await MockDataService.getClubs();
    final allPractices = <Practice>[];
    for (final club in clubs) {
      allPractices.addAll(club.upcomingPractices);
    }
    return allPractices.where((p) => p.patternId == patternId).toList();
  }

  @override
  Future<String?> createPractice(Practice practice) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock implementation returns generated ID
    return 'practice_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<bool> updatePractice(Practice practice) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Mock implementation always succeeds
    return true;
  }

  @override
  Future<bool> cancelPractice(String practiceId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Mock implementation always succeeds
    return true;
  }

  @override
  Future<bool> deletePractice(String practiceId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Mock implementation always succeeds
    return true;
  }

  @override
  Future<List<PracticePattern>> getClubPracticePatterns(String clubId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Use MockDataService to get practice patterns
    return MockDataService.getPracticePatterns(clubId);
  }

  @override
  Future<String?> createPracticePattern(PracticePattern pattern) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'pattern_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<bool> updatePracticePattern(PracticePattern pattern) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  @override
  Future<bool> deletePracticePattern(String patternId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  @override
  Future<List<Practice>> generatePracticesFromPattern({
    required String patternId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Mock implementation returns empty list
    // In real implementation, this would generate practices based on pattern
    return [];
  }

  @override
  Future<List<String>> getClubLocations(String clubId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final practices = await getClubPractices(clubId);
    final locations = practices.map((p) => p.location).toSet().toList();
    locations.sort();
    return locations;
  }

  @override
  Future<List<String>> getClubLevels(String clubId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final practices = await getClubPractices(clubId);
    final levels = practices
        .where((p) => p.tag != null)
        .map((p) => p.tag!)
        .toSet()
        .toList();
    levels.sort();
    return levels;
  }

  @override
  Future<List<Practice>> searchPractices({
    required String clubId,
    String? location,
    String? level,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var practices = await getClubPractices(clubId);
    
    if (location != null) {
      practices = practices.where((p) => p.location == location).toList();
    }
    
    if (level != null) {
      practices = practices.where((p) => p.tag == level).toList();
    }
    
    if (startDate != null) {
      practices = practices.where((p) => p.dateTime.isAfter(startDate)).toList();
    }
    
    if (endDate != null) {
      practices = practices.where((p) => p.dateTime.isBefore(endDate)).toList();
    }
    
    return practices;
  }
}
