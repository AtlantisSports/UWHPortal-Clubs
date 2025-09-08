/// Service locator for dependency injection
/// 
/// This provides a centralized way to register and access services
/// throughout the application, improving testability and maintainability.
library;

import 'package:get_it/get_it.dart';
import '../api/api_client.dart';
import '../../features/clubs/clubs_service.dart';
import '../../features/clubs/clubs_repository.dart';

final GetIt serviceLocator = GetIt.instance;

/// Initialize all services and dependencies
Future<void> setupServiceLocator() async {
  // Core services
  serviceLocator.registerLazySingleton<ApiClient>(() => ApiClient());
  
  // Feature services
  serviceLocator.registerLazySingleton<ClubsService>(
    () => ClubsService(serviceLocator<ApiClient>()),
  );
  
  // Repositories
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
  static ClubsService get clubsService => get<ClubsService>();
  static ClubsRepository get clubsRepository => get<ClubsRepository>();
}
