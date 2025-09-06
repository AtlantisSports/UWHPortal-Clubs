/// User role management for UWH Portal mockup
library;

import 'package:flutter/foundation.dart';

enum UserRole {
  clubAdmin('Club Admin', 'C_admin_user'),
  practiceAdmin('Practice Admin', 'P_admin_user'),
  clubMember('Club Member', 'club_user'),
  knownNonMember('Known Non-Club Member', 'known_user'),
  unknownUser('Unknown User', 'unknown_user');

  const UserRole(this.displayName, this.username);
  
  final String displayName;
  final String username;
}

class UserRoleManager extends ChangeNotifier {
  static final UserRoleManager _instance = UserRoleManager._internal();
  factory UserRoleManager() => _instance;
  UserRoleManager._internal();

  static UserRoleManager get instance => _instance;

  UserRole _currentRole = UserRole.clubAdmin; // Default role

  UserRole get currentRole => _currentRole;
  String get currentRoleDisplay => _currentRole.displayName;
  String get currentUsername => _currentRole.username;

  void setRole(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }

  List<UserRole> get allRoles => UserRole.values;
}
