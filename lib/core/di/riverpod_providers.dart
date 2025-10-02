/// Riverpod DI providers - complete replacement for Provider-based AppProviders
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api/api_client.dart';
import '../config/environment_config.dart';
import '../services/user_service.dart';
import '../services/schedule_service.dart';
import '../repositories/interfaces/participation_repository.dart';
import '../repositories/interfaces/club_repository.dart';
import '../repositories/interfaces/practice_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/mock/mock_participation_repository.dart';
import '../repositories/mock/mock_club_repository.dart';
import '../repositories/mock/mock_practice_repository.dart';
import '../repositories/mock/mock_user_repository.dart';
import '../../features/clubs/clubs_repository.dart';
import '../../features/clubs/clubs_service.dart';
import '../../features/clubs/mock_clubs_service.dart';

part 'riverpod_providers.g.dart';

// === Core Services & Repositories ===

@riverpod
ApiClient apiClient(Ref ref) => ApiClient();

@riverpod
UserService userService(Ref ref) => EnvironmentConfig.useMockServices
    ? MockUserService()
    : ApiUserService();

@riverpod
ScheduleService scheduleService(Ref ref) => EnvironmentConfig.useMockServices
    ? MockScheduleService()
    : ApiScheduleService();

@riverpod
ClubsService clubsService(Ref ref) => EnvironmentConfig.useMockServices
    ? MockClubsService(ref.watch(apiClientProvider))
    : ClubsService(ref.watch(apiClientProvider));

@riverpod
UserRepository userRepository(Ref ref) => MockUserRepository();

@riverpod
ClubsRepository clubsRepository(Ref ref) => ClubsRepositoryImpl(
  clubsService: ref.watch(clubsServiceProvider),
);

@riverpod
ClubRepository clubRepository(Ref ref) => MockClubRepository();

@riverpod
PracticeRepository practiceRepository(Ref ref) => MockPracticeRepository();

@riverpod
ParticipationRepository participationRepository(Ref ref) => MockParticipationRepository(
  userService: ref.watch(userServiceProvider),
  clubsRepository: ref.watch(clubsRepositoryProvider),
);


