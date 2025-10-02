/// Riverpod version of UserProvider
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user_role.dart';

part 'user_riverpod.freezed.dart';
part 'user_riverpod.g.dart';

@freezed
abstract class UserState with _$UserState {
  const factory UserState({
    @Default(UserRole.regularClubMember) UserRole currentRole,
    @Default('John Doe') String userName,
    @Default('john.doe@example.com') String userEmail,
  }) = _UserState;
}

@riverpod
class UserController extends _$UserController {
  @override
  UserState build() {
    return const UserState();
  }

  // Getters for convenience
  UserRole get currentRole => state.currentRole;
  String get userName => state.userName;
  String get userEmail => state.userEmail;
  
  // Role-based access getters
  bool get isAdmin => state.currentRole.isAdmin;
  bool get isMember => state.currentRole.isMember;
  
  /// Update user role (for testing different access levels)
  void updateRole(UserRole newRole) {
    if (state.currentRole != newRole) {
      state = state.copyWith(currentRole: newRole);
    }
  }
  
  /// Update user profile information
  void updateProfile({String? name, String? email}) {
    bool hasChanged = false;
    String? newName;
    String? newEmail;
    
    if (name != null && name != state.userName) {
      newName = name;
      hasChanged = true;
    }
    
    if (email != null && email != state.userEmail) {
      newEmail = email;
      hasChanged = true;
    }
    
    if (hasChanged) {
      state = state.copyWith(
        userName: newName ?? state.userName,
        userEmail: newEmail ?? state.userEmail,
      );
    }
  }
}
