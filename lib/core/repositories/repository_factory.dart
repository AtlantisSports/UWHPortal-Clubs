/// Repository factory for managing different implementations
/// Allows easy switching between mock and API implementations
library;

import 'interfaces/club_repository.dart';
import 'interfaces/practice_repository.dart';
import 'interfaces/participation_repository.dart';
import 'mock/mock_club_repository.dart';
import 'mock/mock_practice_repository.dart';
import 'mock/mock_participation_repository.dart';
// import 'api/api_club_repository.dart';
// import 'api/api_practice_repository.dart';
// import 'api/api_participation_repository.dart';

/// Environment configuration for repository selection
enum RepositoryEnvironment {
  mock,    // Use mock implementations for development/testing
  api,     // Use real API implementations for production
  hybrid,  // Mix of mock and API (useful for gradual migration)
}

/// Factory class for creating repository instances
class RepositoryFactory {
  static RepositoryEnvironment _environment = RepositoryEnvironment.mock;
  
  /// Set the current environment
  static void setEnvironment(RepositoryEnvironment environment) {
    _environment = environment;
  }
  
  /// Get current environment
  static RepositoryEnvironment get environment => _environment;
  
  /// Create club repository instance
  static IClubRepository createClubRepository() {
    switch (_environment) {
      case RepositoryEnvironment.mock:
      case RepositoryEnvironment.hybrid:
        return MockClubRepository();
      case RepositoryEnvironment.api:
        // When ready for API integration, uncomment:
        // return ApiClubRepository(ServiceLocator.apiClient);
        throw UnimplementedError('API club repository not yet implemented');
    }
  }
  
  /// Create practice repository instance
  static IPracticeRepository createPracticeRepository() {
    switch (_environment) {
      case RepositoryEnvironment.mock:
      case RepositoryEnvironment.hybrid:
        return MockPracticeRepository();
      case RepositoryEnvironment.api:
        // TODO: Return API implementation when available
        // return ApiPracticeRepository();
        throw UnimplementedError('API practice repository not yet implemented');
    }
  }
  
  /// Create participation repository instance
  static IParticipationRepository createParticipationRepository() {
    switch (_environment) {
      case RepositoryEnvironment.mock:
      case RepositoryEnvironment.hybrid:
        return MockParticipationRepository();
      case RepositoryEnvironment.api:
        // TODO: Return API implementation when available
        // return ApiParticipationRepository();
        throw UnimplementedError('API participation repository not yet implemented');
    }
  }
  
  /// Initialize all repositories with current environment
  static Map<String, dynamic> initializeRepositories() {
    return {
      'clubRepository': createClubRepository(),
      'practiceRepository': createPracticeRepository(),
      'participationRepository': createParticipationRepository(),
      'environment': _environment.name,
    };
  }
  
  /// Check if API implementations are available
  static bool get hasApiImplementations => false; // TODO: Update when API repos are implemented
  
  /// Get available environments
  static List<RepositoryEnvironment> get availableEnvironments {
    if (hasApiImplementations) {
      return RepositoryEnvironment.values;
    } else {
      return [RepositoryEnvironment.mock];
    }
  }
  
  /// Get environment display name
  static String getEnvironmentDisplayName(RepositoryEnvironment env) {
    switch (env) {
      case RepositoryEnvironment.mock:
        return 'Mock Data (Development)';
      case RepositoryEnvironment.api:
        return 'Live API (Production)';
      case RepositoryEnvironment.hybrid:
        return 'Hybrid (Mixed Sources)';
    }
  }
  
  /// Validate environment configuration
  static bool isEnvironmentValid(RepositoryEnvironment env) {
    switch (env) {
      case RepositoryEnvironment.mock:
        return true; // Always available
      case RepositoryEnvironment.api:
        return hasApiImplementations;
      case RepositoryEnvironment.hybrid:
        return hasApiImplementations;
    }
  }
}
