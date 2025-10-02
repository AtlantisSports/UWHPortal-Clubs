/// Riverpod version of ClubsProvider
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/club.dart';
import '../models/practice.dart';
import '../utils/error_handler.dart';
import '../di/riverpod_providers.dart';

part 'clubs_riverpod.freezed.dart';
part 'clubs_riverpod.g.dart';

@freezed
abstract class ClubsState with _$ClubsState {
  const factory ClubsState({
    @Default([]) List<Club> clubs,
    @Default(false) bool isLoading,
    String? error,
  }) = _ClubsState;
}

@riverpod
class ClubsController extends _$ClubsController {
  @override
  ClubsState build() {
    return const ClubsState();
  }

  // Getters for convenience
  List<Club> get clubs => state.clubs;
  bool get isLoading => state.isLoading;
  String? get error => state.error;

  /// Load all clubs from the repository
  Future<void> loadClubs() async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final clubsRepository = ref.read(clubsRepositoryProvider);
      final clubs = await clubsRepository.getClubs();
      
      // Initialize participation status for all upcoming practices
      final allPractices = <Practice>[];
      for (final club in clubs) {
        allPractices.addAll(club.upcomingPractices);
      }

      state = state.copyWith(
        clubs: clubs,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: AppErrorHandler.getErrorMessage(e),
        isLoading: false,
      );
    }
  }

  /// Get a club by ID
  Club? getClubById(String clubId) {
    try {
      return state.clubs.firstWhere((club) => club.id == clubId);
    } catch (e) {
      return null;
    }
  }

  /// Refresh clubs data
  Future<void> refreshClubs() async {
    await loadClubs();
  }

  /// Filter clubs by tags
  List<Club> getClubsByTags(List<String> tags) {
    return state.clubs.where((club) {
      return tags.any((tag) => club.tags.contains(tag));
    }).toList();
  }

  /// Search clubs by name or description
  List<Club> searchClubs(String query) {
    if (query.isEmpty) return state.clubs;
    
    final lowercaseQuery = query.toLowerCase();
    return state.clubs.where((club) {
      return club.name.toLowerCase().contains(lowercaseQuery) ||
             club.description.toLowerCase().contains(lowercaseQuery) ||
             club.shortName.toLowerCase().contains(lowercaseQuery) ||
             club.longName.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Get active clubs only
  List<Club> get activeClubs {
    return state.clubs.where((club) => club.isActive).toList();
  }
}
