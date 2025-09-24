/// Service locator for dependency injection
/// 
/// This provides a centralized way to register and access services
/// throughout the application, improving testability and maintainability.
library;

import 'package:get_it/get_it.dart';
import '../api/api_client.dart';
import '../config/environment_config.dart';
import '../services/user_service.dart';
import '../services/schedule_service.dart';
import '../repositories/repository_factory.dart';
import '../repositories/interfaces/club_repository.dart';
import '../repositories/interfaces/practice_repository.dart';
import '../repositories/interfaces/participation_repository.dart';
import '../providers/participation_provider.dart';
import '../../features/clubs/clubs_service.dart';
import '../../features/clubs/mock_clubs_service.dart';
import '../../features/clubs/clubs_repository.dart';

final GetIt serviceLocator = GetIt.instance;

/// Initialize all services and dependencies
Future<void> setupServiceLocator() async {
  // Core services
  serviceLocator.registerLazySingleton<ApiClient>(() => ApiClient());
  
  // Environment-based service registration
  if (EnvironmentConfig.useMockServices) {
    // Development/Mock services
    serviceLocator.registerLazySingleton<UserService>(() => MockUserService());
    serviceLocator.registerLazySingleton<ScheduleService>(() => MockScheduleService());
    serviceLocator.registerLazySingleton<ClubsService>(
      () => MockClubsService(serviceLocator<ApiClient>()),
    );
  } else {
    // Production services
    serviceLocator.registerLazySingleton<UserService>(() => ApiUserService());
    serviceLocator.registerLazySingleton<ScheduleService>(() => ApiScheduleService());
    serviceLocator.registerLazySingleton<ClubsService>(
      () => ClubsService(serviceLocator<ApiClient>()),
    );
  }
  
  // Initialize repository factory
  RepositoryFactory.setEnvironment(
    EnvironmentConfig.useMockServices
      ? RepositoryEnvironment.mock
      : RepositoryEnvironment.api
  );

  // New repository layer
  serviceLocator.registerLazySingleton<IClubRepository>(
    () => RepositoryFactory.createClubRepository(),
  );
  serviceLocator.registerLazySingleton<IPracticeRepository>(
    () => RepositoryFactory.createPracticeRepository(),
  );
  serviceLocator.registerLazySingleton<IParticipationRepository>(
    () => RepositoryFactory.createParticipationRepository(),
  );

  // Providers
  serviceLocator.registerLazySingleton<ParticipationProvider>(
    () => ParticipationProvider(),
  );

  // Legacy repositories (keep for backward compatibility)
  serviceLocator.registerLazySingleton<ClubsRepository>(
    () => ClubsRepositoryImpl(clubsService: serviceLocator<ClubsService>()),
  );
  
  // Add more services here as the app grows
  // serviceLocator.registerLazySingleton<AuthService>(
  //   () => AuthService(serviceLocator<ApiClient>()),
  // );
  
  // Wait for any async initialization if needed
  await Future.delayed(Duration.zero);
}

/// Helper methods for easy access
class ServiceLocator {
  static T get<T extends Object>() => serviceLocator.get<T>();

  static ApiClient get apiClient => get<ApiClient>();
  static UserService get userService => get<UserService>();
  static ScheduleService get scheduleService => get<ScheduleService>();
  static ClubsService get clubsService => get<ClubsService>();

  // New repository interfaces
  static IClubRepository get clubRepository => get<IClubRepository>();
  static IPracticeRepository get practiceRepository => get<IPracticeRepository>();
  static IParticipationRepository get participationRepository => get<IParticipationRepository>();

  // Providers
  static ParticipationProvider get participationProvider => get<ParticipationProvider>();

  // Legacy repositories (for backward compatibility)
  static ClubsRepository get clubsRepository => get<ClubsRepository>();
}
