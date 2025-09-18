import 'package:flutter/foundation.dart';
import '../../core/models/club.dart';
import '../../core/providers/participation_provider.dart';
import '../../core/utils/error_handler.dart';
import 'clubs_repository.dart';
import '../../core/di/service_locator.dart';

class ClubsProvider with ChangeNotifier {
  final ClubsRepository _clubsRepository;
  final ParticipationProvider participationProvider;
  
  ClubsProvider({
    required this.participationProvider,
    ClubsRepository? clubsRepository,
  }) : _clubsRepository = clubsRepository ?? ServiceLocator.clubsRepository;

  // State
  List<Club> _clubs = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Club> get clubs => _clubs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all clubs from the repository
  Future<void> loadClubs() async {
    if (_isLoading) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      _clubs = await _clubsRepository.getClubs();
      
      // Initialize participation status for all upcoming practices
      for (final club in _clubs) {
        for (final practice in club.upcomingPractices) {
          participationProvider.initializePracticeParticipation(practice);
        }
      }
      
      notifyListeners();
    } catch (e) {
      _error = AppErrorHandler.getErrorMessage(e);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Get a club by ID
  Club? getClubById(String clubId) {
    try {
      return _clubs.firstWhere((club) => club.id == clubId);
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
    return _clubs.where((club) {
      return tags.any((tag) => club.tags.contains(tag));
    }).toList();
  }

  /// Search clubs by name or description
  List<Club> searchClubs(String query) {
    if (query.isEmpty) return _clubs;
    
    final lowercaseQuery = query.toLowerCase();
    return _clubs.where((club) {
      return club.name.toLowerCase().contains(lowercaseQuery) ||
             club.description.toLowerCase().contains(lowercaseQuery) ||
             club.shortName.toLowerCase().contains(lowercaseQuery) ||
             club.longName.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Get active clubs only
  List<Club> get activeClubs {
    return _clubs.where((club) => club.isActive).toList();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
