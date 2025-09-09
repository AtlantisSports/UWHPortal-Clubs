/// User provider for managing current user state and role
library;

import 'package:flutter/foundation.dart';
import '../models/user_role.dart';

class UserProvider extends ChangeNotifier {
  UserRole _currentRole = UserRole.regularClubMember;
  String _userName = 'John Doe';
  String _userEmail = 'john.doe@example.com';

  // Getters
  UserRole get currentRole => _currentRole;
  String get userName => _userName;
  String get userEmail => _userEmail;
  
  // Role-based access getters
  bool get isAdmin => _currentRole.isAdmin;
  bool get isMember => _currentRole.isMember;
  
  /// Update user role (for testing different access levels)
  void updateRole(UserRole newRole) {
    if (_currentRole != newRole) {
      _currentRole = newRole;
      notifyListeners();
    }
  }
  
  /// Update user profile information
  void updateProfile({String? name, String? email}) {
    bool hasChanged = false;
    
    if (name != null && name != _userName) {
      _userName = name;
      hasChanged = true;
    }
    
    if (email != null && email != _userEmail) {
      _userEmail = email;
      hasChanged = true;
    }
    
    if (hasChanged) {
      notifyListeners();
    }
  }
}
